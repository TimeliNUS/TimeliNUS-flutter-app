import 'package:TimeliNUS/models/meeting.dart';
import 'package:TimeliNUS/utils/alertDialog.dart';
import 'package:TimeliNUS/widgets/overlayPopup.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:flutter/material.dart';
import 'package:TimeliNUS/utils/dateTimeExtension.dart';
import 'package:intl/intl.dart';

class ExtraTimeSlotPopup extends StatefulWidget {
  final List<Intervals> intervals;
  final Function callback;
  const ExtraTimeSlotPopup(this.callback, {this.intervals = const []});
  @override
  ExtraTimeSlotPopupState createState() => ExtraTimeSlotPopupState();
}

class ExtraTimeSlotPopupState extends State<ExtraTimeSlotPopup> {
  List<Intervals> intervals = [];
  DateTime start = DateTime.now().stripTime();
  DateTime end = DateTime.now().stripTime();
  @override
  void initState() {
    super.initState();
    intervals = widget.intervals;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Container(
            padding: EdgeInsets.all(25),
            child: Stack(children: [
              Positioned(
                  right: -15,
                  top: -13,
                  child: IconButton(
                    icon: Icon(Icons.close, size: 16),
                    onPressed: () => Navigator.pop(context),
                  )),
              Padding(
                  padding: EdgeInsets.all(2),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('Add extra unavailable timeslot'),
                    Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.end, children: [
                      SizedBox(
                          width: 50,
                          height: 28,
                          child: Text(
                            'From:',
                          )),
                      Expanded(
                          child: DeadlineInput(
                        (val) => setState(() => start = val),
                        false,
                        true,
                        isNotMini: false,
                      )),
                    ]),
                    Row(
                      children: [
                        SizedBox(
                            width: 50,
                            height: 14,
                            child: Text(
                              'to:',
                            )),
                        Expanded(
                            child: DeadlineInput(
                          (val) => setState(() => end = val),
                          false,
                          true,
                          isNotMini: false,
                        )),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(top: 10)),
                    ElevatedButton(
                      child: Text('Add'),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(appTheme.primaryColorLight),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)))),
                      onPressed: () {
                        bool isAtSameMoment =
                            intervals.any((x) => (x.start.isAtSameMomentAs(start) && x.end.isAtSameMomentAs(end)));
                        if (start.isBefore(end) || !isAtSameMoment) {
                          setState(() => intervals = [(new Intervals(start, end))]..addAll(intervals));
                        } else {
                          customAlertDialog(context,
                              message: isAtSameMoment
                                  ? 'current extra unavailable timeslot is same with existing one!'
                                  : 'Start date must be after end date!');
                        }
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                    ),
                    ExtraTimeslotList(
                      (val) => setState(() => intervals = intervals.where((x) => x != val).toList()),
                      intervals: intervals,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                    ),
                    ElevatedButton(
                      child: Text('Confirm'),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(appTheme.primaryColorLight),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)))),
                      onPressed: () {
                        widget.callback(intervals);
                        Navigator.pop(context);
                      },
                    ),
                  ]))
            ])));
  }
}

class ExtraTimeslotList extends StatelessWidget {
  final Function callback;
  final List<Intervals> intervals;
  const ExtraTimeslotList(this.callback, {this.intervals = const [], Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: intervals.length != 0
          ? intervals
              .map((x) => Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => callback(x),
                      ),
                      Text(' From ' + DateFormat('HH:mm M/d').format(x.start)),
                      Text(' to ' + DateFormat('HH:mm M/d').format(x.end)),
                    ],
                  ))
              .toList()
          : [
              Text('No extra timeslots currently added',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                  ))
            ],
    );
  }
}
