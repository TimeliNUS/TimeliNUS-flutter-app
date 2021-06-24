import 'package:TimeliNUS/blocs/app/appState.dart';
import 'package:TimeliNUS/screens/dashboardScreen.dart';
import 'package:TimeliNUS/screens/meetingScreen.dart';
import 'package:TimeliNUS/screens/projectScreen.dart';
import 'package:TimeliNUS/screens/todoScreen.dart';
import 'package:TimeliNUS/screens/landingScreen.dart';
import 'package:TimeliNUS/screens/invitationScreen.dart';
import 'package:flutter/widgets.dart';

List<Page> onGenerateAppViewPages(AppState state, List<Page<dynamic>> pages) {
  switch (state.status) {
    case AppStatus.authenticated:
      // return [LandingScreen.page()];
      return [MeetingScreen.page()];
    case AppStatus.unauthenticated:
      return [LandingScreen.page()];
    case AppStatus.onTodo:
      return [TodoScreen.page()];
    case AppStatus.onProject:
      return [ProjectScreen.page()];
    case AppStatus.onMeeting:
      return [MeetingScreen.page()];
    case AppStatus.onInvitation:
      return [Invitation.page(state.data)];
    default:
      return [DashboardScreen.page()];
  }
}
