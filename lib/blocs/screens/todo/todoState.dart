import 'package:TimeliNUS/models/todo.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TodoState extends Equatable {
  TodoState([List props = const []]) : super();
  @override
  List<Object> get props => [];
}

class TodoLoading extends TodoState {
  @override
  String toString() => 'TodosLoading';
}

class TodoLoaded extends TodoState {
  final List<Todo> todos;

  TodoLoaded([this.todos = const []]) : super([todos]);

  @override
  String toString() => 'TodosLoaded { todos: $todos }';
}

class TodoNotLoaded extends TodoState {
  @override
  String toString() => 'TodosNotLoaded';
}
