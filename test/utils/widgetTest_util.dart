import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget makeTesteableWidget({Widget child}) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}
