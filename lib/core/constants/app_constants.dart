import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static const int minEssayLength = 50;

  static const String apiBaseUrl = 'https://generativelanguage.googleapis.com';

  static String get customBackendUrl {
    return 'https://gradegenius-yourname-gradegenius-backend.hf.space';
  }


  static const String geminiApiKey = 'AIzaSyATJiHN8Xl0SUCxq6himAIBzUH_lY7QAb0';

  static const int connectTimeoutMs = 30000;

  static const int receiveTimeoutMs = 60000;

  static const int splashDurationMs = 3000;

  static const String historyKey = 'essay_history';
  static const String lastResultKey = 'last_result';

  static const String gradingPrompt = '''
You are an expert academic essay grader and proofreader. Analyze the following essay and provide a concise evaluation.

CRITICAL REQUIREMENT: You MUST detect spelling mistakes word-by-word. If the user writes a misspelled word such as "importent" instead of "important", or "languges" instead of "languages", you MUST include that exact wrong word and the corrected word in the spelling_errors array. If there are no spelling mistakes, return an empty spelling_errors array.

Grade the essay from 0 to 10 and keep all feedback short and practical:
1. Grammar & Spelling - if there are spelling mistakes, write ONLY the corrections as "wrong -> correction" pairs. If there are no spelling mistakes, write "No spelling mistakes found." Do not add long explanations.
2. Coherence - one short sentence only.
3. Vocabulary - one short sentence only.
4. Semantics - one short sentence only.

Also:
- Detect the essay category (ARGUMENTATIVE, LITERATURE REVIEW, ETHICS, HISTORY, NARRATIVE, or OTHER)
- Generate a short title for the essay (max 10 words)
- Suggest up to 2 simple vocabulary improvements. Only suggest a word or phrase that appears exactly in the essay. Use clear, common alternatives. If there is no clear improvement, return an empty vocab_suggestions array.

Return ONLY valid JSON in this exact format (do not include markdown block ticks like ```json):
{
  "score": 7.5,
  "grammar": "importent -> important; languges -> languages",
  "coherence": "The essay flow is mostly clear.",
  "vocabulary": "Use more precise academic words.",
  "semantics": "The main meaning is understandable.",
  "category": "ARGUMENTATIVE",
  "title": "The Impact of Climate Policy on Urban Infrastructure",
  "grammar_status": "Significant grammar improvements needed",
  "coherence_status": "Logic flow is highly logical",
  "spelling_errors": [
    {"wrong": "importent", "correction": "important"},
    {"wrong": "languges", "correction": "languages"}
  ],
  "vocab_suggestions": [
    {"original": "very big", "suggestion": "huge"},
    {"original": "a lot of", "suggestion": "many"}
  ]
}

Essay to grade:
''';
}
