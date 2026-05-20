# GradeGenius Project Dataset

This repository includes a labeled dataset for the graduation project:

`datasets/essay_correction_evaluation.csv`

The dataset is also registered in `pubspec.yaml` under Flutter assets, so it is part of the project files.

## What This Dataset Is Used For

GradeGenius uses Google Gemini 2.0 Flash as a pre-trained AI model. The project dataset is used for:

- testing spelling correction behavior
- checking expected corrections
- checking essay category detection
- checking simple vocabulary suggestions
- demonstrating the system during project review

## Important Note For Discussion

The app does not train Gemini locally. Gemini is already pre-trained by Google.

So the accurate explanation is:

"Our project uses a labeled evaluation dataset to test and validate the app output. The AI model itself is Gemini 2.0 Flash, which is a pre-trained model accessed through an API."

## Dataset Columns

- `id`: Sample number.
- `essay_text`: The essay/sample text entered into the app.
- `sample_type`: What the row is mainly testing.
- `expected_wrong_words`: Misspelled words expected to be detected.
- `expected_corrections`: Correct words expected from the app.
- `expected_category`: Expected broad category.
- `expected_vocab_original`: Word or phrase expected to appear in Better Words.
- `expected_vocab_suggestion`: Suggested clearer alternative.
- `notes`: Short reviewer note.

## How To Show It

1. Open `datasets/essay_correction_evaluation.csv`.
2. Show that it contains labeled essay samples.
3. Copy one row from `essay_text`.
4. Paste it into the app.
5. Compare the app result with the expected columns.

## How To Calculate Accuracy

Run this command from the project root:

```bash
dart run tools/evaluate_dataset.dart
```

For a quick test with only 5 rows:

```bash
dart run tools/evaluate_dataset.dart --limit=5
```

If Gemini returns rate-limit errors, run it slower:

```bash
dart run tools/evaluate_dataset.dart --delay-ms=5000
```

If it still returns HTTP `429`, the API key has no available quota. Wait for the quota to reset or replace the Gemini API key.

The script creates:

- `datasets/evaluation_results.csv`
- `datasets/evaluation_summary.md`

The summary file contains:

- spelling exact match accuracy
- category accuracy
- vocabulary accuracy
- overall row accuracy

Recommended examples to demonstrate:

- Row 1: spelling + vocabulary
- Row 6: history category
- Row 9: literature category
- Row 20: multiple spelling mistakes
