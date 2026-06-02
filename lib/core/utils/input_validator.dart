import 'package:dartz/dartz.dart';
import '../error/failures.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';

class InputValidator {
  Either<Failure, String> validateEssay(String? text) {
    if (text == null || text.trim().isEmpty) {
      return const Left(ValidationFailure(AppStrings.errorEmpty));
    }

    final trimmed = text.trim();

    if (trimmed.length < AppConstants.minEssayLength) {
      return const Left(ValidationFailure(AppStrings.errorMinLength));
    }

    return Right(trimmed);
  }

  static int wordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
  }
}
