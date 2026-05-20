import '../../domain/entities/essay_result.dart';

/// Data model for the AI grading response
/// Handles JSON parsing and serialization
class EssayResponseModel extends EssayResult {
  const EssayResponseModel({
    required super.score,
    required super.grammar,
    required super.coherence,
    required super.vocabulary,
    required super.semantics,
    required super.category,
    required super.title,
    required super.grammarStatus,
    required super.coherenceStatus,
    required super.vocabSuggestions,
    super.spellingErrors,
    super.analysisTimeSeconds,
  });

  /// Parse from the AI response JSON
  factory EssayResponseModel.fromJson(Map<String, dynamic> json) {
    // Parse vocabulary suggestions
    final suggestionsJson = json['vocab_suggestions'] as List<dynamic>? ?? [];
    final suggestions = suggestionsJson
        .map(
          (s) => VocabSuggestion(
            original: s['original'] as String? ?? '',
            suggestion: s['suggestion'] as String? ?? '',
          ),
        )
        .where((s) => s.original.isNotEmpty && s.suggestion.isNotEmpty)
        .take(2)
        .toList();

    final spellingJson = json['spelling_errors'] as List<dynamic>? ?? [];
    final spellingErrors = spellingJson
        .map(
          (s) => SpellingError(
            wrong: s['wrong'] as String? ?? '',
            correction: s['correction'] as String? ?? '',
          ),
        )
        .where((s) => s.wrong.isNotEmpty && s.correction.isNotEmpty)
        .toList();

    return EssayResponseModel(
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      grammar: json['grammar'] as String? ?? 'No grammar feedback available.',
      coherence:
          json['coherence'] as String? ?? 'No coherence feedback available.',
      vocabulary:
          json['vocabulary'] as String? ?? 'No vocabulary feedback available.',
      semantics:
          json['semantics'] as String? ?? 'No semantics analysis available.',
      category: json['category'] as String? ?? 'OTHER',
      title: json['title'] as String? ?? 'Untitled Essay',
      grammarStatus:
          json['grammar_status'] as String? ?? 'Grammar analysis complete',
      coherenceStatus:
          json['coherence_status'] as String? ?? 'Coherence analysis complete',
      vocabSuggestions: suggestions,
      spellingErrors: spellingErrors,
      analysisTimeSeconds:
          (json['analysis_time_seconds'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Serialize to JSON (for local caching)
  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'grammar': grammar,
      'coherence': coherence,
      'vocabulary': vocabulary,
      'semantics': semantics,
      'category': category,
      'title': title,
      'grammar_status': grammarStatus,
      'coherence_status': coherenceStatus,
      'spelling_errors': spellingErrors
          .map((s) => {'wrong': s.wrong, 'correction': s.correction})
          .toList(),
      'vocab_suggestions': vocabSuggestions
          .map((s) => {'original': s.original, 'suggestion': s.suggestion})
          .toList(),
      'analysis_time_seconds': analysisTimeSeconds,
    };
  }

  /// Create a copy with updated analysis time
  EssayResponseModel copyWithTime(double seconds) {
    return EssayResponseModel(
      score: score,
      grammar: grammar,
      coherence: coherence,
      vocabulary: vocabulary,
      semantics: semantics,
      category: category,
      title: title,
      grammarStatus: grammarStatus,
      coherenceStatus: coherenceStatus,
      vocabSuggestions: vocabSuggestions,
      spellingErrors: spellingErrors,
      analysisTimeSeconds: seconds,
    );
  }
}
