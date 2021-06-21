import 'dart:ui';

import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/screens/todo/todo.dart';
import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/widgets/overlayPopup.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/topBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewTodoPopup extends StatefulWidget {
  final TodoBloc todosBloc;
  const NewTodoPopup(this.todosBloc);
  @override
  State<NewTodoPopup> createState() => _NewTodoPopupState();
}

class _NewTodoPopupState extends State<NewTodoPopup> {
  DateTime deadlineValue;
  final TextEditingController textController = new TextEditingController();
  final TextEditingController noteController = new TextEditingController();
  List<User> pics = [];
  Project selectedProject;

  @override
  Widget build(BuildContext context) {
    String userId = context.read<AppBloc>().getCurrentUser().id;
    if (pics.isEmpty) {
      pics.add(context.select((AppBloc bloc) => bloc.state.user));
    }
    return BlocProvider<TodoBloc>(
        create: (context) => widget.todosBloc,
        child: ColoredSafeArea(
            appTheme.primaryColorLight,
            Scaffold(
                body: Container(
                    color: appTheme.primaryColorLight,
                    child: Column(children: [
                      TopBar(() => Navigator.pop(context), "Create Todo"),
                      Expanded(
                          child: GestureDetector(
                              onTap: () =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(40.0),
                                          topLeft: Radius.circular(40.0))),
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 30, right: 30, top: 15),
                                      child: ListView(
                                        children: [
                                          // TopBar(),
                                          PopupInput(textController),
                                          customPadding(),
                                          PopupDropdown(
                                              dropdownLabel: 'Module Project',
                                              callback: (val) => {
                                                    setState(() =>
                                                        selectedProject = val)
                                                  }),
                                          customPadding(),
                                          PersonInChargeChips(
                                              pics, "Person in Charge",
                                              project: selectedProject,
                                              callback: (val) {
                                            setState(() => pics = val);
                                          }),
                                          customPadding(),
                                          // constraints: BoxConstraints.expand(height: 200)),
                                          DeadlineInput(
                                              (val) => setState(
                                                  () => deadlineValue = val),
                                              true,
                                              initialTime: null),
                                          customPadding(),
                                          NotesInput(noteController),
                                        ],
                                      ))))),
                      Container(
                        color: Colors.white,
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                            padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).padding.bottom),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                appTheme.primaryColorLight)),
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text("Add & Next",
                                            style: appTheme.textTheme.bodyText2
                                                .apply(color: Colors.white))),
                                    onPressed: () {
                                      widget.todosBloc.add(AddTodo(
                                          Todo(textController.text,
                                              note: noteController.text,
                                              pic: pics,
                                              deadline: deadlineValue,
                                              project: selectedProject,
                                              complete: false),
                                          userId));
                                      Navigator.pop(context);
                                    }),
                                OutlinedButton(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text("Add & Done",
                                            style:
                                                appTheme.textTheme.bodyText2)),
                                    onPressed: () {
                                      widget.todosBloc.add(AddTodo(
                                          Todo(textController.text,
                                              note: noteController.text,
                                              deadline: deadlineValue,
                                              pic: pics,
                                              project: selectedProject,
                                              complete: true),
                                          userId));
                                      Navigator.pop(context);
                                    })
                              ],
                            )),
                      )
                    ])))));
  }
}

Widget customPadding() => Padding(padding: EdgeInsets.only(bottom: 40));
