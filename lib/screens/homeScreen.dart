import 'package:TimeliNUS/blocs/screens/landing/landingCubit.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/widgets/landingScreen/actionButton.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/todoScreen/newTodoPopup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  static Page page() => MaterialPage(child: HomeScreen());

  @override
  Widget build(BuildContext context) {
    return ColoredSafeArea(
        appTheme.primaryColorLight,
        Scaffold(
            body: BlocProvider(
                create: (_) =>
                    LandingCubit(context.read<AuthenticationRepository>()),
                child: Container(
                    color: appTheme.primaryColorLight,
                    child: Column(children: [
                      Expanded(
                        child: Card(),
                      ),
                      wideActionButton(
                          "Logout",
                          () =>
                              context.read<AuthenticationRepository>().logOut())
                    ])))));
  }
}

class Card extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(40.0),
                topLeft: Radius.circular(40.0))),
        child: Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 15),
            child: Column(
              children: [
                Row(
                  children: [
                    Text("Todo",
                        style: TextStyle(
                            fontSize: 24, color: appTheme.primaryColorLight)),
                    Icon(Icons.add, color: appTheme.primaryColorLight)
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                Padding(padding: EdgeInsets.only(bottom: 15)),
                TodoItem(),
                NewTodoPopup()
              ],
            )));
  }
}

class TodoItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Container(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Row(children: [
                    Text(
                      "Task 1",
                      style: TextStyle(color: appTheme.primaryColor),
                    )
                  ]),
                  Padding(padding: EdgeInsets.only(top: 5)),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          color: appTheme.primaryColorLight),
                      Padding(padding: EdgeInsets.only(right: 5)),
                      Text("Mar 07, 2021  21:30",
                          style: TextStyle(color: appTheme.primaryColor))
                    ],
                  )
                ],
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: appTheme.primaryColorLight,
                    spreadRadius: 1,
                    blurRadius: 1),
              ],
            ),
          )),
          Padding(
            padding: EdgeInsets.only(right: 40),
          ),
          SizedBox(
              height: 24.0,
              width: 24.0,
              child: Checkbox(value: true, onChanged: (boolean) => {}))
        ],
      ),
    ]);
  }
}
