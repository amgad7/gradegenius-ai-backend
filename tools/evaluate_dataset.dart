import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../lib/core/constants/app_constants.dart';
import '../lib/core/network/api_endpoints.dart';
import '../lib/features/essay_grading/data/models/essay_request_model.dart';

const _datasetPath = 'datasets/essay_correction_evaluation.csv';
const _resultsPath = 'datasets/evaluation_results.csv';
const _summaryPath = 'datasets/evaluation_summary.md';

Future<void> main(List<String> args) async {
  final limit = _readIntArg(args, '--limit');
  final delayMs = _readIntArg(args, '--delay-ms') ?? 300;

  final datasetFile = File(_datasetPath);
  if (!datasetFile.existsSync()) {
    stderr.writeln('Dataset not found: $_datasetPath');
    exitCode = 1;
    return;
  }

  final rows = _readDataset(datasetFile);
  final selectedRows = limit == null ? rows : rows.take(limit).toList();

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(
        milliseconds: AppConstants.connectTimeoutMs,
      ),
      receiveTimeout: const Duration(
        milliseconds: AppConstants.receiveTimeoutMs,
      ),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final results = <EvaluationResult>[];

  for (var i = 0; i < selectedRows.length; i++) {
    final row = selectedRows[i];
    stdout.writeln('Evaluating ${i + 1}/${selectedRows.length}: row ${row.id}');

    try {
      final response = await _submitEssay(dio, row.essayText);
      results.add(EvaluationResult.fromResponse(row, response));
    } catch (error) {
      results.add(EvaluationResult.failed(row, error.toString()));
    }

    if (i < selectedRows.length - 1 && delayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: delayMs));
    }
  }

  _writeResults(results);
  _writeSummary(results);

  stdout.writeln('');
  stdout.writeln('Done.');
  stdout.writeln('Results: $_resultsPath');
  stdout.writeln('Summary: $_summaryPath');
}

Future<Map<String, dynamic>> _submitEssay(Dio dio, String essayText) async {
  final request = EssayRequestModel(essayText: essayText);

  for (var attempt = 0; attempt < 2; attempt++) {
    try {
      final response = await dio.post(
        ApiEndpoints.generateContent,
        queryParameters: {'key': AppConstants.geminiApiKey},
        data: request.toGeminiPayload(),
      );

      final candidates = response.data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw const FormatException('Gemini returned no candidates.');
      }

      final content = candidates[0]['content']['parts'][0]['text'] as String;
      return json.decode(_cleanJson(content)) as Map<String, dynamic>;
    } on DioException catch (error) {
      if (error.response?.statusCode == 429 && attempt == 0) {
        await Future<void>.delayed(const Duration(seconds: 4));
        continue;
      }
      throw Exception(_formatDioError(error));
    }
  }

  throw StateError('Unexpected Gemini retry failure.');
}

String _formatDioError(DioException error) {
  final statusCode = error.response?.statusCode;
  final data = error.response?.data;
  final message = error.message ?? error.toString();
  if (statusCode == 429) {
    return 'Gemini API returned 429 rate limit/quota error. Wait and retry later, increase --delay-ms, or use a valid API key with available quota. Response: $data';
  }
  return 'Gemini API error. Status: $statusCode. Message: $message. Response: $data';
}

String _cleanJson(String content) {
  var cleanContent = content.trim();
  if (cleanContent.startsWith('```json')) {
    cleanContent = cleanContent.substring(7);
  } else if (cleanContent.startsWith('```')) {
    cleanContent = cleanContent.substring(3);
  }
  if (cleanContent.endsWith('```')) {
    cleanContent = cleanContent.substring(0, cleanContent.length - 3);
  }
  return cleanContent.trim();
}

List<DatasetRow> _readDataset(File file) {
  final lines = file.readAsLinesSync();
  if (lines.isEmpty) return [];

  final header = _parseCsvLine(lines.first);
  return lines.skip(1).where((line) => line.trim().isNotEmpty).map((line) {
    final values = _parseCsvLine(line);
    final map = <String, String>{};
    for (var i = 0; i < header.length; i++) {
      map[header[i]] = i < values.length ? values[i] : '';
    }
    return DatasetRow.fromCsv(map);
  }).toList();
}

