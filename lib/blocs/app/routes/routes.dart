import 'package:TimeliNUS/blocs/app/appState.dart';
import 'package:TimeliNUS/screens/todoScreen.dart';
import 'package:TimeliNUS/screens/landingScreen.dart';
import 'package:flutter/widgets.dart';

List<Page> onGenerateAppViewPages(AppStatus state, List<Page<dynamic>> pages) {
  switch (state) {
    case AppStatus.authenticated:
      // return [LandingScreen.page()];
      return [TodoScreen.page()];
    case AppStatus.unauthenticated:
      return [LandingScreen.page()];
    default:
      return [TodoScreen.page()];
  }
}
