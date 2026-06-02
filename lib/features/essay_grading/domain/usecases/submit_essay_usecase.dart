import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/input_validator.dart';
import '../entities/essay.dart';
import '../entities/essay_result.dart';
import '../repositories/essay_repository.dart';

class SubmitEssayUseCase extends UseCase<EssayResult, SubmitEssayParams> {
  final EssayRepository repository;
  final InputValidator validator;

  SubmitEssayUseCase({
    required this.repository,
    required this.validator,
  });

  @override
  Future<Either<Failure, EssayResult>> call(SubmitEssayParams params) async {
    final validationResult = validator.validateEssay(params.text);

    return validationResult.fold(
      (failure) async => Left(failure),
      (validText) async {
        final essay = Essay(text: validText);
        return await repository.submitEssay(essay);
      },
    );
  }
}

class SubmitEssayParams {
  final String text;

  const SubmitEssayParams({required this.text});
}
