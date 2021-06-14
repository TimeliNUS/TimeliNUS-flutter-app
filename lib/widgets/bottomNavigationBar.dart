import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/app/appEvent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BottomBar extends StatelessWidget {
  final currentIndex;
  final buttonToState = [AppOnTodo(), AppOnProject()];

  BottomBar(this.currentIndex);
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
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
      ],
      // currentIndex: _selectedIndex,
      selectedItemColor: Colors.amber[800],
      // onTap: _onItemTapped,
    );
  }
}
