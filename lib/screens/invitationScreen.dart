import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/app/appEvent.dart';
import 'package:TimeliNUS/blocs/screens/invitation/invitationBloc.dart';
import 'package:TimeliNUS/models/meeting.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/repository/meetingRepository.dart';
import 'package:TimeliNUS/utils/alertDialog.dart';
import 'package:TimeliNUS/utils/transitionBuilder.dart';
import 'package:TimeliNUS/widgets/bottomNavigationBar.dart';
import 'package:TimeliNUS/widgets/customCard.dart';
import 'package:TimeliNUS/widgets/invitationDetail.dart';
import 'package:TimeliNUS/widgets/meetingScreen/extraTimeSlotPopup.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/topBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class Invitation extends StatefulWidget {
  static Page page(Map<String, Object> obj) =>
      MaterialPage(child: Invitation(meetingId: obj['id'], isMeeting: obj['isMeeting']));
  final String meetingId;
  final bool isMeeting;
  const Invitation({this.meetingId, this.isMeeting, Key key}) : super(key: key);

  @override
  _InvitationState createState() => _InvitationState();
}

class _InvitationState extends State<Invitation> {
  final _meetingRepository = MeetingRepository();
  String authorName = '';

  @override
  void initState() {
    super.initState();
    // print('Invitation page: ' + widget.meetingId);
  }

  void findAuthorName(Meeting meeting) async {
    if (meeting != null) {
      String tempName = await AuthenticationRepository().findUsersByRef([meeting.author]).then((x) => x[0].name);
      setState(() => authorName = tempName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InvitationBloc>(
        create: (context) => widget.isMeeting
            ? (InvitationBloc(_meetingRepository, context.read<AppBloc>())..add(LoadInvitation(widget.meetingId)))
            : (InvitationBloc(_meetingRepository, context.read<AppBloc>())
              ..add(LoadProjectInvitation(widget.meetingId))),
        child: BlocBuilder<InvitationBloc, InvitationState>(builder: (context, state) {
          widget.isMeeting ? findAuthorName(state.meeting) : null;
          return ColoredSafeArea(
              appTheme.primaryColorLight,
              Scaffold(
                  backgroundColor: appTheme.primaryColorLight,
                  bottomNavigationBar: BottomBar(3),
                  body: Column(
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TopBar(
                          "Accept Meeting Invitation",
                          onPressedCallback: () => context.read<AppBloc>().add(AppOnMeeting()),
                        ),
                        Expanded(
                            child: CustomCard(
                                padding: 30,
                                radius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                                child: ListView(
                                  children: [
                                    Padding(
                                        child: InvitationDetail(state.meeting, authorName,
                                            project: !widget.isMeeting ? state.project : null),
                                        padding: EdgeInsets.all(2)),
                                    widget.isMeeting ? ImportCalendarWidget() : Container(),
                                    !widget.isMeeting
                                        ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                            Container(
                                                padding: EdgeInsets.only(right: 15, top: 15),
                                                child: ElevatedButton(
                                                    child: Text('Accept'),
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty.all(appTheme.primaryColorLight)),
                                                    onPressed: () => context.read<InvitationBloc>().add(
                                                          AcceptProjectInvitation(
                                                              context.read<AppBloc>().state.user.id, true),
                                                        ))),
                                            Container(
                                                padding: EdgeInsets.only(top: 15),
                                                child: ElevatedButton(
                                                    child: Text('Decline'),
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty.all(appTheme.primaryColorLight)),
                                                    onPressed: () => context.read<InvitationBloc>().add(
                                                          AcceptProjectInvitation(
                                                              context.read<AppBloc>().state.user.id, false),
                                                        )))
                                          ])
                                        : Container()
                                  ],
                                )))
                      ])));
        }));
  }
}

class ImportCalendarWidget extends StatefulWidget {
  ImportCalendarWidget({Key key}) : super(key: key);

  @override
  _ImportCalendarWidgetState createState() => _ImportCalendarWidgetState();
}

enum CalendarSource { exist, import }

class _ImportCalendarWidgetState extends State<ImportCalendarWidget> {
  final TextEditingController controller = new TextEditingController();
  final TextEditingController defaultController = new TextEditingController();
  List<Intervals> intervals = [];
  bool isLinked = false;
  bool isUsingGoogle = false;
  bool isUsingNUSMods = false;
  bool isImporting = false;
  CalendarSource selectedCalendarSource = CalendarSource.import;

  @override
  void initState() {
    super.initState();
    setIsLinked();
    if (context.read<AppBloc>().state.user.calendar != null) {
      defaultController.text = context.read<AppBloc>().state.user.calendar;
    }
  }

