import 'dart:io';

import 'package:TimeliNUS/widgets/actionButton.dart';
import 'package:TimeliNUS/widgets/textWithAction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget landingActionGroup(Function() login, Function() register) {
  return Padding(
    padding: EdgeInsets.only(top: 20, left: 20, right: 20),
    child: Column(
      // mainAxisSize: MainAxisSize.max,
      children: [
        textWithAction("Have an account?", "Sign in here", () => login()),
        Padding(padding: EdgeInsets.only(bottom: 10)),
        wideActionButton("Continue with Email", () => register())
      ],
    ),
  );
}
