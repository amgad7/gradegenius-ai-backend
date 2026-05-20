import 'package:equatable/equatable.dart';
import 'essay_result.dart';

/// Domain entity representing a single essay history entry
class EssayHistoryItem extends Equatable {
  /// Unique identifier
  final String id;

  /// Auto-generated or user-provided essay title
  final String title;

  /// Detected category (ARGUMENTATIVE, ETHICS, etc.)
  final String category;

  /// Preview text (first ~100 chars of the essay)
  final String essayPreview;

  /// The full essay text
  final String essayText;

  /// The score received
  final double score;

  /// When the essay was analyzed
  final DateTime timestamp;

  /// Full grading result
  final EssayResult result;

  const EssayHistoryItem({
    required this.id,
    required this.title,
    required this.category,
    required this.essayPreview,
    required this.essayText,
    required this.score,
    required this.timestamp,
    required this.result,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        essayPreview,
        essayText,
        score,
        timestamp,
      ];
}
