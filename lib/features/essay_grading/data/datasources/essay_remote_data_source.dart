import 'dart:math';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/entities/essay_result.dart';
import '../models/essay_request_model.dart';
import '../models/essay_response_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';

abstract class EssayRemoteDataSource {
  Future<EssayResponseModel> submitEssay(EssayRequestModel request);
}

class EssayRemoteDataSourceMock implements EssayRemoteDataSource {
  @override
  Future<EssayResponseModel> submitEssay(EssayRequestModel request) async {
    final delay = 1500 + Random().nextInt(1500);
    await Future.delayed(Duration(milliseconds: delay));

    if (Random().nextInt(20) == 0) {
      throw const ServerException(
        message: 'API rate limit exceeded. Please try again later.',
        statusCode: 429,
      );
    }

    final essayText = request.essayText;

    final baseScore = _calculateBaseScore(essayText);

    final category = _detectCategory(essayText);

    final title = _generateTitle(essayText);

    return EssayResponseModel(
      score: baseScore,
      grammar: _generateGrammarFeedback(baseScore, essayText),
      coherence: _generateCoherenceFeedback(baseScore),
      vocabulary: _generateVocabularyFeedback(baseScore),
      semantics: _generateSemanticsFeedback(baseScore),
      category: category,
      title: title,
      grammarStatus: baseScore >= 7.0
          ? 'Overall mechanics are excellent'
          : baseScore >= 5.0
          ? 'Some grammar issues detected'
          : 'Significant grammar improvements needed',
      coherenceStatus: baseScore >= 7.0
          ? 'Logic flow is highly logical'
          : baseScore >= 5.0
          ? 'Flow could be improved'
          : 'Structure needs significant work',
      spellingErrors: _detectSpellingErrors(essayText),
      vocabSuggestions: _generateVocabSuggestions(essayText),
      analysisTimeSeconds: delay / 1000.0,
    );
  }

  double _calculateBaseScore(String text) {
    final wordCount = text.split(RegExp(r'\s+')).length;
    final sentenceCount = text.split(RegExp(r'[.!?]+')).length;
    final avgWordLength =
        text.replaceAll(RegExp(r'\s+'), '').length /
        (wordCount > 0 ? wordCount : 1);

    double score = 5.0;
    if (wordCount > 100) score += 1.0;
    if (wordCount > 200) score += 0.5;
    if (wordCount > 300) score += 0.5;
    if (avgWordLength > 4.5) score += 0.5;
    if (avgWordLength > 5.5) score += 0.5;
    if (sentenceCount > 5) score += 0.5;
    if (sentenceCount > 10) score += 0.5;

    score += (Random().nextDouble() * 1.0) - 0.5;

    return double.parse(score.clamp(3.0, 9.8).toStringAsFixed(1));
  }

