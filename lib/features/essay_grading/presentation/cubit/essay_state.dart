import 'package:equatable/equatable.dart';
import '../../domain/entities/essay_result.dart';

/// States for the essay grading flow
abstract class EssayState extends Equatable {
  const EssayState();

  @override
  List<Object?> get props => [];
}

/// Initial state — ready for user input
class EssayInitial extends EssayState {
  const EssayInitial();
}

/// Loading state — essay is being analyzed
/// [statusMessage] shows the current analysis step for the UI animation
class EssayLoading extends EssayState {
  /// Current status text (e.g., "Context Loaded", "Evaluating Flow")
  final String statusMessage;

  /// Progress value from 0.0 to 1.0
  final double progress;

  const EssayLoading({
    this.statusMessage = 'Starting analysis...',
    this.progress = 0.0,
  });

  @override
  List<Object?> get props => [statusMessage, progress];
}

/// Success state — analysis complete, result available
class EssaySuccess extends EssayState {
  /// The full grading result from the AI
  final EssayResult result;

  const EssaySuccess({required this.result});

  @override
  List<Object?> get props => [result];
}

/// Error state — something went wrong
class EssayError extends EssayState {
  /// User-friendly error message
  final String message;

  const EssayError({required this.message});

  @override
  List<Object?> get props => [message];
}
