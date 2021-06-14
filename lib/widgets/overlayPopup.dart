import 'package:TimeliNUS/widgets/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PopupInput extends StatefulWidget {
  final TextEditingController controller;
  final String inputLabel;
  final String errorMsg;
  const PopupInput(this.controller,
      {Key key,
      this.inputLabel = 'Todo Title',
      this.errorMsg = 'Please enter your task!'})
      : super(key: key);

  @override
  State<PopupInput> createState() => _PopupInputState();
}

class _PopupInputState extends State<PopupInput> {
  String currentText = '';

  @override
  void initState() {
    super.initState();
    currentText = widget.controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('todoTitle_textField'),
      controller: widget.controller,
      onChanged: (value) => setState(() => currentText = value),
      decoration: InputDecoration(
        labelText: widget.inputLabel,
        labelStyle: TextStyle(color: appTheme.accentColor, fontSize: 18),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        errorText: currentText.length < 3 ? widget.errorMsg : null,
      ),
    );
  }
}

class PopupDropdown extends StatefulWidget {
  final String dropdownLabel;
  const PopupDropdown({@required this.dropdownLabel, Key key})
      : super(key: key);

  @override
  State<PopupDropdown> createState() => PopupDropdownState();
}

class PopupDropdownState extends State<PopupDropdown> {
  String dropdownValue = 'CS2103 Software Engineering Project';

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.dropdownLabel),
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

class PersonInChargeChips extends StatefulWidget {
  final String chipsLabel;
  final List<String> chipInput;
  const PersonInChargeChips(this.chipInput, this.chipsLabel);
  @override
  State<PersonInChargeChips> createState() => _PersonInChargeChipsState();
}

class _PersonInChargeChipsState extends State<PersonInChargeChips> {
  Map<String, bool> chipInputState;

  @override
  void initState() {
    chipInputState = Map.fromIterable(widget.chipInput,
        key: (e) => e.toString(), value: (e) => true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // chipInputState = Map.fromIterable(widget.chipInput,
    //     key: (e) => e.toString(),
    //     value: (e) => true); // <<< ADDING THIS HERE IS THE FIX
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.chipsLabel, style: appTheme.textTheme.bodyText2),
      Wrap(
        spacing: 8.0, // gap between adjacent chips
        runSpacing: 4.0, // gap between lines
        children: chipInputState.entries
            .map((e) => InputChip(
                avatar: CircleAvatar(
                  backgroundColor: Colors.grey.shade800,
                  child: const Text('ME'),
                ),
                shape: StadiumBorder(
                    side: BorderSide(color: appTheme.primaryColorLight)),
                backgroundColor: Colors.transparent,
                selectedColor: appTheme.primaryColorLight,
                selected: e.value,
                onPressed: () {
                  setState(() => chipInputState = chipInputState
                    ..update(e.key, (value) => !e.value));
                  print(chipInputState);
                },
                label: Text(e.key,
                    style: TextStyle(
                        color: e.value
                            ? Colors.white
                            : appTheme.primaryColorLight))))
            .toList(),
      )
    ]);
  }
}

class DeadlineInput extends StatefulWidget {
  final bool isOptional;
  final Function(DateTime date) callback;
  const DeadlineInput(this.callback, this.isOptional);
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
                    onPressed: () {
                      if (chosenDateTime == null) {
                        DateTime now = DateTime.now();
                        setState(() {
                          chosenDateTime = isWithTime
                              ? now
                              : new DateTime(now.year, now.month, now.day);
                        });
                        print(chosenDateTime);
                        widget.callback(chosenDateTime);
                      }
                      Navigator.of(context, rootNavigator: true).pop("OK");
                    },
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
          Text("Deadline" + (widget.isOptional ? "(Optional)" : "")),
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
