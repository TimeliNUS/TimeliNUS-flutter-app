import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/authentication/authenticationBloc.dart';
import 'package:TimeliNUS/blocs/screens/landing/landingCubit.dart';
import 'package:TimeliNUS/blocs/screens/todo/todo.dart';
import 'package:TimeliNUS/models/todo.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/repository/todoRepository.dart';
import 'package:TimeliNUS/utils/transitionBuilder.dart';
import 'package:TimeliNUS/widgets/landingScreen/actionButton.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/todoScreen/newTodoPopup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
// import 'package:percent_indicator/percent_indicator.dart';

class TodoScreen extends StatelessWidget {
  static Page page() => MaterialPage(child: TodoScreen());

  @override
  Widget build(BuildContext context) {
    final appBloc = BlocProvider.of<AppBloc>(context);
    final todosBloc = BlocProvider.of<TodoBloc>(context)
      ..add(LoadTodos(appBloc.getCurrentUser().id));
    return BlocBuilder(
        bloc: todosBloc,
        builder: (BuildContext context, TodoState state) {
          return ColoredSafeArea(
              appTheme.primaryColorLight,
              Scaffold(
                  body: BlocProvider(
                      create: (_) => LandingCubit(
                          context.read<AuthenticationRepository>()),
                      child: Container(
                          color: appTheme.primaryColorLight,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TopBar(
                                    () => context
                                        .read<AuthenticationRepository>()
                                        .logOut(),
                                    "EG1234",
                                    "Example Project"),
                                Expanded(
                                  child: CustomCard(),
                                ),
                                // wideActionButton(
                                //     "test",
                                //     () => todosBloc.add(AddTodo(
                                //         Todo("test", "1234"),
                                //         appBloc.getCurrentUser().id))),
                              ])))));
        });
  }
}

class TopBar extends StatelessWidget {
  final Function() onPressedCallback;
  final String title;
  final String subtitle;
  const TopBar(this.onPressedCallback, this.title, [this.subtitle]);
  @override
  Widget build(BuildContext context) {
    return Container(
        color: appTheme.primaryColorLight,
        child: Padding(
            padding: EdgeInsets.only(left: 25, right: 25, bottom: 15),
            child: Row(children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: onPressedCallback,
              ),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(this.title,
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                    this.subtitle != null
                        ? Text(this.subtitle,
                            style: TextStyle(color: Colors.white, fontSize: 16))
                        : Container()
                  ])),
              // CircularPercentIndicator(
              //   radius: 60.0,
              //   lineWidth: 5.0,
              //   percent: 1.0,
              //   center: new Text("100%"),
              //   progressColor: appTheme.accentColor,
              // )
            ])));
  }
}

class CustomCard extends StatelessWidget {
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
                    IconButton(
                      icon: Icon(Icons.add, color: appTheme.primaryColorLight),
                      onPressed: () => Navigator.push(
                          context, SlideRightRoute(page: NewTodoPopup())),
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                Padding(padding: EdgeInsets.only(bottom: 15)),
                Expanded(
                    child: SingleChildScrollView(
                        clipBehavior: Clip.hardEdge,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 2),
                          child: BlocBuilder<TodoBloc, TodoState>(
                            buildWhen: (previousState, state) {
                              return state is TodoLoaded;
                            },
                            builder: (context, state) {
                              if (!(state is TodoLoaded)) {
                                return Container();
                              }
                              TodoLoaded temp = state as TodoLoaded;
                              return Column(
                                  children: temp.todos
                                      .map((todo) => TodoItem(todo))
                                      .toList());
                            },
                          ),
                        )))
              ],
            )));
  }
}

class TodoItem extends StatefulWidget {
  final Todo todo;
  const TodoItem(this.todo);

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  bool isChecked;
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
                      widget.todo.title,
                      style: TextStyle(color: appTheme.primaryColor),
                    )
                  ]),
                  Padding(padding: EdgeInsets.only(top: 5)),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          color: appTheme.primaryColorLight),
                      Padding(padding: EdgeInsets.only(right: 5)),
                      Text(
                          widget.todo.deadline != null
                              ? DateFormat('MMM dd, yyyy – kk:mm')
                                  .format(widget.todo.deadline)
                              : "No deadline set",
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
              child: Checkbox(
                  value: isChecked ?? widget.todo.complete,
                  onChanged: (boolean) => setState(() => isChecked =
                      (isChecked != null
                          ? !isChecked
                          : !widget.todo.complete))))
        ],
      ),
      Padding(padding: EdgeInsets.only(bottom: 10)),
    ]);
  }
}
