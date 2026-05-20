import 'package:equatable/equatable.dart';

/// Domain entity representing an essay to be graded
class Essay extends Equatable {
  /// The full text of the essay
  final String text;

  /// Optional title (may be auto-detected by AI)
  final String? title;

  const Essay({
    required this.text,
    this.title,
  });

  @override
  List<Object?> get props => [text, title];
}
