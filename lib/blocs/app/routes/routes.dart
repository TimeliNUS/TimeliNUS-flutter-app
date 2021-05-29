import 'package:TimeliNUS/blocs/app/appState.dart';
import 'package:TimeliNUS/screens/homeScreen.dart';
import 'package:TimeliNUS/screens/landingScreen.dart';
import 'package:flutter/widgets.dart';

List<Page> onGenerateAppViewPages(AppStatus state, List<Page<dynamic>> pages) {
  switch (state) {
    case AppStatus.authenticated:
      // return [LandingScreen.page()];
      return [HomeScreen.page()];
    case AppStatus.unauthenticated:
      return [LandingScreen.page()];
    default:
      return [HomeScreen.page()];
  }
}