  String _detectCategory(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('argue') ||
        lower.contains('debate') ||
        lower.contains('opinion') ||
        lower.contains('claim')) {
      return 'ARGUMENTATIVE';
    }
    if (lower.contains('novel') ||
        lower.contains('author') ||
        lower.contains('literary') ||
        lower.contains('symbolism')) {
      return 'LITERATURE REVIEW';
    }
    if (lower.contains('moral') ||
        lower.contains('ethical') ||
        lower.contains('rights') ||
        lower.contains('justice')) {
      return 'ETHICS';
    }
    if (lower.contains('history') ||
        lower.contains('century') ||
        lower.contains('war') ||
        lower.contains('revolution')) {
      return 'HISTORY';
    }
    if (lower.contains('story') ||
        lower.contains('narrative') ||
        lower.contains('character')) {
      return 'NARRATIVE';
    }
    return 'ARGUMENTATIVE'; // Default
  }

  String _generateTitle(String text) {
    final words = text.split(RegExp(r'\s+'));
    if (words.length < 5) return 'Short Essay Analysis';

    final titleWords = words
        .where(
          (w) =>
              w.length > 3 &&
              ![
                'the',
                'and',
                'for',
                'with',
                'that',
                'this',
                'from',
                'have',
              ].contains(w.toLowerCase()),
        )
        .take(6)
        .toList();

    if (titleWords.isEmpty) return 'Essay Analysis';

    return titleWords
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  String _generateGrammarFeedback(double score, String text) {
    String spellingFeedback = '';
    List<String> errors = [];

    final lowerText = text.toLowerCase();
    if (lowerText.contains('importent'))
      errors.add("'importent' should be 'important'");
    if (lowerText.contains('languges'))
      errors.add("'languges' should be 'languages'");
    if (lowerText.contains('futuer')) errors.add("'futuer' should be 'future'");
    if (lowerText.contains('contry'))
      errors.add("'contry' should be 'country'");
    if (lowerText.contains('teh ')) errors.add("'teh' should be 'the'");
    if (lowerText.contains('alot')) errors.add("'alot' should be 'a lot'");

    if (errors.isNotEmpty) {
      spellingFeedback = "Spelling errors detected: ${errors.join(', ')}.\n\n";
    }

    if (score >= 8.0) {
      return '${spellingFeedback}Grammar is mostly correct.';
    } else if (score >= 6.0) {
      return '${spellingFeedback}Check a few sentence structure issues.';
    }
    return '${spellingFeedback}Several grammar issues need correction.';
  }

  String _generateCoherenceFeedback(double score) {
    if (score >= 8.0) {
      return 'The ideas flow clearly.';
    } else if (score >= 6.0) {
      return 'Some transitions could be smoother.';
    }
    return 'The essay needs clearer organization.';
  }

  String _generateVocabularyFeedback(double score) {
    if (score >= 8.0) {
      return 'Vocabulary is clear and strong.';
    } else if (score >= 6.0) {
      return 'Use more precise words in repeated places.';
    }
    return 'Vocabulary needs more variety.';
  }

  String _generateSemanticsFeedback(double score) {
    if (score >= 8.0) {
      return 'The meaning is clear and connected.';
    } else if (score >= 6.0) {
      return 'Some ideas need clearer connection.';
    }
    return 'The main meaning needs clearer support.';
  }

  List<SpellingError> _detectSpellingErrors(String text) {
    final lowerText = text.toLowerCase();
    final errors = <SpellingError>[];

    void addIfFound(String wrong, String correction) {
      if (lowerText.contains(wrong)) {
        errors.add(SpellingError(wrong: wrong, correction: correction));
      }
    }

    addIfFound('importent', 'important');
    addIfFound('languges', 'languages');
    addIfFound('futuer', 'future');
    addIfFound('contry', 'country');
    addIfFound('teh', 'the');
    addIfFound('alot', 'a lot');

    return errors;
  }

  List<VocabSuggestion> _generateVocabSuggestions(String text) {
    final lowerText = text.toLowerCase();
    final suggestions = <VocabSuggestion>[];

    void addIfFound(String original, String suggestion) {
      if (lowerText.contains(original) && suggestions.length < 2) {
        suggestions.add(
          VocabSuggestion(original: original, suggestion: suggestion),
        );
      }
    }

    addIfFound('very big', 'huge');
    addIfFound('a lot of', 'many');
    addIfFound('good', 'strong');
    addIfFound('bad', 'weak');
    addIfFound('show', 'explain');
    addIfFound('think about', 'consider');

    return suggestions;
  }
}

class EssayRemoteDataSourceCustom implements EssayRemoteDataSource {
  final Dio dio;

  EssayRemoteDataSourceCustom({required this.dio});

  @override
  Future<EssayResponseModel> submitEssay(EssayRequestModel request) async {
    try {
      final response = await dio.post(
        '/gradio_api/call/run_analysis',
        data: {
          'data': [request.essayText],
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final eventId = responseData['event_id']?.toString();
      if (eventId == null || eventId.isEmpty) {
        throw const ServerException(
          message: 'NLP model did not return a Gradio event id.',
        );
      }

      final resultResponse = await dio.get(
        '/gradio_api/call/run_analysis/$eventId',
        options: Options(responseType: ResponseType.plain),
      );

      final gradioData = _parseGradioEventData(
        resultResponse.data?.toString() ?? '',
      );

      return _mapGradioResult(gradioData);
    } on DioException catch (e) {
      throw ServerException(
        message: 'Could not reach Menna NLP model: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Could not parse NLP model result: $e');
    }
  }

  List<dynamic> _parseGradioEventData(String eventBody) {
    final lines = eventBody.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('data:')) {
        final jsonText = trimmed.substring('data:'.length).trim();
        return json.decode(jsonText) as List<dynamic>;
      }
    }

    throw const ServerException(
      message: 'NLP model response did not contain Gradio data.',
    );
  }

