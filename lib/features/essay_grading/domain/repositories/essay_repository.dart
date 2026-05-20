import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/essay.dart';
import '../entities/essay_result.dart';
import '../entities/essay_history_item.dart';

/// Repository interface for essay grading operations
/// Defined in Domain layer — implemented in Data layer
abstract class EssayRepository {
  /// Submit an essay for AI grading
  /// Returns [EssayResult] on success or [Failure] on error
  Future<Either<Failure, EssayResult>> submitEssay(Essay essay);

  /// Retrieve all previously graded essays from local storage
  Future<Either<Failure, List<EssayHistoryItem>>> getHistory();

  /// Delete a specific history item by its ID
  Future<Either<Failure, void>> deleteHistoryItem(String id);

  /// Clear all history
  Future<Either<Failure, void>> clearHistory();
}
