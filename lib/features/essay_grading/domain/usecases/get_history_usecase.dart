import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/essay_history_item.dart';
import '../repositories/essay_repository.dart';

class GetHistoryUseCase extends UseCase<List<EssayHistoryItem>, NoParams> {
  final EssayRepository repository;

  GetHistoryUseCase({required this.repository});

  @override
  Future<Either<Failure, List<EssayHistoryItem>>> call(NoParams params) async {
    return await repository.getHistory();
  }
}
