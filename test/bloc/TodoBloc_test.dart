import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/screens/todo/todo.dart';
import 'package:TimeliNUS/blocs/screens/todo/todoBloc.dart';
import 'package:TimeliNUS/models/todo.dart';
import 'package:TimeliNUS/models/todoEntity.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/repository/todoRepository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

class MockTodosBloc extends MockBloc<TodoEvent, TodoState> implements TodoBloc {
}

void main() {
  TodoRepository todoRepository;
  // TodoRepository todoRepositoryWithItem;
  TodoBloc todoBloc;
  // TodoBloc todoBlocWithItem;
  // setUpAll(() {
  //   registerFallbackValue<TodoState>(
  //       /* create a dummy instance of `TodoState` */);
  // });
  Todo testTodo = Todo('first', id: '123');

  setUp(() {
    todoRepository = MockTodoRepository();
    // todoRepositoryWithItem = MockTodoRepository();

    when(todoRepository.loadTodos(any)).thenAnswer((_) => Future.value([]));
    // when(todoRepositoryWithItem.loadTodos(any)).thenAnswer((_) =>
    //     Future.value([TodoEntity('test', '123', '', false, null, null)]));

    todoBloc = TodoBloc(todoRepository: todoRepository);
    // todoBlocWithItem = TodoBloc(todoRepository: todoRepositoryWithItem);
    // todoBlocWithItem.add(LoadTodos('123');
    // print(todoBlocWithItem.state);
  });
  // blocTest(
  //   'Reorder Todos',
  //   build: () => todoBloc,
  //   act: (TodoBloc bloc) async {
  //     bloc.add(AddTodo(testTodo, 'userId'));
  //     bloc.add(AddTodo(Todo('second', id: '234'), 'userId'));
  //     return bloc;
  //   },
  //   // ..add(ReorderTodos([Todo('second', id: '234'), testTodo], 'userId'));

  //   expect: () => [
  //     TodoLoading(),
  //     TodoLoaded(0, [testTodo]),
  //     TodoLoading(),
  //     TodoLoaded(0, [testTodo, Todo('second', id: '234')]),
  //     // TodoLoading(),
  //     // TodoLoaded(0, [Todo('second', id: '234'), testTodo]),
  //   ],
  // );
  group('TodoBloc', () {
    test('throws AssertionError if Authentication Repository is null', () {
      expect(
        () => TodoBloc(todoRepository: null),
        throwsA(isAssertionError),
      );
    });
    group('TodoBloc Load', () {
      blocTest(
        'Load Todos',
        build: () => todoBloc,
        act: (bloc) => bloc.add(LoadTodos('123')),
        expect: () => [
          TodoLoading(),
          TodoLoaded(0, []),
        ],
      );
      blocTest(
        'Add Todos',
        build: () => todoBloc,
        act: (bloc) => bloc.add(AddTodo(testTodo, 'userId')),
        expect: () => [
          TodoLoading(),
          TodoLoaded(0, [testTodo]),
        ],
      );
      blocTest(
        'Delete Todos',
        build: () => todoBloc,
        act: (bloc) => bloc
          ..add(AddTodo(testTodo, 'userId'))
          ..add(DeleteTodo(testTodo, 'userId')),
        expect: () => [
          TodoLoading(),
          TodoLoaded(0, [testTodo]),
          TodoLoading(),
          TodoLoaded(0, []),
        ],
      );
      blocTest(
        'Update Todos',
        build: () => todoBloc,
        act: (bloc) => bloc
          ..add(AddTodo(testTodo, 'userId'))
          ..add(UpdateTodo(Todo('yes', id: '123'))),
        expect: () => [
          TodoLoading(),
          TodoLoaded(0, [testTodo]),
          TodoLoading(),
          TodoLoaded(0, [Todo('yes', id: '123')]),
        ],
      );
    });
  });
}
