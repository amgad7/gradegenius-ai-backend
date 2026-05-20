import 'package:equatable/equatable.dart';
import '../../domain/entities/essay_history_item.dart';

/// States for the history feature
abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state — history not yet loaded
class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

/// Loading state — fetching history from cache
class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

/// Loaded state — history items available
class HistoryLoaded extends HistoryState {
  /// List of past essay analyses
  final List<EssayHistoryItem> items;

  const HistoryLoaded({required this.items});

  @override
  List<Object?> get props => [items];
}

/// Error state — failed to load history
class HistoryError extends HistoryState {
  final String message;

  const HistoryError({required this.message});

  @override
  List<Object?> get props => [message];
}
