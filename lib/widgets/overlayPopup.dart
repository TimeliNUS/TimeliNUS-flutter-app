import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/models/project.dart';
import 'package:TimeliNUS/models/userModel.dart';
import 'package:TimeliNUS/repository/projectRepository.dart';
import 'package:TimeliNUS/utils/transitionBuilder.dart';
import 'package:TimeliNUS/widgets/searchUser.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:TimeliNUS/utils/dateTimeExtension.dart';

class PopupInput extends StatefulWidget {
  final TextEditingController controller;
  final String inputLabel;
  final String errorMsg;
  const PopupInput(this.controller,
      {Key key, this.inputLabel = 'Todo Title', this.errorMsg = 'Please enter your task!'})
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
    return TextFormField(
      key: const Key('todoTitle_textField'),
      controller: widget.controller,
      onChanged: (value) => setState(() => currentText = value),
      decoration: InputDecoration(
        labelText: (widget.inputLabel + '*'),
        labelStyle: TextStyle(color: appTheme.accentColor, fontSize: 18),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        errorText: currentText.length < 3 ? widget.errorMsg : null,
      ),
      validator: (val) => (val.isEmpty) ? 'This field is required' : val,
    );
  }
}

class PopupDropdown extends StatefulWidget {
  final String dropdownLabel;
  final Function callback;
  final Project initialProject;
  final bool isDisabled;
  const PopupDropdown(
      {@required this.dropdownLabel, this.callback, this.initialProject, this.isDisabled = false, Key key})
      : super(key: key);

  @override
  State<PopupDropdown> createState() => PopupDropdownState();
}

class PopupDropdownState extends State<PopupDropdown> {
  List<Project> projects = [new Project('Please select a project!')];
  Project selectedProject;

  @override
  void initState() {
    super.initState();
    loadProjects(BlocProvider.of<AppBloc>(context).state.user.id, widget.initialProject);
  }

