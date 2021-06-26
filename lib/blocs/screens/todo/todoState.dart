import 'package:TimeliNUS/models/project.dart';
import 'package:TimeliNUS/models/todo.dart';
import 'package:TimeliNUS/screens/todoScreen.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TodoState extends Equatable {
  final List<Todo> todos;
  final double progress;
  TodoState(this.todos, this.progress, [List props = const []]) : super();
  @override
  List<Object> get props => [todos, progress];
}

class TodoLoading extends TodoState {
  final bool isNull;
  TodoLoading({this.isNull = false}) : super((isNull ? null : []), 0.0);
  @override
  String toString() => 'TodoLoading';
}

class TodoLoaded extends TodoState {
  final List<Todo> todos;

  final double progress;

  TodoLoaded(this.progress, this.todos) : super(todos, progress);

  @override
  String toString() => 'TodosLoaded { progress: $progress, todos: $todos }';

  @override
  List<Object> get props => [todos, progress];
}

class TodoNotLoaded extends TodoState {
  TodoNotLoaded() : super([], 0.0);
  @override
  String toString() => 'TodosNotLoaded';
}
