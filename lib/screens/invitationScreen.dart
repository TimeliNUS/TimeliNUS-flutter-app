import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/app/appEvent.dart';
import 'package:TimeliNUS/blocs/screens/invitation/invitationBloc.dart';
import 'package:TimeliNUS/models/meeting.dart';
import 'package:TimeliNUS/repository/meetingRepository.dart';
import 'package:TimeliNUS/widgets/bottomNavigationBar.dart';
import 'package:TimeliNUS/widgets/customCard.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/topBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class Invitation extends StatefulWidget {
  static Page page(String id) => MaterialPage(child: Invitation(meetingId: id));
  final String meetingId;
  const Invitation({this.meetingId, Key key}) : super(key: key);

  @override
  _InvitationState createState() => _InvitationState();
}

class _InvitationState extends State<Invitation> {
  final _meetingRepository = MeetingRepository();
  @override
  void initState() {
    super.initState();
    print('Invitation page: ' + widget.meetingId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InvitationBloc>(
        create: (context) => InvitationBloc(_meetingRepository)
          ..add(LoadInvitation(widget.meetingId)),
        child: BlocBuilder<InvitationBloc, InvitationState>(
            builder: (context, state) {
          return ColoredSafeArea(
              appTheme.primaryColorLight,
              Scaffold(
                  backgroundColor: appTheme.primaryColorLight,
                  bottomNavigationBar: BottomBar(3),
                  body: Column(
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TopBar(() => Navigator.pop(context),
                            "Accept Meeting Invitation"),
                        Expanded(
                            child: CustomCard(
                                padding: 30,
                                radius: BorderRadius.only(
                                    topLeft: Radius.circular(40),
                                    topRight: Radius.circular(40)),
                                child: ListView(
                                  children: [
                                    InvitationDetail(state.meeting),
                                    ImportCalendarWidget()
                                  ],
                                )))
                      ])));
        }));
  }
}

class InvitationDetail extends StatelessWidget {
  final Meeting meeting;
  const InvitationDetail(this.meeting, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                  color: appTheme.primaryColor,
                  spreadRadius: 0.5,
                  blurRadius: 0.5)
            ],
            color: Colors.white),
        child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meeting.title ?? ''),
                customPadding(),
                Text(meeting.project != null ? meeting.project.title : ''),
                customPadding(),
                Divider(
                  color: appTheme.primaryColorLight,
                  thickness: 1.25,
                ),
                customPadding(),
                Text('Meeting created by: '),
                customPadding(),
                Text('Meeting is within:'),
                customPadding(),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18, color: appTheme.primaryColorLight),
                    Text(' ' +
                        DateFormat('MMM dd, yyyy').format(meeting.startDate) +
                        ' - ' +
                        DateFormat('MMM dd, yyyy').format(meeting.endDate))
                  ],
                ),
                Padding(padding: EdgeInsets.only(bottom: 7.5)),
                Row(
                  children: [
                    Icon(Icons.av_timer_rounded,
                        size: 18, color: appTheme.primaryColorLight),
                    Text(' ' +
                        DateFormat('kk:mm').format(meeting.startDate) +
                        ' - ' +
                        DateFormat('kk:mm').format(meeting.endDate)),
                  ],
                ),
                Padding(padding: EdgeInsets.only(bottom: 7.5)),
                Row(
                  children: [
                    Icon(Icons.location_pin,
                        size: 18, color: appTheme.primaryColorLight),
                    Text(' ' + meeting.meetingVenue.toString().split('.')[1]),
                  ],
                )
              ],
            )));
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
  CalendarSource selectedCalendarSource = CalendarSource.import;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Import Calendar'),
          customPadding(),
          Text('NUSMods:'),
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
            Text('Use existing/default calendar')
          ]),
          CalendarImportField(null),
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
            Text('Import a new calendar'),
          ]),
          CalendarImportField(controller),
          customPadding(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Google Calendar: '),
              OutlinedButton(
                  style: ButtonStyle(
                      side: MaterialStateProperty.resolveWith((states) =>
                          BorderSide(color: appTheme.primaryColorLight))),
                  onPressed: () => {},
                  child: Text('Login to Google',
                      style: TextStyle(color: appTheme.primaryColorLight)))
            ],
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                          (states) => appTheme.primaryColorLight)),
                  child: Text('Done'),
                  onPressed: () {
                    context
                        .read<InvitationBloc>()
                        .add(AcceptInvitation(controller.text));
                    context.read<AppBloc>().add(AppOnMeeting());
                  }))
        ]));
  }
}

class CalendarImportField extends StatefulWidget {
  final TextEditingController controller;
  const CalendarImportField(this.controller, {Key key}) : super(key: key);

  @override
  _CalendarImportFieldState createState() => _CalendarImportFieldState();
}

class _CalendarImportFieldState extends State<CalendarImportField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 45,
        child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Container(
                      child: TextField(
                controller: widget.controller,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(fontSize: 12),
                maxLines: 1,
                decoration: InputDecoration(
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: appTheme.primaryColorLight),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: appTheme.primaryColorLight),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8))),
                ),
              ))),
              Container(
                  alignment: Alignment.center,
                  constraints: BoxConstraints(minHeight: double.infinity),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: appTheme.primaryColorLight,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8))),
                  child: Text('Paste',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white)))
            ]));
  }
}

Widget customPadding() => Padding(padding: EdgeInsets.only(bottom: 10));
