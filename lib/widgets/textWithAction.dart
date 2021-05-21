import 'package:TimeliNUS/widgets/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget textWithAction(String description, String actionText, tapAction) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(description, style: TextStyle(color: Colors.black54, fontSize: 12)),
      new InkWell(
          onTap: () => tapAction(),
          child: new Padding(
            padding: new EdgeInsets.all(10.0),
            child: new Text(actionText,
                style: ThemeTextStyle.defaultText
                    .apply(decoration: TextDecoration.underline)),
          ))
    ],
  );
}
