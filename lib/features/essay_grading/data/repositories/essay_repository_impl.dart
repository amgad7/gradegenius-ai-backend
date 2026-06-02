import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/essay.dart';
import '../../domain/entities/essay_history_item.dart';
import '../../domain/entities/essay_result.dart';
import '../../domain/repositories/essay_repository.dart';
import '../datasources/essay_local_data_source.dart';
import '../datasources/essay_remote_data_source.dart';
import '../models/essay_history_model.dart';
import '../models/essay_request_model.dart';
import '../models/essay_response_model.dart';

class EssayRepositoryImpl implements EssayRepository {
  final EssayRemoteDataSource remoteDataSource;
  final EssayLocalDataSource localDataSource;
  final Uuid _uuid = const Uuid();

  EssayRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, EssayResult>> submitEssay(Essay essay) async {
    try {
      final request = EssayRequestModel(essayText: essay.text);
      final stopwatch = Stopwatch()..start();

      final response = await remoteDataSource.submitEssay(request);

      stopwatch.stop();
      final analysisTime = stopwatch.elapsedMilliseconds / 1000.0;

      final resultWithTime = response.copyWithTime(analysisTime);

      try {
        final historyItem = EssayHistoryModel.fromResult(
          id: _uuid.v4(),
          essayText: essay.text,
          result: resultWithTime,
        );
        await localDataSource.cacheResult(historyItem);
      } catch (_) {
      }

      return Right(resultWithTime);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<EssayHistoryItem>>> getHistory() async {
    try {
      final history = await localDataSource.getHistory();
      return Right(history);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message ?? 'Failed to load history'));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHistoryItem(String id) async {
    try {
      await localDataSource.deleteHistoryItem(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message ?? 'Failed to delete item'));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearHistory() async {
    try {
      await localDataSource.clearHistory();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message ?? 'Failed to clear history'));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }
}
