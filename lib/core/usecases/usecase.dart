import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base use case interface following Clean Architecture
/// [Type] is the return type, [Params] is the input parameter type
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Used when a use case requires no parameters
class NoParams {
  const NoParams();
}
