import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/screens/todo/todo.dart';
import 'package:TimeliNUS/blocs/screens/todo/todoBloc.dart';
import 'package:TimeliNUS/models/todo.dart';
import 'package:TimeliNUS/models/todoEntity.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/repository/todoRepository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../integration/services/firebase/firebase_auth_test.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

class MockTodosBloc extends MockBloc<TodoEvent, TodoState> implements TodoBloc {}

void main() {
  TodoRepository todoRepository;
  // TodoRepository todoRepositoryWithItem;
  TodoBloc todoBloc;
  // TodoBloc todoBlocWithItem;
  // setUpAll(() {
  //   registerFallbackValue<TodoState>(
  //       /* create a dummy instance of `TodoState` */);
  // });
  setupCloudFirestoreMocks();
  Todo testTodo;
  TodoEntity originalTodoEntity;
  Todo originalTodo;
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    todoRepository = MockTodoRepository();
    DateTime currentDate = DateTime.now();
    originalTodo = Todo('original',
        id: '123', deadline: currentDate, ref: FirebaseFirestore.instance.collection('todo').doc('123'), pic: []);
    originalTodoEntity = TodoEntity('original', '123', '', false, Timestamp.fromDate(currentDate), null, null, false,
        FirebaseFirestore.instance.collection('todo').doc('123'));
    testTodo = Todo('first',
        id: '123',
        deadline: currentDate.subtract(Duration(days: 1)),
        ref: FirebaseFirestore.instance.collection('todo').doc('123'),
        includeTime: false);
    when(todoRepository.loadTodos(any)).thenAnswer((ans) => Future.value([originalTodoEntity]));
    when(todoRepository.addNewTodo(any, any)).thenAnswer(
        (ans) => Future.value(FirebaseFirestore.instance.collection('todo').doc(ans.positionalArguments[0].id)));
    todoBloc = TodoBloc(todoRepository: todoRepository);
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
          TodoLoaded(0, [originalTodo]),
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
        act: (bloc) => bloc..add(AddTodo(testTodo, 'userId'))..add(DeleteTodo(testTodo, 'userId')),
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
        act: (bloc) => bloc..add(AddTodo(testTodo, 'userId'))..add(UpdateTodo(Todo('yes', id: '123'))),
        expect: () => [
          TodoLoading(),
          TodoLoaded(0, [testTodo]),
          TodoLoading(),
          TodoLoaded(0, [Todo('yes', id: '123')]),
        ],
      );

      blocTest(
        'Today Todos',
        build: () => todoBloc,
        act: (bloc) => bloc..add(TodayTodo('userId')),
        expect: () => [
          TodoLoading(),
          TodoLoaded(0, [originalTodo]),
        ],
      );
    });
  });
}
