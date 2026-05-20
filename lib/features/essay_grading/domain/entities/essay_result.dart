import 'package:equatable/equatable.dart';

/// Domain entity representing the AI grading result
class EssayResult extends Equatable {
  /// Overall score from 0 to 10
  final double score;

  /// Detailed grammar feedback
  final String grammar;

  /// Detailed coherence feedback
  final String coherence;

  /// Detailed vocabulary feedback
  final String vocabulary;

  /// Detailed semantics analysis
  final String semantics;

  /// Auto-detected essay category (e.g., "ARGUMENTATIVE")
  final String category;

  /// Auto-generated title for the essay
  final String title;

  /// Short status line for grammar (e.g., "Overall mechanics are excellent")
  final String grammarStatus;

  /// Short status line for coherence (e.g., "Logic flow is highly logical")
  final String coherenceStatus;

  /// Vocabulary improvement suggestions
  final List<VocabSuggestion> vocabSuggestions;

  /// Detected spelling mistakes and their corrections
  final List<SpellingError> spellingErrors;

  /// Time taken for analysis (in seconds)
  final double analysisTimeSeconds;

  const EssayResult({
    required this.score,
    required this.grammar,
    required this.coherence,
    required this.vocabulary,
    required this.semantics,
    required this.category,
    required this.title,
    required this.grammarStatus,
    required this.coherenceStatus,
    required this.vocabSuggestions,
    this.spellingErrors = const [],
    this.analysisTimeSeconds = 0.0,
  });

  @override
  List<Object?> get props => [
    score,
    grammar,
    coherence,
    vocabulary,
    semantics,
    category,
    title,
    grammarStatus,
    coherenceStatus,
    vocabSuggestions,
    spellingErrors,
    analysisTimeSeconds,
  ];
}

/// A single spelling mistake detected in the essay
class SpellingError extends Equatable {
  /// The misspelled word exactly as written by the user
  final String wrong;

  /// The corrected spelling
  final String correction;

  const SpellingError({required this.wrong, required this.correction});

  @override
  List<Object?> get props => [wrong, correction];
}

/// A single vocabulary improvement suggestion
class VocabSuggestion extends Equatable {
  /// The original word/phrase used in the essay
  final String original;

  /// The suggested better alternative
  final String suggestion;

  const VocabSuggestion({required this.original, required this.suggestion});

  @override
  List<Object?> get props => [original, suggestion];
}