List<String> _parseCsvLine(String line) {
  final values = <String>[];
  final current = StringBuffer();
  var inQuotes = false;

  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
        current.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (char == ',' && !inQuotes) {
      values.add(current.toString());
      current.clear();
    } else {
      current.write(char);
    }
  }

  values.add(current.toString());
  return values;
}

void _writeResults(List<EvaluationResult> results) {
  final buffer = StringBuffer();
  buffer.writeln(
    [
      'id',
      'status',
      'expected_wrong_words',
      'actual_wrong_words',
      'expected_corrections',
      'actual_corrections',
      'spelling_exact',
      'expected_category',
      'actual_category',
      'category_correct',
      'expected_vocab_original',
      'expected_vocab_suggestion',
      'actual_vocab',
      'vocab_correct',
      'error',
    ].join(','),
  );

  for (final result in results) {
    buffer.writeln(
      [
        result.row.id,
        result.status,
        result.row.expectedWrongWords.join('; '),
        result.actualWrongWords.join('; '),
        result.row.expectedCorrections.join('; '),
        result.actualCorrections.join('; '),
        result.spellingExact,
        result.row.expectedCategory,
        result.actualCategory,
        result.categoryCorrect,
        result.row.expectedVocabOriginal,
        result.row.expectedVocabSuggestion,
        result.actualVocabPairs.join('; '),
        result.vocabCorrect,
        result.error,
      ].map(_csvEscape).join(','),
    );
  }

  File(_resultsPath).writeAsStringSync(buffer.toString());
}

void _writeSummary(List<EvaluationResult> results) {
  final completed = results.where((result) => result.status == 'ok').toList();
  final rowsWithExpectedVocab = completed
      .where((result) => result.row.expectedVocabOriginal.isNotEmpty)
      .toList();

  final spellingAccuracy = _accuracy(
    completed.where((result) => result.spellingExact),
    completed,
  );
  final categoryAccuracy = _accuracy(
    completed.where((result) => result.categoryCorrect),
    completed,
  );
  final vocabAccuracy = _accuracy(
    rowsWithExpectedVocab.where((result) => result.vocabCorrect),
    rowsWithExpectedVocab,
  );
  final overallAccuracy = _accuracy(
    completed.where((result) => result.rowIsCorrect),
    completed,
  );

  final buffer = StringBuffer()
    ..writeln('# Evaluation Summary')
    ..writeln()
    ..writeln('- Dataset rows: ${results.length}')
    ..writeln('- Completed rows: ${completed.length}')
    ..writeln('- Failed rows: ${results.length - completed.length}')
    ..writeln()
    ..writeln('| Metric | Accuracy |')
    ..writeln('| --- | ---: |')
    ..writeln('| Spelling exact match | ${_percentOrNa(spellingAccuracy)} |')
    ..writeln('| Category accuracy | ${_percentOrNa(categoryAccuracy)} |')
    ..writeln('| Vocabulary accuracy | ${_percentOrNa(vocabAccuracy)} |')
    ..writeln('| Overall row accuracy | ${_percentOrNa(overallAccuracy)} |')
    ..writeln()
    ..writeln(
      'If rows fail with HTTP 429, the Gemini API key is rate-limited or out of quota. Wait and retry later, use a larger `--delay-ms`, or replace the API key.',
    )
    ..writeln()
    ..writeln('Generated by `dart run tools/evaluate_dataset.dart`.');

  File(_summaryPath).writeAsStringSync(buffer.toString());
}

double? _accuracy(Iterable<Object> correct, List<Object> total) {
  if (total.isEmpty) return null;
  return correct.length / total.length;
}

String _percentOrNa(double? value) {
  if (value == null) return 'N/A';
  return '${(value * 100).toStringAsFixed(1)}%';
}

String _csvEscape(Object? value) {
  final text = value?.toString() ?? '';
  if (!text.contains(',') && !text.contains('"') && !text.contains('\n')) {
    return text;
  }
  return '"${text.replaceAll('"', '""')}"';
}

int? _readIntArg(List<String> args, String name) {
  for (final arg in args) {
    if (arg.startsWith('$name=')) {
      return int.tryParse(arg.substring(name.length + 1));
    }
  }
  return null;
}

