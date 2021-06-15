import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/app/appEvent.dart';
import 'package:TimeliNUS/blocs/app/appState.dart';
import 'package:TimeliNUS/screens/todoScreen.dart';
import 'package:TimeliNUS/utils/transitionBuilder.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatefulWidget {
  static Page page() => MaterialPage(child: DashboardScreen());
  DashboardScreen({Key key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return ColoredSafeArea(
        appTheme.primaryColorLight,
        Scaffold(
            body: Column(
          children: [
            OutlinedButton(
                child: Text('Todo Screen'),
                onPressed: () =>
                    BlocProvider.of<AppBloc>(context).add(AppOnTodo())),
            OutlinedButton(
                child: Text('Project Screen'),
                onPressed: () =>
                    BlocProvider.of<AppBloc>(context).add(AppOnProject()))
          ],
        )));
  }
}
