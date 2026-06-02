"""
GradeGenius - Dataset Evaluator
================================
Tests the custom NLP model against the project's dataset
to measure accuracy before connecting it to the Flutter app.

Run with:
    python evaluate_model.py
"""

import csv
from model.essay_grader import grade_essay


def load_dataset(filepath: str) -> list[dict]:
    """Load the CSV dataset into a list of test cases."""
    rows = []
    with open(filepath, encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append(row)
    return rows


def evaluate():
    dataset = load_dataset('../datasets/essay_correction_evaluation.csv')

    total = len(dataset)
    category_correct = 0
    spelling_correct = 0
    vocab_correct    = 0
    total_category   = 0
    total_spelling   = 0
    total_vocab      = 0

    print("=" * 70)
    print("  GradeGenius Custom NLP Model — Dataset Evaluation")
    print("=" * 70)

    for row in dataset:
        essay_id    = row['id']
        text        = row['essay_text']
        sample_type = row['sample_type']
        exp_category= row['expected_category'].strip()
        exp_wrong   = [w.strip().lower() for w in row['expected_wrong_words'].split(';') if w.strip()]
        exp_vocab_orig = row['expected_vocab_original'].strip().lower()

        result = grade_essay(text)

        # ── Category Check
        if exp_category and exp_category != '':
            total_category += 1
            predicted_cat = result['category']
            ok = predicted_cat == exp_category
            if ok:
                category_correct += 1
            status = '[OK]' if ok else '[FAIL]'
            print(f"\n[{essay_id}] Category {status} | Expected: {exp_category} | Got: {predicted_cat}")

        # ── Spelling Check
        if exp_wrong:
            total_spelling += 1
            found_words = {e['wrong'].lower() for e in result['spelling_errors']}
            all_found = all(w in found_words for w in exp_wrong)
            if all_found:
                spelling_correct += 1
            status = '[OK]' if all_found else '[FAIL]'
            print(f"   Spelling {status} | Expected: {exp_wrong} | Found: {list(found_words)}")

        # ── Vocab Check
        if exp_vocab_orig:
            total_vocab += 1
            found_originals = {s['original'].lower() for s in result['vocab_suggestions']}
            ok = exp_vocab_orig in found_originals
            if ok:
                vocab_correct += 1
            status = '[OK]' if ok else '[FAIL]'
            print(f"   Vocab   {status} | Expected phrase: '{exp_vocab_orig}' | Found: {found_originals}")

        print(f"   Score: {result['score']}/10  |  Category: {result['category']}")

    # ── Summary
    print("\n" + "=" * 70)
    print("  RESULTS SUMMARY")
    print("=" * 70)
    if total_category > 0:
        cat_acc = (category_correct / total_category) * 100
        print(f"  Category Accuracy : {category_correct}/{total_category} = {cat_acc:.1f}%")
    if total_spelling > 0:
        sp_acc = (spelling_correct / total_spelling) * 100
        print(f"  Spelling Accuracy : {spelling_correct}/{total_spelling} = {sp_acc:.1f}%")
    if total_vocab > 0:
        voc_acc = (vocab_correct / total_vocab) * 100
        print(f"  Vocab Accuracy    : {vocab_correct}/{total_vocab} = {voc_acc:.1f}%")
    print("=" * 70)


if __name__ == '__main__':
    evaluate()
