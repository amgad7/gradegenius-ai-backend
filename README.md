# Essay Correction Dataset

Main file:

`essay_correction_evaluation.csv`

This is the dataset file to show during the graduation project discussion.

It contains labeled examples for:

- spelling mistakes
- expected corrections
- expected essay categories
- simple vocabulary suggestions

Use it as the project evaluation dataset.

To calculate accuracy, run:

```bash
dart run tools/evaluate_dataset.dart
```

Output files:

- `evaluation_results.csv`
- `evaluation_summary.md`
