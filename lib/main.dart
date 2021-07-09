import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/app/appState.dart';
import 'package:TimeliNUS/blocs/app/blocObserver.dart';
import 'package:TimeliNUS/blocs/app/routes/routes.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/repository/projectRepository.dart';
import 'package:TimeliNUS/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:googleapis_auth/auth_io.dart";

Future<void> main() async {
  Bloc.observer = AppBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();

  // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  // AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  // print('Is emulator: ${!androidInfo.isPhysicalDevice}');
  // IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
  // print('Is emulator: ${!iosDeviceInfo.isPhysicalDevice}');
  // IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  await Firebase.initializeApp();
  await AppConstants.init();

  var id =
      ClientId("114066663509-j11htpbtn3u1p7dulr22bpjldopg3d11.apps.googleusercontent.com", "Zk7QGcCR6Ym_PxztseumHQfM");
  var scopes = ['https://www.googleapis.com/auth/calendar'];

  clientViaUserConsent(id, scopes, prompt).then((AuthClient client) {
    client.close();
  });

  final authenticationRepository = AuthenticationRepository();
  final projectRepository = ProjectRepository();
  await authenticationRepository.user.first;
  FirebaseMessaging.instance.onTokenRefresh.listen((token) {
    authenticationRepository.saveTokenToDatabase(token, authenticationRepository.currentUser.id);
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(App(authenticationRepository: authenticationRepository, projectRepository: projectRepository));
}

void prompt(String url) {
  print("Please go to the following URL and grant access:");
  print("  => $url");
  print("");
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class App extends StatelessWidget {
  const App({
    Key key,
    @required AuthenticationRepository authenticationRepository,
    @required ProjectRepository projectRepository,
  })  : _authenticationRepository = authenticationRepository,
        _projectRepository = projectRepository,
        super(key: key);
  // This widget is the root of your application.

  final AuthenticationRepository _authenticationRepository;
  final ProjectRepository _projectRepository;

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
            RepositoryProvider<ProjectRepository>(
              create: (context) => _projectRepository,
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
      home: FlowBuilder<AppState>(
        state: context.select((AppBloc bloc) => bloc.state),
        onGeneratePages: onGenerateAppViewPages,
      ), // Default home route
    );
  }
}
