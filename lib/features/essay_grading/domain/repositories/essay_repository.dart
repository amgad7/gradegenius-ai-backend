import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/essay.dart';
import '../entities/essay_result.dart';
import '../entities/essay_history_item.dart';

abstract class EssayRepository {
  Future<Either<Failure, EssayResult>> submitEssay(Essay essay);

  Future<Either<Failure, List<EssayHistoryItem>>> getHistory();

  Future<Either<Failure, void>> deleteHistoryItem(String id);

  Future<Either<Failure, void>> clearHistory();
}