List<String> _splitExpected(String value) {
  if (value.trim().isEmpty) return [];
  return value
      .split(';')
      .map((part) => _normalize(part))
      .where((part) => part.isNotEmpty)
      .toList();
}

String _normalize(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

bool _sameSet(List<String> expected, List<String> actual) {
  return Set<String>.from(expected).containsAll(actual) &&
      Set<String>.from(actual).containsAll(expected);
}

class DatasetRow {
  final String id;
  final String essayText;
  final List<String> expectedWrongWords;
  final List<String> expectedCorrections;
  final String expectedCategory;
  final String expectedVocabOriginal;
  final String expectedVocabSuggestion;

  const DatasetRow({
    required this.id,
    required this.essayText,
    required this.expectedWrongWords,
    required this.expectedCorrections,
    required this.expectedCategory,
    required this.expectedVocabOriginal,
    required this.expectedVocabSuggestion,
  });

  factory DatasetRow.fromCsv(Map<String, String> csv) {
    return DatasetRow(
      id: csv['id'] ?? '',
      essayText: csv['essay_text'] ?? '',
      expectedWrongWords: _splitExpected(csv['expected_wrong_words'] ?? ''),
      expectedCorrections: _splitExpected(csv['expected_corrections'] ?? ''),
      expectedCategory: _normalize(csv['expected_category'] ?? ''),
      expectedVocabOriginal: _normalize(csv['expected_vocab_original'] ?? ''),
      expectedVocabSuggestion: _normalize(
        csv['expected_vocab_suggestion'] ?? '',
      ),
    );
  }
}

class EvaluationResult {
  final DatasetRow row;
  final String status;
  final List<String> actualWrongWords;
  final List<String> actualCorrections;
  final String actualCategory;
  final List<String> actualVocabPairs;
  final String error;

  const EvaluationResult({
    required this.row,
    required this.status,
    required this.actualWrongWords,
    required this.actualCorrections,
    required this.actualCategory,
    required this.actualVocabPairs,
    this.error = '',
  });

  factory EvaluationResult.fromResponse(
    DatasetRow row,
    Map<String, dynamic> response,
  ) {
    final spellingErrors =
        response['spelling_errors'] as List<dynamic>? ?? <dynamic>[];
    final vocabSuggestions =
        response['vocab_suggestions'] as List<dynamic>? ?? <dynamic>[];

    return EvaluationResult(
      row: row,
      status: 'ok',
      actualWrongWords: spellingErrors
          .map((item) => _normalize((item as Map)['wrong']?.toString() ?? ''))
          .where((word) => word.isNotEmpty)
          .toList(),
      actualCorrections: spellingErrors
          .map(
            (item) => _normalize((item as Map)['correction']?.toString() ?? ''),
          )
          .where((word) => word.isNotEmpty)
          .toList(),
      actualCategory: _normalize(response['category']?.toString() ?? ''),
      actualVocabPairs: vocabSuggestions
          .map((item) {
            final map = item as Map;
            final original = _normalize(map['original']?.toString() ?? '');
            final suggestion = _normalize(map['suggestion']?.toString() ?? '');
            return '$original->$suggestion';
          })
          .where((pair) => pair != '->')
          .toList(),
    );
  }

  factory EvaluationResult.failed(DatasetRow row, String error) {
    return EvaluationResult(
      row: row,
      status: 'failed',
      actualWrongWords: const [],
      actualCorrections: const [],
      actualCategory: '',
      actualVocabPairs: const [],
      error: error,
    );
  }

  bool get spellingExact {
    return _sameSet(row.expectedWrongWords, actualWrongWords) &&
        _sameSet(row.expectedCorrections, actualCorrections);
  }

  bool get categoryCorrect => row.expectedCategory == actualCategory;

  bool get vocabCorrect {
    if (row.expectedVocabOriginal.isEmpty) return true;
    final expected =
        '${row.expectedVocabOriginal}->${row.expectedVocabSuggestion}';
    return actualVocabPairs.contains(expected);
  }

  bool get rowIsCorrect => spellingExact && categoryCorrect && vocabCorrect;
}
