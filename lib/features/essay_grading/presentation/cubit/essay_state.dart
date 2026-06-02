import 'package:equatable/equatable.dart';
import '../../domain/entities/essay_result.dart';

abstract class EssayState extends Equatable {
  const EssayState();

  @override
  List<Object?> get props => [];
}

class EssayInitial extends EssayState {
  const EssayInitial();
}

class EssayLoading extends EssayState {
  final String statusMessage;

  final double progress;

  const EssayLoading({
    this.statusMessage = 'Starting analysis...',
    this.progress = 0.0,
  });

  @override
  List<Object?> get props => [statusMessage, progress];
}

class EssaySuccess extends EssayState {
  final EssayResult result;

  const EssaySuccess({required this.result});

  @override
  List<Object?> get props => [result];
}

class EssayError extends EssayState {
  final String message;

  const EssayError({required this.message});

  @override
  List<Object?> get props => [message];
}