  void loadProjects(String id, Project initial) async {
    final returnedProjects = await context.read<ProjectRepository>().loadProjects(id).then((x) => x.map((e) {
          return Project.fromEntity(e);
        }).toList());

    setState(() {
      print(returnedProjects);
      projects.addAll(returnedProjects);
      // print(initial);
      if (initial != null) {
        try {
          selectedProject = projects.firstWhere((x) => x.id == initial.id);
        } catch (e) {
          projects[0] = new Project('Deleted project');
          selectedProject = projects[0];
        }
      } else {
        selectedProject = projects[0];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.dropdownLabel + '*'),
      ButtonTheme(
          // alignedDropdown: true,
          child: DropdownButton<Project>(
        value: projects.isNotEmpty ? selectedProject : null,
        icon: Icon(Icons.arrow_drop_down, color: appTheme.primaryColor),
        iconSize: 30,
        isExpanded: true,
        elevation: 16,
        style: TextStyle(color: appTheme.primaryColor),
        underline: Container(
          height: 2,
          color: appTheme.accentColor,
        ),
        // onTap: widget.isDisabled ? null : () => {},
        onChanged: widget.isDisabled
            ? null
            : (Project newValue) {
                // if (newValue != projects[0]) {
                widget.callback(newValue);
                // }
                setState(() {
                  selectedProject = newValue;
                });
              },
        items: projects.map<DropdownMenuItem<Project>>((Project proj) {
          return DropdownMenuItem<Project>(
            value: proj,
            child: Text(proj.title, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
      ))
    ]);
  }
}

class PersonInChargeChips extends StatefulWidget {
  final String chipsLabel;
  final List<User> chipInput;
  final Project project;
  final Function callback;
  const PersonInChargeChips(this.chipInput, this.chipsLabel, {this.callback, this.project});
  @override
  State<PersonInChargeChips> createState() => _PersonInChargeChipsState();
}

class _PersonInChargeChipsState extends State<PersonInChargeChips> {
  Map<User, bool> chipInputState;
  List<User> usersAvailableToChoose = [];

  void loadProjects(String id) async {
    final List<User> returnedProject =
        await ProjectRepository().loadProjectById(id).then((x) => Project.fromEntity(x).confirmed);
    if (mounted) {
      setState(() {
        usersAvailableToChoose = returnedProject;
      });
    }
  }

  @override
  void initState() {
    chipInputState =
        widget.chipInput.isNotEmpty ? Map.fromIterable(widget.chipInput, key: (e) => e, value: (e) => true) : new Map();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.project != null) loadProjects(widget.project.id);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text((widget.chipsLabel + '*'), style: appTheme.textTheme.bodyText2),
      Wrap(
        spacing: 8.0, // gap between adjacent chips
        runSpacing: 4.0, // gap between lines
        children: [
          ...(chipInputState.entries
              .map((e) => InputChip(
                  avatar: CircleAvatar(
                    backgroundColor: Colors.grey.shade800,
                  ),
                  shape: StadiumBorder(side: BorderSide(color: appTheme.primaryColorLight)),
                  backgroundColor: Colors.transparent,
                  selectedColor: appTheme.primaryColorLight,
                  selected: e.value,
                  onPressed: () {
                    setState(() => chipInputState = chipInputState..update(e.key, (value) => !e.value));
                    List<User> tempUser = [];
                    chipInputState.forEach((key, value) => value ? tempUser.add(key) : null);
                    widget.callback(tempUser);
                  },
                  label: Text(e.key.name ?? '',
                      style: TextStyle(color: e.value ? Colors.white : appTheme.primaryColorLight))))
              .toList()),
          ActionChip(
            label: Icon(Icons.add, color: appTheme.primaryColorLight),
            shape: StadiumBorder(side: BorderSide(color: appTheme.primaryColorLight)),
            backgroundColor: Colors.transparent,
            onPressed: () => Navigator.push(
                context,
                SlideRightRoute(
                    page: SearchUser((val) {
                  setState(() => chipInputState.putIfAbsent(val, () => true));
                  List<User> tempUser = [];
                  chipInputState.forEach((key, value) => value ? tempUser.add(key) : null);
                  widget.callback(tempUser);
                }, groupmates: usersAvailableToChoose))),
          )
        ],
      )
    ]);
  }
}

class DeadlineInput extends StatefulWidget {
  final bool isOptional;
  final bool isNotMini;
  final bool isWithTime;
  final bool isDisabled;
  final Function(DateTime date) callback;
  final Function(bool isIncludingTime) callbackForTime;
  final DateTime initialTime;
  DeadlineInput(this.callback, this.isOptional, this.isWithTime,
      {this.initialTime, this.isNotMini = true, this.isDisabled = false, this.callbackForTime});
  @override
  State<DeadlineInput> createState() => _DeadlineInputState();
}

class _DeadlineInputState extends State<DeadlineInput> {
  bool isWithTime;
  DateTime chosenDateTime;
  DateTime now = DateTime.now();
  @override
  void initState() {
    super.initState();
    isWithTime = widget.isWithTime;
    chosenDateTime = widget.initialTime ?? (widget.isOptional ? null : now.stripTime());
  }

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
                        mode: isWithTime ? CupertinoDatePickerMode.dateAndTime : CupertinoDatePickerMode.date,
                        initialDateTime: chosenDateTime,
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
                        setState(() {
                          chosenDateTime = isWithTime ? now : now.stripTime();
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
    return Flex(
        direction: widget.isNotMini ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.start,
        // mainAxisSize: widget.isNotMini ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.isNotMini ? Text("Deadline" + (widget.isOptional ? "(Optional)" : "")) : Container(),
          Expanded(
              flex: widget.isNotMini ? 0 : 1,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                InkWell(
                    onTap: widget.isDisabled ? null : () => _showDatePicker(context, isWithTime),
                    child: new Padding(
                        padding: new EdgeInsets.only(top: 10.0),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(chosenDateTime != null ? DateFormat.yMMMd().format(chosenDateTime) : "No deadline set",
                              style: appTheme.textTheme.bodyText2.copyWith(
                                  color: widget.isDisabled ? Colors.black26 : appTheme.primaryColorLight,
                                  fontWeight: FontWeight.w700)),
                          Padding(
                              padding: EdgeInsets.all(5),
                              child: Icon(Icons.calendar_today, size: 24, color: appTheme.accentColor))
                        ]))),
                ClipPath(
                    clipper: ShapeBorderClipper(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                    child: Container(
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: appTheme.accentColor, width: 1.0))))),
              ])),
          widget.isNotMini
              ? Row(children: [
                  Expanded(
                      child: Row(children: [
                    Text("Include Time"),
                    Switch(
                      value: isWithTime,
                      activeColor: appTheme.accentColor,
                      onChanged: (bool) {
                        setState(() => isWithTime = !isWithTime);
                        widget.callbackForTime(bool);
                      },
                    ),
                  ])),
                  Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: (isWithTime && !widget.isDisabled) ? appTheme.primaryColorLight : Colors.black38,
                              spreadRadius: 1,
                              blurRadius: 1),
                        ],
                      ),
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Text(
                              (chosenDateTime != null ? chosenDateTime.hour.toString().padLeft(2, '0') : "00") +
                                  " : " +
                                  (chosenDateTime != null ? chosenDateTime.minute.toString().padLeft(2, '0') : "00"),
                              style: TextStyle(
                                  color:
                                      (isWithTime && !widget.isDisabled) ? appTheme.primaryColorLight : Colors.black38),
                              textAlign: TextAlign.end)))
                ])
              : Container(
                  width: 70,
                  margin: EdgeInsets.only(top: 15, left: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: (!widget.isDisabled) ? appTheme.primaryColorLight : Colors.black38,
                          spreadRadius: 1,
                          blurRadius: 1),
                    ],
                  ),
                  child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Text(
                          (chosenDateTime != null ? chosenDateTime.hour.toString().padLeft(2, '0') : "00") +
                              " : " +
                              (chosenDateTime != null ? chosenDateTime.minute.toString().padLeft(2, '0') : "00"),
                          style: TextStyle(color: (!widget.isDisabled) ? appTheme.primaryColorLight : Colors.black38),
                          textAlign: TextAlign.center)))
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
          decoration:
              new InputDecoration.collapsed(hintText: 'Type your notes here', hintStyle: appTheme.textTheme.bodyText2),
        )
      ],
    );
  }
}