  void setIsLinked() async {
    String token = await AuthenticationRepository().checkLinkedToGoogle(context.read<AppBloc>().state.user.id);
    setState(() => isLinked = (token != null));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Import Calendar'),
          customPadding(),
          Row(children: [
            Text('NUSMods:'),
            SizedBox(
                width: 35,
                height: 30,
                child: Checkbox(
                    value: isUsingNUSMods, onChanged: (boolean) => setState(() => isUsingNUSMods = !isUsingNUSMods)))
          ]),
          isUsingNUSMods
              ? Column(children: [
                  customPadding(),
                  Row(children: [
                    SizedBox(
                        width: 20,
                        height: 35,
                        child: Radio<CalendarSource>(
                          value: CalendarSource.exist,
                          groupValue: selectedCalendarSource,
                          onChanged: (CalendarSource value) {
                            setState(() {
                              selectedCalendarSource = value;
                            });
                          },
                        )),
                    Padding(padding: EdgeInsets.only(right: 5)),
                    Text('Use existing/default calendar')
                  ]),
                  CalendarImportField(
                    defaultController,
                    isEnabled: false,
                    isImportable: false,
                  ),
                  customPadding(),
                  Row(children: [
                    SizedBox(
                        width: 20,
                        height: 35,
                        child: Radio<CalendarSource>(
                          value: CalendarSource.import,
                          groupValue: selectedCalendarSource,
                          onChanged: (CalendarSource value) {
                            setState(() {
                              selectedCalendarSource = value;
                            });
                          },
                        )),
                    Padding(padding: EdgeInsets.only(right: 5)),
                    Text('Import a new calendar'),
                  ]),
                  // Text(isImportingNewCalendar.toString()),
                  CalendarImportField(controller, callback: () {
                    setState(() {
                      defaultController.text = controller.text;
                      selectedCalendarSource = CalendarSource.exist;
                      controller.text = '';
                      isImporting = true;
                    });
                    customAlertDialog(context, message: "Warning:\nOnly will import as default after confirmation");
                  }),
                ])
              : Container(),
          customPadding(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Google Calendar: '),
              OutlinedButton(
                  style: ButtonStyle(
                      side: MaterialStateProperty.resolveWith(
                          (states) => BorderSide(color: isUsingGoogle ? Colors.grey : appTheme.primaryColorLight))),
                  onPressed: isUsingGoogle
                      ? null
                      : () => isLinked
                          ? setState(() => isUsingGoogle = true)
                          : AuthenticationRepository().linkAccountWithGoogle(),
                  child: Text(
                      isUsingGoogle
                          ? 'Using Linked Google account'
                          : isLinked
                              ? 'Use linked Google account'
                              : 'Login to Google',
                      style: TextStyle(color: isUsingGoogle ? Colors.grey : appTheme.primaryColorLight)))
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Manage Extra Timeslots: '),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => showDialog(
                  context: context,
                  builder: (context) =>
                      ExtraTimeSlotPopup((val) => setState(() => intervals = val), intervals: intervals)),
            ),
          ]),
          Align(
              alignment: Alignment.bottomCenter,
              child: Row(children: [
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith((states) => appTheme.primaryColorLight)),
                    child: Text('Confirm'),
                    onPressed: () {
                      if (isUsingNUSMods &&
                          selectedCalendarSource == CalendarSource.exist &&
                          defaultController.text == '') {
                        customAlertDialog(context,
                            message:
                                "Currently you do not have any existing calendar related to NUSMods for importing!");
                      } else {
                        context.read<InvitationBloc>().add(AcceptInvitation(
                            isUsingNUSMods
                                ? ((selectedCalendarSource == CalendarSource.import)
                                    ? (controller.text)
                                    : defaultController.text)
                                : '',
                            context.read<AppBloc>().state.user.id,
                            intervals,
                            useGoogle: isUsingGoogle));

                        if (isImporting)
                          context.read<AppBloc>().add(AppUserChanged(
                              context.read<AppBloc>().state.user.updateNewCalendar(defaultController.text)));
                        // context.read<AppBloc>().add(AppOnMeeting());

                      }
                    }),
                ElevatedButton(
                  onPressed: () {
                    context.read<InvitationBloc>().add(AcceptInvitation(null, null, null, isAccepted: false));
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith((states) => appTheme.primaryColorLight)),
                  child: Text('Decline'),
                )
              ]))
        ]));
  }
}

class CalendarImportField extends StatefulWidget {
  final TextEditingController controller;
  final bool isEnabled;
  final Function callback;
  final bool isImportable;
  const CalendarImportField(this.controller, {Key key, this.isEnabled = true, this.isImportable = true, this.callback})
      : super(key: key);

  @override
  _CalendarImportFieldState createState() => _CalendarImportFieldState();
}

class _CalendarImportFieldState extends State<CalendarImportField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 45,
        child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
              child: Container(
                  child: TextField(
            enabled: widget.isEnabled,
            controller: widget.controller,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(fontSize: 12, color: widget.isEnabled ? Colors.black : Colors.black45),
            maxLines: 1,
            decoration: InputDecoration(
              isDense: true,
              disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: appTheme.primaryColorLight),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: appTheme.primaryColorLight),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))),
            ),
          ))),
          widget.isImportable
              ? GestureDetector(
                  onTap: widget.isEnabled
                      ? () {
                          // if (widget.controller.text != '') {
                          AuthenticationRepository()
                              .importNewCalendar(widget.controller.text, context.read<AppBloc>().state.user.id);
                          widget.callback();
                          // } else {
                          //   customAlertDialog(context, message: 'Link must not be empty!');
                          // }
                        }
                      : null,
                  child: Container(
                      alignment: Alignment.center,
                      constraints: BoxConstraints(minHeight: double.infinity),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: appTheme.primaryColorLight,
                          borderRadius:
                              BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8))),
                      child: Text('Import\nas default',
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10))))
              : Container()
        ]));
  }
}

Widget customPadding() => Padding(padding: EdgeInsets.only(bottom: 10));
