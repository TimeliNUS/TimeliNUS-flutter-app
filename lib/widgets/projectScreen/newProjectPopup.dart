import 'dart:ui';

import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/screens/project/projectBloc.dart';
import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/widgets/overlayPopup.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/topBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:TimeliNUS/utils/dateTimeExtension.dart';

class NewProjectPopup extends StatefulWidget {
  final ProjectBloc projectBloc;
  const NewProjectPopup(this.projectBloc);
  @override
  State<NewProjectPopup> createState() => _NewProjectPopupState();
}

class _NewProjectPopupState extends State<NewProjectPopup> {
  List<User> groupmates = [];
  DateTime deadlineValue = DateTime.now().stripTime();
  final TextEditingController textController = new TextEditingController();
  final TextEditingController moduleCodeController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (groupmates.isEmpty) {
      groupmates.add(context.select((AppBloc bloc) => bloc.state.user));
    }
    // final projectBloc =
    //     ProjectBloc(projectRepository: context.read<ProjectRepository>());
    return BlocProvider<ProjectBloc>(
        create: (context) => widget.projectBloc,
        child: ColoredSafeArea(
            appTheme.primaryColorLight,
            Scaffold(
                body: Container(
                    color: appTheme.primaryColorLight,
                    child: Column(children: [
                      TopBar(
                        "Create Project",
                        onPressedCallback: () => Navigator.pop(context),
                      ),
                      Expanded(
                          child: GestureDetector(
                              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(40.0), topLeft: Radius.circular(40.0))),
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 30, right: 30, top: 15),
                                      child: ListView(
                                        children: [
                                          // TopBar(),
                                          PopupInput(textController,
                                              inputLabel: 'Project Title',
                                              errorMsg: 'Please enter your project title!'),
                                          customPadding(),
                                          PopupInput(moduleCodeController,
                                              inputLabel: 'Module Code', errorMsg: 'Please enter your module code!'),
                                          customPadding(),
                                          PersonInChargeChips(groupmates, "Groupmates", callback: (val) {
                                            setState(() => groupmates = val);
                                          }),
                                          customPadding(),
                                          // constraints: BoxConstraints.expand(height: 200)),
                                          DeadlineInput((val) => setState(() => deadlineValue = val), false),
                                        ],
                                      ))))),
                      Container(
                        color: Colors.white,
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // ElevatedButton(
                                //     style: ButtonStyle(
                                //         backgroundColor:
                                //             MaterialStateProperty.all<Color>(
                                //                 appTheme.primaryColorLight)),
                                //     child: Padding(
                                //         padding: EdgeInsets.symmetric(
                                //             horizontal: 10),
                                //         child: Text("Add & Next",
                                //             style: appTheme.textTheme.bodyText2
                                //                 .apply(color: Colors.white))),
                                //     onPressed: () {
                                //       Navigator.pop(context);
                                //     }),
                                ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(appTheme.primaryColorLight)),
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: Text("Done",
                                            style: appTheme.textTheme.bodyText2.apply(color: Colors.white))),
                                    onPressed: () {
                                      widget.projectBloc.add(AddProject(
                                          Project(
                                            textController.text,
                                            moduleCode: moduleCodeController.text,
                                            deadline: deadlineValue,
                                            groupmates: groupmates,
                                          ),
                                          context.read<AppBloc>().getCurrentUser().id));
                                      Navigator.pop(context);
                                    })
                              ],
                            )),
                      )
                    ])))));
  }
}

Widget customPadding() => Padding(padding: EdgeInsets.only(bottom: 40));
