import 'dart:io';

const _datasetPath = 'datasets/essay_correction_evaluation.csv';
const _htmlPath = 'datasets/gradegenius_dataset.html';
const _wordPath = 'datasets/gradegenius_dataset.doc';

void main() {
  final datasetFile = File(_datasetPath);
  if (!datasetFile.existsSync()) {
    stderr.writeln('Dataset not found: $_datasetPath');
    exitCode = 1;
    return;
  }

  final rows = _readCsv(datasetFile);
  final html = _buildHtml(rows);

  File(_htmlPath).writeAsStringSync(html);
  File(_wordPath).writeAsStringSync(html);

  stdout.writeln('Generated: $_htmlPath');
  stdout.writeln('Generated: $_wordPath');
}

List<Map<String, String>> _readCsv(File file) {
  final lines = file.readAsLinesSync();
  if (lines.isEmpty) return [];

  final header = _parseCsvLine(lines.first);
  return lines.skip(1).where((line) => line.trim().isNotEmpty).map((line) {
    final values = _parseCsvLine(line);
    final map = <String, String>{};
    for (var i = 0; i < header.length; i++) {
      map[header[i]] = i < values.length ? values[i] : '';
    }
    return map;
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

String _buildHtml(List<Map<String, String>> rows) {
  final columns = [
    'id',
    'essay_text',
    'sample_type',
    'expected_wrong_words',
    'expected_corrections',
    'expected_category',
    'expected_vocab_original',
    'expected_vocab_suggestion',
    'notes',
  ];

  final bodyRows = rows
      .map((row) {
        final cells = columns
            .map((column) => '<td>${_escape(row[column] ?? '')}</td>')
            .join();
        return '<tr>$cells</tr>';
      })
      .join('\n');

  return '''
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>GradeGenius Dataset</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      color: #1f2937;
      margin: 32px;
      line-height: 1.5;
    }
    h1 {
      margin-bottom: 4px;
      color: #4f46e5;
    }
    .meta {
      color: #6b7280;
      margin-bottom: 24px;
    }
    .note {
      background: #f5f3ff;
      border-left: 4px solid #6c5ce7;
      padding: 12px 16px;
      margin: 16px 0 24px;
    }
    table {
      border-collapse: collapse;
      width: 100%;
      font-size: 12px;
    }
    th {
      background: #6c5ce7;
      color: white;
      text-align: left;
      padding: 8px;
      border: 1px solid #ddd;
    }
    td {
      vertical-align: top;
      padding: 8px;
      border: 1px solid #ddd;
    }
    tr:nth-child(even) {
      background: #f9fafb;
    }
  </style>
</head>
<body>
  <h1>GradeGenius Essay Correction Dataset</h1>
  <div class="meta">Labeled evaluation dataset - 30 samples</div>

  <div class="note">
    This dataset is used to test spelling correction, category detection, and simple vocabulary suggestions.
    The AI endpoint is a backend/API service. The model used by the Flutter app is Gemini 2.0 Flash through the Gemini API.
  </div>

  <h2>Dataset Table</h2>
  <table>
    <thead>
      <tr>
        ${columns.map((column) => '<th>${_escape(column)}</th>').join()}
      </tr>
    </thead>
    <tbody>
      $bodyRows
    </tbody>
  </table>
</body>
</html>
''';
}

String _escape(String text) {
  return text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
