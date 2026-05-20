import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/submit_essay_usecase.dart';
import '../../domain/entities/essay_result.dart';
import 'essay_state.dart';

/// Cubit managing the essay grading flow
/// Handles submission, loading progress, and results
class EssayCubit extends Cubit<EssayState> {
  final SubmitEssayUseCase submitEssayUseCase;

  EssayCubit({required this.submitEssayUseCase}) : super(const EssayInitial());

  /// Submit an essay for grading
  /// Emits progressive loading states for the analyzing screen animation
  Future<void> submitEssay(String text) async {
    // Emit loading with progressive status messages
    emit(const EssayLoading(
      statusMessage: 'Loading context...',
      progress: 0.1,
    ));

    // Simulate progressive analysis steps
    await Future.delayed(const Duration(milliseconds: 500));
    if (isClosed) return;

    emit(const EssayLoading(
      statusMessage: 'Context Loaded',
      progress: 0.3,
    ));

    await Future.delayed(const Duration(milliseconds: 400));
    if (isClosed) return;

    emit(const EssayLoading(
      statusMessage: 'Evaluating Flow',
      progress: 0.5,
    ));

    await Future.delayed(const Duration(milliseconds: 400));
    if (isClosed) return;

    emit(const EssayLoading(
      statusMessage: 'Verifying Tone',
      progress: 0.7,
    ));

    // Actually call the use case
    final result = await submitEssayUseCase(
      SubmitEssayParams(text: text),
    );

    if (isClosed) return;

    // Emit success or error
    result.fold(
      (failure) => emit(EssayError(message: failure.message)),
      (essayResult) => emit(EssaySuccess(result: essayResult)),
    );
  }

  /// Check an old result from history without grading
  void showResult(EssayResult result) {
    emit(EssaySuccess(result: result));
  }

  /// Reset back to initial state
  void reset() {
    emit(const EssayInitial());
  }
}
