import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:TimeliNUS/models/models.dart';

@immutable
abstract class TodoEvent extends Equatable {
  TodoEvent([List props = const []]) : super();

  @override
  List<Object> get props => [props];
}

class LoadTodos extends TodoEvent {
  final String id;
  LoadTodos(this.id) : super([id]);
  @override
  String toString() => 'LoadTodos';
}

class AddTodo extends TodoEvent {
  final Todo todo;
  final String userId;
  AddTodo(this.todo, this.userId) : super([todo, userId]);

  @override
  String toString() => 'AddTodo { todo: $todo, id: $userId }';
}

class UpdateTodo extends TodoEvent {
  final Todo updatedTodo;

  UpdateTodo(this.updatedTodo) : super([updatedTodo]);

  @override
  String toString() => 'UpdateTodo { updatedTodo: $updatedTodo }';
}

class DeleteTodo extends TodoEvent {
  final Todo todo;

  DeleteTodo(this.todo) : super([todo]);

  @override
  String toString() => 'DeleteTodo { todo: $todo }';
}

class ClearCompleted extends TodoEvent {
  @override
  String toString() => 'ClearCompleted';
}

class ToggleAll extends TodoEvent {
  @override
  String toString() => 'ToggleAll';
}
