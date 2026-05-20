import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_history_usecase.dart';
import '../../domain/usecases/delete_history_item_usecase.dart';
import 'history_state.dart';

/// Cubit managing essay history
/// Handles loading, refreshing, and deleting history items
class HistoryCubit extends Cubit<HistoryState> {
  final GetHistoryUseCase getHistoryUseCase;
  final DeleteHistoryItemUseCase deleteHistoryItemUseCase;

  HistoryCubit({
    required this.getHistoryUseCase,
    required this.deleteHistoryItemUseCase,
  }) : super(const HistoryInitial());

  /// Load all history items from local storage
  Future<void> loadHistory() async {
    emit(const HistoryLoading());

    final result = await getHistoryUseCase(const NoParams());

    result.fold(
      (failure) => emit(HistoryError(message: failure.message)),
      (items) => emit(HistoryLoaded(items: items)),
    );
  }

  /// Delete a specific history item and refresh the list
  Future<void> deleteItem(String id) async {
    final result = await deleteHistoryItemUseCase(id);

    result.fold(
      (failure) => emit(HistoryError(message: failure.message)),
      (_) => loadHistory(), // Refresh the list after deletion
    );
  }
}
