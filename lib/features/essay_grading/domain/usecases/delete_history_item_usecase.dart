import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/essay_repository.dart';

class DeleteHistoryItemUseCase extends UseCase<void, String> {
  final EssayRepository repository;

  DeleteHistoryItemUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteHistoryItem(id);
  }
}
