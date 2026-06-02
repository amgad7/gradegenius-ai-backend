import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/submit_essay_usecase.dart';
import '../../domain/entities/essay_result.dart';
import 'essay_state.dart';

class EssayCubit extends Cubit<EssayState> {
  final SubmitEssayUseCase submitEssayUseCase;

  EssayCubit({required this.submitEssayUseCase}) : super(const EssayInitial());

  Future<void> submitEssay(String text) async {
    emit(const EssayLoading(
      statusMessage: 'Loading context...',
      progress: 0.1,
    ));

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

    final result = await submitEssayUseCase(
      SubmitEssayParams(text: text),
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(EssayError(message: failure.message)),
      (essayResult) => emit(EssaySuccess(result: essayResult)),
    );
  }

  void showResult(EssayResult result) {
    emit(EssaySuccess(result: result));
  }

  void reset() {
    emit(const EssayInitial());
  }
}
