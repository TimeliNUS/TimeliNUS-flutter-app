import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/screens/todo/todo.dart';
import 'package:TimeliNUS/models/todo.dart';
import 'package:TimeliNUS/screens/todoScreen.dart';
import 'package:TimeliNUS/widgets/landingScreen/actionButton.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class NewTodoPopup extends PopupRoute {
  @override
  Duration get transitionDuration => Duration(milliseconds: 500);

  final TextEditingController textController = new TextEditingController();
  final TextEditingController noteController = new TextEditingController();

  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  String get barrierLabel => "Add Todo Popup";

  DateTime deadlineValue;

  // final AnimationController _controller = AnimationController(
  //   duration: const Duration(seconds: 2), vsync: 10,
  // );
  // final Animation<Offset> _offsetAnimation = Tween<Offset>(
  //   begin: Offset.zero,
  //   end: const Offset(1.5, 0.0),
  // ).animate(CurvedAnimation(
  //   parent: _controller,
  //   curve: Curves.elasticIn,
  // ));

  // @override
  // Widget buildTransitions(BuildContext context, Animation<double> animation,
  //     Animation<double> secondaryAnimation, Widget widget) {
  //   return SlideTransition(
  //     position: 0.5,
  //   );
  // }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final todosBloc = BlocProvider.of<TodoBloc>(context);
    final appBloc = BlocProvider.of<AppBloc>(context);
    return ColoredSafeArea(
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
                                    // mainAxisAlignment: MainAxisAlignment.start,
                                    // mainAxisSize: MainAxisSize.min,
                                    // crossAxisAlignment:
                                    //     CrossAxisAlignment.start,
                                    children: [
                                      // TopBar(),
                                      TodoInput(textController),
                                      customPadding(),
                                      MyStatefulWidget(),
                                      customPadding(),
                                      PersonInChargeChips([
                                        appBloc.getCurrentUser().name ??
                                            "Myself"
                                      ]),
                                      customPadding(),
                                      // constraints: BoxConstraints.expand(height: 200)),
                                      DeadlineInput((val) =>
                                          setState(() => deadlineValue = val)),
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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Text("Add & Next",
                                        style: appTheme.textTheme.bodyText2
                                            .apply(color: Colors.white))),
                                onPressed: () {
                                  todosBloc.add(AddTodo(
                                      Todo(textController.text,
                                          note: noteController.text,
                                          deadline: deadlineValue),
                                      appBloc.getCurrentUser().id));
                                  Navigator.pop(context);
                                }),
                            OutlinedButton(
                                child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Text("Add & Done",
                                        style: appTheme.textTheme.bodyText2)),
                                onPressed: () => {})
                          ],
                        )),
                  )
                ]))));
  }
}

class TodoInput extends StatelessWidget {
  final TextEditingController controller;
  const TodoInput(this.controller);

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('todoTitle_textField'),
      controller: controller,
      decoration: InputDecoration(
          labelText: 'Todo Title',
          labelStyle: TextStyle(color: appTheme.accentColor, fontSize: 18),
          floatingLabelBehavior: FloatingLabelBehavior.always
          // errorText: controller.text.length < 3 ? 'Invalid Task!' : null,
          ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  String dropdownValue = 'CS2103 Software Engineering Project';

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Module Project"),
      ButtonTheme(
          // alignedDropdown: true,
          child: DropdownButton<String>(
        value: dropdownValue,
        icon: Icon(Icons.arrow_drop_down, color: appTheme.primaryColor),
        iconSize: 30,
        isExpanded: true,
        elevation: 16,
        style: TextStyle(color: appTheme.primaryColor),
        underline: Container(
          height: 2,
          color: appTheme.accentColor,
        ),
        onChanged: (String newValue) {
          setState(() {
            dropdownValue = newValue;
          });
        },
        items: <String>[
          'CS2103 Software Engineering Project',
          'CS2101 Effective Communication for Computing Professionals Project'
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
      ))
    ]);
  }
}

class PersonInChargeChips extends StatelessWidget {
  final List<String> chipInput;
  const PersonInChargeChips(this.chipInput);
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Person In Charge", style: appTheme.textTheme.bodyText2),
      Wrap(
        spacing: 8.0, // gap between adjacent chips
        runSpacing: 4.0, // gap between lines
        children: chipInput
            .map<Chip>((String value) => Chip(
                avatar: CircleAvatar(
                  backgroundColor: Colors.grey.shade800,
                  child: const Text('ME'),
                ),
                backgroundColor: appTheme.primaryColorLight,
                label: Text(value, style: TextStyle(color: Colors.white))))
            .toList(),
      )
    ]);
  }
}

class DeadlineInput extends StatefulWidget {
  final Function(DateTime date) callback;
  const DeadlineInput(this.callback);
  @override
  State<DeadlineInput> createState() => _DeadlineInputState();
}

class _DeadlineInputState extends State<DeadlineInput> {
  bool isWithTime = false;
  DateTime chosenDateTime;

  void _showDatePicker(ctx, bool isWithTime) {
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Container(
              height: 355,
              color: Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: [
                  Container(
                    height: 300,
                    child: CupertinoDatePicker(
                        mode: isWithTime
                            ? CupertinoDatePickerMode.dateAndTime
                            : CupertinoDatePickerMode.date,
                        initialDateTime: chosenDateTime ?? DateTime.now(),
                        onDateTimeChanged: (val) {
                          setState(() {
                            chosenDateTime = val;
                          });
                          widget.callback(val);
                        }),
                  ),
                  CupertinoButton(
                    child: Text('Confirm'),
                    onPressed: () =>
                        {Navigator.of(context, rootNavigator: true).pop("OK")},
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Deadline (Optional)"),
          InkWell(
              onTap: () => _showDatePicker(context, isWithTime),
              child: new Padding(
                  padding: new EdgeInsets.only(top: 10.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            chosenDateTime != null
                                ? DateFormat.yMMMd().format(chosenDateTime)
                                : "No deadline set",
                            style: appTheme.textTheme.bodyText2),
                        Padding(
                            padding: EdgeInsets.all(5),
                            child: Icon(Icons.calendar_today,
                                size: 24, color: appTheme.accentColor))
                      ]))),
          ClipPath(
              clipper: ShapeBorderClipper(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)))),
              child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: appTheme.accentColor, width: 1.0))))),
          Row(children: [
            Expanded(
                child: Row(children: [
              Text("Include Time"),
              Switch(
                value: isWithTime,
                activeColor: appTheme.accentColor,
                onChanged: (bool) => setState(() => isWithTime = !isWithTime),
              ),
            ])),
            Container(
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
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Text(
                        (chosenDateTime != null
                                ? chosenDateTime.hour.toString().padLeft(2, '0')
                                : "00") +
                            " : " +
                            (chosenDateTime != null
                                ? chosenDateTime.minute
                                    .toString()
                                    .padLeft(2, '0')
                                : "00"),
                        textAlign: TextAlign.end)))
          ])
        ]);
  }
}

class NotesInput extends StatelessWidget {
  final TextEditingController controller;
  const NotesInput(this.controller);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Notes"),
        Padding(padding: EdgeInsets.only(bottom: 10)),
        TextField(
          controller: controller,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: new InputDecoration.collapsed(
              hintText: 'Type your notes here',
              hintStyle: appTheme.textTheme.bodyText2),
        )
      ],
    );
  }
}

Widget customPadding() => Padding(padding: EdgeInsets.only(bottom: 40));
