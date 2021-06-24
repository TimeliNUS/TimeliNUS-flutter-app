import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/app/appEvent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app/appEvent.dart';

class BottomBar extends StatelessWidget {
  final currentIndex;
  final buttonToState = [
    AppOnTodo(),
    AppOnProject(),
    AppOnMeeting(),
    AppOnInvitation(invitationId: 'lJgJ3oEDfFG20z2CRoTp')
    // AppOnInvitation(invitationId: '0hscA8lb0nAw4TcmRqv7')
  ];

  BottomBar(this.currentIndex);
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (int index) =>
          BlocProvider.of<AppBloc>(context).add(buttonToState[index]),
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.done),
          label: 'Todo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          label: 'Project',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Meeting',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.email),
          label: 'Invitation',
        ),
      ],
      // currentIndex: _selectedIndex,
      selectedItemColor: Colors.amber[800],
      // onTap: _onItemTapped,
    );
  }
}
