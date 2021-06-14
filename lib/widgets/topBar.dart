import 'package:TimeliNUS/widgets/style.dart';
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final Function() onPressedCallback;
  final String title;
  final String subtitle;
  final Widget rightWidget;
  const TopBar(this.onPressedCallback, this.title,
      {this.subtitle, this.rightWidget});
  @override
  Widget build(BuildContext context) {
    return Container(
        color: appTheme.primaryColorLight,
        child: Padding(
            padding: EdgeInsets.only(left: 25, right: 25, bottom: 15),
            child: Row(children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: onPressedCallback,
              ),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(this.title,
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                    this.subtitle != null
                        ? Text(this.subtitle,
                            style: TextStyle(color: Colors.white, fontSize: 16))
                        : Container()
                  ])),
              rightWidget ?? Container()
            ])));
  }
}
