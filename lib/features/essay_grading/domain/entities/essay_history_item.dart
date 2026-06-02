import 'package:equatable/equatable.dart';
import 'essay_result.dart';

class EssayHistoryItem extends Equatable {
  final String id;

  final String title;

  final String category;

  final String essayPreview;

  final String essayText;

  final double score;

  final DateTime timestamp;

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
