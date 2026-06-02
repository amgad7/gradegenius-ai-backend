import 'package:equatable/equatable.dart';

class Essay extends Equatable {
  final String text;

  final String? title;

  const Essay({
    required this.text,
    this.title,
  });

  @override
  List<Object?> get props => [text, title];
}
