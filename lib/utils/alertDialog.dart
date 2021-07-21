import 'dart:async';

import 'package:flutter/material.dart';

void customAlertDialog(BuildContext context, {String message}) {
  showDialog(
      context: context,
      builder: (BuildContext popupContext) {
        Timer(Duration(seconds: 1), () => Navigator.pop(popupContext));
        return AlertDialog(content: Text(message ?? 'Not all the fields are filled in!'));
      });
}
