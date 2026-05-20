import '../../domain/entities/essay_history_item.dart';
import '../../domain/entities/essay_result.dart';
import 'essay_response_model.dart';

/// Data model for essay history persistence
/// Handles JSON serialization for SharedPreferences storage
class EssayHistoryModel extends EssayHistoryItem {
  const EssayHistoryModel({
    required super.id,
    required super.title,
    required super.category,
    required super.essayPreview,
    required super.essayText,
    required super.score,
    required super.timestamp,
    required super.result,
  });

  /// Create from a grading result + original essay text
  factory EssayHistoryModel.fromResult({
    required String id,
    required String essayText,
    required EssayResult result,
  }) {
    return EssayHistoryModel(
      id: id,
      title: result.title,
      category: result.category,
      essayPreview: essayText.length > 100
          ? '${essayText.substring(0, 100)}...'
          : essayText,
      essayText: essayText,
      score: result.score,
      timestamp: DateTime.now(),
      result: result,
    );
  }

  /// Parse from JSON (loaded from SharedPreferences)
  factory EssayHistoryModel.fromJson(Map<String, dynamic> json) {
    return EssayHistoryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      essayPreview: json['essay_preview'] as String,
      essayText: json['essay_text'] as String,
      score: (json['score'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      result: EssayResponseModel.fromJson(
        json['result'] as Map<String, dynamic>,
      ),
    );
  }

  /// Serialize to JSON for SharedPreferences storage
  Map<String, dynamic> toJson() {
    final resultModel = result is EssayResponseModel
        ? (result as EssayResponseModel)
        : EssayResponseModel(
            score: result.score,
            grammar: result.grammar,
            coherence: result.coherence,
            vocabulary: result.vocabulary,
            semantics: result.semantics,
            category: result.category,
            title: result.title,
            grammarStatus: result.grammarStatus,
            coherenceStatus: result.coherenceStatus,
            vocabSuggestions: result.vocabSuggestions,
            spellingErrors: result.spellingErrors,
            analysisTimeSeconds: result.analysisTimeSeconds,
          );

    return {
      'id': id,
      'title': title,
      'category': category,
      'essay_preview': essayPreview,
      'essay_text': essayText,
      'score': score,
      'timestamp': timestamp.toIso8601String(),
      'result': resultModel.toJson(),
    };
  }
}
