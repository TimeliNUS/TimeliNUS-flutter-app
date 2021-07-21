import 'package:TimeliNUS/models/meeting.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:flutter/material.dart';

const onlineVenues = ['Zoom', 'Microsoft Teams']; //'Google Meets',

// const offlineVenues = ['Zoom', 'Microsoft Teams']; //'Google Meets',

class MeetingVenueSelect extends StatefulWidget {
  final Function callback;
  final Function boolCallback;
  final String meetingVenue;
  final bool isDisabled;
  final bool isOnline;
  MeetingVenueSelect(this.callback, this.boolCallback, this.meetingVenue,
      {Key key, this.isDisabled = false, this.isOnline = false})
      : super(key: key);

  @override
  _MeetingVenueSelectState createState() => _MeetingVenueSelectState();
}

class _MeetingVenueSelectState extends State<MeetingVenueSelect> {
  bool isOnline;
  TextEditingController controller = new TextEditingController();
  @override
  void initState() {
    super.initState();
    controller.text = widget.meetingVenue;
    isOnline = widget.isOnline;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(
        children: [
          Text('Online'),
          Radio<bool>(
            value: true,
            groupValue: isOnline,
            onChanged: widget.isDisabled
                ? null
                : (bool value) => setState(() {
                      widget.boolCallback(value);
                      isOnline = value;
                      widget.callback(onlineVenues[0]);
                    }),
          ),
          Padding(padding: EdgeInsets.only(right: 30)),
          Text('Offline'),
          Radio<bool>(
            value: false,
            groupValue: isOnline,
            onChanged: widget.isDisabled
                ? null
                : (bool value) => setState(() {
                      isOnline = value;
                      widget.boolCallback(value);
                      widget.callback('');
                    }),
          ),
        ],
      ),
      isOnline
          ? DropdownButton<String>(
              isExpanded: true,
              value: widget.meetingVenue ?? onlineVenues[0],
              onChanged: widget.isDisabled
                  ? null
                  : (String venue) {
                      widget.callback(venue);
                    },
              items: onlineVenues.map((x) => DropdownMenuItem<String>(child: Text(x), value: x)).toList())
          : TextField(
              style: TextStyle(color: widget.isDisabled ? Colors.black26 : Colors.black87, fontSize: 14),
              controller: controller,
              enabled: !widget.isDisabled,
              onChanged: (String venue) => widget.callback(venue)),
    ]);
  }
}
