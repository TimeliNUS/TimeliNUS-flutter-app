import 'package:TimeliNUS/widgets/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewTodoPopup extends StatelessWidget {
  final TextEditingController controller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        TodoInput(controller),
        MyStatefulWidget(),
        ConstrainedBox(
            child: PersonInChargeChips(['Jin Zhao', 'Jin Jin']),
            constraints: BoxConstraints.expand(height: 200)),
        DeadlineInput(),
      ],
    );
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
  String dropdownValue = 'CS2103 Software Engineering';

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
        alignedDropdown: true,
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
            'CS2103 Software Engineering',
            'CS2101 Effective Communication for Computing Professionals'
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ));
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
                  child: const Text('JZ'),
                ),
                backgroundColor: appTheme.accentColor,
                label: Text(value, style: TextStyle(color: Colors.white))))
            .toList(),
      )
    ]);
  }
}

class DeadlineInput extends StatefulWidget {
  const DeadlineInput({Key key}) : super(key: key);

  @override
  State<DeadlineInput> createState() => _DeadlineInputState();
}

class _DeadlineInputState extends State<DeadlineInput> {
  bool showDatePicker = false;
  DateTime _chosenDateTime;

  // Show the modal that contains the CupertinoDatePicker
  void _showDatePicker(ctx) {
    // showCupertinoModalPopup is a built-in function of the cupertino library
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Container(
              height: 500,
              color: Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: [
                  Container(
                    height: 400,
                    child: CupertinoDatePicker(
                        initialDateTime: DateTime.now(),
                        onDateTimeChanged: (val) {
                          setState(() {
                            _chosenDateTime = val;
                          });
                        }),
                  ),

                  // Close the modal
                  CupertinoButton(
                    child: Text('OK'),
                    onPressed: () => Navigator.pop(context),
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
          OutlinedButton(
              child: Text("Someday"),
              onPressed: () => _showDatePicker(context)),
          // showDatePicker
          // ? CupertinoDatePicker(onDateTimeChanged: (val) => null)
          // ? CalendarDatePicker(
          //     firstDate: DateTime.now(),
          //     lastDate: DateTime.now(),
          //     initialDate: DateTime.now(),
          //     onDateChanged: (date) => null)
          //     : Container(),
          Row(children: [
            Expanded(
                child: Row(children: [
              Switch(
                value: true,
                onChanged: (bool) => null,
              ),
              Text("Include Time"),
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
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Text("21 : 30", textAlign: TextAlign.end)))
          ])
        ]);
  }
}