  EssayResponseModel _mapGradioResult(List<dynamic> data) {
    dynamic at(int index) => data.length > index ? data[index] : null;

    final grammarStatus = at(0)?.toString() ?? 'Grammar analysis complete';
    final grammarErrors = at(1) is List ? at(1) as List<dynamic> : <dynamic>[];
    final spellingErrorsRaw = at(2) is List
        ? at(2) as List<dynamic>
        : <dynamic>[];
    final coherencePercent = _asDouble(at(3));

    final spellingErrors = spellingErrorsRaw
        .whereType<Map>()
        .map((item) {
          final wrong = (item['wrong_word'] ?? item['wrong'])?.toString() ?? '';
          final correction =
              (item['suggestion'] ?? item['correction'])?.toString() ?? '';
          return SpellingError(wrong: wrong, correction: correction);
        })
        .where((error) => error.wrong.isNotEmpty && error.correction.isNotEmpty)
        .toList();

    final grammarMessages = grammarErrors
        .whereType<Map>()
        .map((item) => item['message']?.toString() ?? '')
        .where((message) => message.isNotEmpty)
        .toList();

    final grammar = spellingErrors.isEmpty
        ? 'No spelling mistakes found.'
        : spellingErrors
              .map((error) => '${error.wrong} -> ${error.correction}')
              .join('; ');

    final score = double.parse(
      (coherencePercent / 10).clamp(0.0, 10.0).toStringAsFixed(1),
    );

    return EssayResponseModel(
      score: score,
      grammar: grammarMessages.isEmpty
          ? grammar
          : '$grammar ${grammarMessages.join(' ')}',
      coherence:
          'Sentence coherence score: ${coherencePercent.toStringAsFixed(1)}%.',
      vocabulary: 'This model focuses on grammar, spelling, and coherence.',
      semantics: 'The text was analyzed by the NLP grammar model.',
      category: 'OTHER',
      title: 'NLP Grammar Analysis',
      grammarStatus: grammarStatus,
      coherenceStatus: coherencePercent >= 70
          ? 'Coherence is strong'
          : coherencePercent >= 40
          ? 'Coherence could be improved'
          : 'Coherence needs improvement',
      vocabSuggestions: const [],
      spellingErrors: spellingErrors,
      analysisTimeSeconds: 0.0,
    );
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}

class EssayRemoteDataSourceGemini implements EssayRemoteDataSource {
  final Dio dio;
  final EssayRemoteDataSourceMock _mockFallback = EssayRemoteDataSourceMock();

  EssayRemoteDataSourceGemini({required this.dio});

  @override
  Future<EssayResponseModel> submitEssay(EssayRequestModel request) async {
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final response = await dio.post(
          ApiEndpoints.generateContent,
          data: request.toGeminiPayload(),
        );

        if (response.statusCode == 200) {
          final candidates = response.data['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final content =
                candidates[0]['content']['parts'][0]['text'] as String;

            String cleanContent = content.trim();
            if (cleanContent.startsWith('```json')) {
              cleanContent = cleanContent.substring(7);
            } else if (cleanContent.startsWith('```')) {
              cleanContent = cleanContent.substring(3);
            }
            if (cleanContent.endsWith('```')) {
              cleanContent = cleanContent.substring(0, cleanContent.length - 3);
            }
            cleanContent = cleanContent.trim();

            final jsonResponse =
                json.decode(cleanContent) as Map<String, dynamic>;
            return EssayResponseModel.fromJson(jsonResponse);
          }
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 429 && attempt == 0) {
          await Future.delayed(const Duration(seconds: 4));
          continue; // retry
        }
        break;
      } catch (_) {
        break;
      }
    }

    return _mockFallback.submitEssay(request);
  }
}
