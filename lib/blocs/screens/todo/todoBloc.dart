import 'dart:async';
import 'package:TimeliNUS/repository/todoRepository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:TimeliNUS/blocs/screens/todo/todoEvent.dart';
import 'package:TimeliNUS/blocs/screens/todo/todoState.dart';
import 'package:TimeliNUS/models/models.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository todoRepository;

  TodoBloc({@required this.todoRepository}) : super(TodoLoading());

  TodoState get initialState => TodoLoading();

  @override
  Stream<TodoState> mapEventToState(TodoEvent event) async* {
    if (event is LoadTodos) {
      yield* _mapLoadTodosToState(event);
    } else if (event is AddTodo) {
      yield* _mapAddTodoToState(event);
    } else if (event is UpdateTodo) {
      yield* _mapUpdateTodoToState(event);
    } else if (event is DeleteTodo) {
      yield* _mapDeleteTodoToState(event);
    } else if (event is ToggleAll) {
      yield* _mapToggleAllToState();
    } else if (event is ClearCompleted) {
      yield* _mapClearCompletedToState();
    }
  }

  Stream<TodoState> _mapLoadTodosToState(LoadTodos event) async* {
    try {
      final todos = await todoRepository.loadTodos(event.id);
      print("finish");
      yield TodoLoaded(
        todos.map((todo) => Todo.fromEntity(todo)).toList(),
      );
    } catch (_) {
      yield TodoNotLoaded();
    }
  }

  Stream<TodoState> _mapAddTodoToState(AddTodo event) async* {
    if (state is TodoLoaded) {
      yield TodoLoading();
      final updatedTodos = List<Todo>.from((state as TodoLoaded).todos)
        ..add(event.todo);
      yield TodoLoaded(updatedTodos);
    }
    todoRepository.addNewTodo(event.todo.toEntity(), event.userId);
  }

  Stream<TodoState> _mapUpdateTodoToState(UpdateTodo event) async* {
    if (state is TodoLoaded) {
      final updatedTodos = (state as TodoLoaded).todos.map((todo) {
        return todo.id == event.updatedTodo.id ? event.updatedTodo : todo;
      }).toList();
      yield TodoLoaded(updatedTodos);
    }
    todoRepository.updateTodo(event.updatedTodo.toEntity());
  }

  Stream<TodoState> _mapDeleteTodoToState(DeleteTodo event) async* {
    if (state is TodoLoaded) {
      final updatedTodos = (state as TodoLoaded)
          .todos
          .where((todo) => todo.id != event.todo.id)
          .toList();
      yield TodoLoaded(updatedTodos);
    }
  }

  Stream<TodoState> _mapToggleAllToState() async* {
    if (state is TodoLoaded) {
      final allComplete =
          (state as TodoLoaded).todos.every((todo) => todo.complete);
      final updatedTodos = (state as TodoLoaded)
          .todos
          .map((todo) => todo.copyWith(complete: !allComplete))
          .toList();
      yield TodoLoaded(updatedTodos);
    }
  }

  Stream<TodoState> _mapClearCompletedToState() async* {
    if (state is TodoLoaded) {
      final updatedTodos =
          (state as TodoLoaded).todos.where((todo) => !todo.complete).toList();
      yield TodoLoaded(updatedTodos);
    }
  }
}
