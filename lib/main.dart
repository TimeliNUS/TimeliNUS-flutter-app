import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/app/appState.dart';
import 'package:TimeliNUS/blocs/app/blocObserver.dart';
import 'package:TimeliNUS/blocs/app/routes/routes.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/repository/todoRepository.dart';
import 'package:TimeliNUS/utils/services/firebase.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  Bloc.observer = AppBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();

  // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  // AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  // print('Is emulator: ${androidInfo.isPhysicalDevice}');

  // IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  await Firebase.initializeApp();
  // if (!iosInfo.isPhysicalDevice) {
  //   await FirebaseService().switchToEmulator();
  // }
  final authenticationRepository = AuthenticationRepository();
  final todoRepository = TodoRepository();
  await authenticationRepository.user.first;
  runApp(App(
      authenticationRepository: authenticationRepository,
      todoRepository: todoRepository));
}

class App extends StatelessWidget {
  const App({
    Key key,
    @required AuthenticationRepository authenticationRepository,
    @required TodoRepository todoRepository,
  })  : _authenticationRepository = authenticationRepository,
        _todoRepository = todoRepository,
        super(key: key);
  // This widget is the root of your application.

  final AuthenticationRepository _authenticationRepository;
  final TodoRepository _todoRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => AppBloc(
              authenticationRepository: _authenticationRepository,
            ),
        child: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AuthenticationRepository>(
              create: (context) => _authenticationRepository,
            ),
            RepositoryProvider<TodoRepository>(
              create: (context) => _todoRepository,
            ),
          ],
          child: AppView(),
        ));
  }
}

class AppView extends StatelessWidget {
  const AppView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      home: FlowBuilder<AppStatus>(
        state: context.select((AppBloc bloc) => bloc.state.status),
        onGeneratePages: onGenerateAppViewPages,
      ),
    );
  }
}
