import 'package:TimeliNUS/blocs/app/appState.dart';
import 'package:TimeliNUS/screens/dashboardScreen.dart';
import 'package:TimeliNUS/screens/projectScreen.dart';
import 'package:TimeliNUS/screens/todoScreen.dart';
import 'package:TimeliNUS/screens/landingScreen.dart';
import 'package:flutter/widgets.dart';

List<Page> onGenerateAppViewPages(AppStatus state, List<Page<dynamic>> pages) {
  switch (state) {
    case AppStatus.authenticated:
      // return [LandingScreen.page()];
      return [DashboardScreen.page()];
    case AppStatus.unauthenticated:
      return [LandingScreen.page()];
    case AppStatus.onTodo:
      return [TodoScreen.page()];
    case AppStatus.onProject:
      return [ProjectScreen.page()];
    default:
      return [DashboardScreen.page()];
  }
}
