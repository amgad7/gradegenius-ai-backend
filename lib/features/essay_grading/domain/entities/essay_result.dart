import 'package:equatable/equatable.dart';

class EssayResult extends Equatable {
  final double score;

  final String grammar;

  final String coherence;

  final String vocabulary;

  final String semantics;

  final String category;

  final String title;

  final String grammarStatus;

  final String coherenceStatus;

  final List<VocabSuggestion> vocabSuggestions;

  final List<SpellingError> spellingErrors;

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

class SpellingError extends Equatable {
  final String wrong;

  final String correction;

  const SpellingError({required this.wrong, required this.correction});

  @override
  List<Object?> get props => [wrong, correction];
}

class VocabSuggestion extends Equatable {
  final String original;

  final String suggestion;

  const VocabSuggestion({required this.original, required this.suggestion});

  @override
  List<Object?> get props => [original, suggestion];
}
