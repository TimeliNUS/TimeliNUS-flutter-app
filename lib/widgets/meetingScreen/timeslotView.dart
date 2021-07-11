import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class TimeslotView extends StatefulWidget {
  final List<TimeRegion> intervals;
  final DateTime startDate;
  final DateTime endDate;
  final bool isDialog;
  final int meetingLength;
  final Function callback;
  final bool isConfirmed;
  final DateTime selectedDate;
  TimeslotView(this.intervals, this.startDate, this.endDate,
      {this.callback,
      this.isDialog = true,
      this.meetingLength = 120,
      this.isConfirmed = false,
      this.selectedDate,
      Key key})
      : super(key: key);

  @override
  TimeslotViewState createState() => TimeslotViewState();
}

class TimeslotViewState extends State<TimeslotView> {
  DateTime selectedTime;
  @override
  void initState() {
    super.initState();
    print(widget.isConfirmed);
  }

  @override
  Widget build(BuildContext context) {
    final timetable = Column(children: [
      widget.isDialog
          ? ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(appTheme.primaryColorLight)),
              child: Text('Confirm'),
              onPressed: () {
                widget.callback(selectedTime);
                Navigator.pop(context);
              })
          : Container(),
      Expanded(
        child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35)),
            padding: EdgeInsets.all(15),
            child: SfCalendar(
              initialSelectedDate: widget.isConfirmed ? widget.selectedDate : null,
              initialDisplayDate: widget.isConfirmed ? widget.selectedDate : null,
              specialRegions: widget.isConfirmed
                  ? (widget.intervals
                    ..add(TimeRegion(
                        startTime: widget.startDate,
                        endTime: widget.endDate,
                        enablePointerInteraction: false,
                        color: Colors.grey.withOpacity(0))))
                  : widget.intervals,
              timeSlotViewSettings: TimeSlotViewSettings(
                startHour: widget.startDate.minute != 0
                    ? (widget.startDate.hour.toDouble())
                    : widget.startDate.hour.toDouble(),
                endHour:
                    widget.endDate.minute != 0 ? (widget.endDate.hour.toDouble() + 1) : widget.endDate.hour.toDouble(),
                timeInterval: Duration(minutes: widget.meetingLength),
                timeFormat: 'h:mm a',
                timeIntervalHeight: 45,
                // minimumAppointmentDuration: Duration(minutes: 30)
                // timeIntervalHeight: -1,
              ),
              view: CalendarView.week,
              firstDayOfWeek: widget.startDate.weekday,
              maxDate: widget.endDate,
              minDate: widget.startDate,
              onTap: (CalendarTapDetails details) {
                setState(() => selectedTime = details.date);
                print(selectedTime);
              },
            )),
      )
    ]);
    return widget.isDialog
        ? Dialog(
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(35),
            // ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: timetable)
        : timetable;
  }
}
