import 'dart:async';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/repository/projectRepository.dart';
import 'package:TimeliNUS/repository/todoRepository.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:TimeliNUS/blocs/screens/todo/todoEvent.dart';
import 'package:TimeliNUS/blocs/screens/todo/todoState.dart';
import 'package:TimeliNUS/models/models.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository todoRepository;
  TodoBloc({@required this.todoRepository})
      : assert(todoRepository != null),
        super(TodoLoading());
  //       {
  //   if (id != null) {
  //     print(id);
  //     loadProjects();
  //   }
  // }

  // Future<List<Project>> loadProjects() async {
  //   projects = (await ProjectRepository().loadProjects(id))
  //       .map((project) => Project.fromEntity(project))
  //       .toList();
  // }

  // TodoState get initialState => TodoLoading();
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
    } else if (event is ReorderTodos) {
      yield* _mapReorderTodosToState(event);
    } else if (event is ToggleAll) {
      yield* _mapToggleAllToState();
    } else if (event is ClearCompleted) {
      yield* _mapClearCompletedToState();
    } else if (event is TodayTodo) {
      yield* _mapTodayTodoToState(event);
    }
  }

  Stream<TodoState> _mapLoadTodosToState(LoadTodos event) async* {
    try {
      yield TodoLoading();
      final todoEntities = await todoRepository.loadTodos(event.id);
      final List<Todo> todos =
          todoEntities.map((todo) => Todo.fromEntity(todo)).toList();
      yield TodoLoaded(
        calculateProgressPercentage(todos),
        todos,
      );
    } catch (err) {
      yield TodoNotLoaded();
    }
  }

  Stream<TodoState> _mapReorderTodosToState(ReorderTodos event) async* {
    yield TodoLoading();
    await todoRepository.reorderTodo(
        event.todos.map((item) => item.ref).toList(), event.id);
    yield TodoLoaded(state.progress, event.todos);
  }

  Stream<TodoState> _mapAddTodoToState(AddTodo event) async* {
    List<Todo> currentTodos = state.todos;
    yield TodoLoading();
    DocumentReference newTodoRef =
        await todoRepository.addNewTodo(event.todo.toEntity(), event.id);
    final updatedTodos = currentTodos
      ..add(event.todo.copyWith(ref: newTodoRef, id: newTodoRef.id));
    yield TodoLoaded(
      calculateProgressPercentage(updatedTodos),
      updatedTodos,
    );
  }

  Stream<TodoState> _mapUpdateTodoToState(UpdateTodo event) async* {
    yield TodoLoading();
    print("Event: " + event.updatedTodo.toString());
    Todo oldTodo;
    final updatedTodos = state.todos.map((todo) {
      if (todo.id == event.updatedTodo.id) {
        oldTodo = todo;
        return event.updatedTodo;
      } else {
        return todo;
      }
    }).toList();
    yield TodoLoaded(
      calculateProgressPercentage(updatedTodos),
      updatedTodos,
    );
    await todoRepository.updateTodo(
        oldTodo.toEntity(), event.updatedTodo.toEntity());
  }

  Stream<TodoState> _mapDeleteTodoToState(DeleteTodo event) async* {
    // if (state is TodoLoaded) {
    yield TodoLoading();
    final updatedTodos =
        state.todos.where((todo) => todo.id != event.todo.id).toList();
    yield TodoLoaded(
      calculateProgressPercentage(updatedTodos),
      updatedTodos,
    );
    // }
    await todoRepository.deleteTodo(event.todo, event.userId);
  }

  Stream<TodoState> _mapToggleAllToState() async* {
    if (state is TodoLoaded) {
      final allComplete =
          (state as TodoLoaded).todos.every((todo) => todo.complete);
      final updatedTodos = (state as TodoLoaded)
          .todos
          .map((todo) => todo.copyWith(complete: !allComplete))
          .toList();
      yield TodoLoaded(
        calculateProgressPercentage(updatedTodos),
        updatedTodos,
      );
    }
  }

  Stream<TodoState> _mapTodayTodoToState(TodayTodo event) async* {
    try {
      yield TodoLoading(isNull: true);
      final todoEntities = await todoRepository.loadTodos(event.id);
      final List<Todo> todos = todoEntities
          .map((todo) => Todo.fromEntity(todo))
          .where((todo) => todo.deadline.day == DateTime.now().day)
          .toList();
      yield TodoLoaded(
        calculateProgressPercentage(todos),
        todos,
      );
    } catch (err) {
      yield TodoNotLoaded();
    }
  }

  Stream<TodoState> _mapClearCompletedToState() async* {
    if (state is TodoLoaded) {
      final updatedTodos =
          (state as TodoLoaded).todos.where((todo) => !todo.complete).toList();
      yield TodoLoaded(
        calculateProgressPercentage(updatedTodos),
        updatedTodos,
      );
    }
  }

  double calculateProgressPercentage(List<Todo> todos) {
    double progress = (todos.length == 0
        ? 0
        : (todos.where((todo) => todo.complete).toList().length /
            todos.length));
    return progress;
  }

  @override
  void onChange(Change<TodoState> change) {
    super.onChange(change);
  }
}
