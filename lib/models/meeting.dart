import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class Meeting extends Equatable {
  final String title;
  final DateTime deadline;

  const Meeting(this.title, {this.deadline});
  @override
  List<Object> get props => [title, deadline];
}
