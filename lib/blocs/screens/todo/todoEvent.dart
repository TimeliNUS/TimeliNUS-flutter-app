import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:TimeliNUS/models/models.dart';

@immutable
abstract class TodoEvent extends Equatable {
  TodoEvent([List props]) : super();

  @override
  List<Object> get props => [...props];
}

class LoadTodos extends TodoEvent {
  final String id;
  final bool isSearchByProject;
  LoadTodos(this.id, {this.isSearchByProject = false}) : super([id]);
  @override
  String toString() => 'LoadTodos';

  @override
  List<Object> get props => [id];
}

class ReorderTodos extends TodoEvent {
  final List<Todo> todos;
  final String id;

  ReorderTodos(this.todos, this.id) : super([todos, id]);
  @override
  String toString() => 'Reorder Todos';

  @override
  List<Object> get props => [todos, id];
}

class AddTodo extends TodoEvent {
  final Todo todo;
  final String id;
  AddTodo(this.todo, this.id) : super([todo, id]);

  @override
  String toString() => 'AddTodo { todo: $todo, id: $id }';

  @override
  List<Object> get props => [todo, id];
}

class UpdateTodo extends TodoEvent {
  final Todo updatedTodo;

  UpdateTodo(this.updatedTodo) : super([updatedTodo]);

  @override
  String toString() => 'UpdateTodo { updatedTodo: $updatedTodo }';

  @override
  List<Object> get props => [updatedTodo];
}

class DeleteTodo extends TodoEvent {
  final Todo todo;
  final String userId;

  DeleteTodo(this.todo, this.userId) : super([todo, userId]);

  @override
  String toString() => 'DeleteTodo { todo: $todo }';

  @override
  List<Object> get props => [todo, userId];
}

class ClearCompleted extends TodoEvent {
  @override
  String toString() => 'ClearCompleted';
}

class ToggleAll extends TodoEvent {
  @override
  String toString() => 'ToggleAll';
}

class TodayTodo extends TodoEvent {
  final String id;
  TodayTodo(this.id) : super([id]);
  @override
  String toString() => 'TodayTodo';

  @override
  List<Object> get props => [id];
}
