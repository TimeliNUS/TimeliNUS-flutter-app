import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter/widgets.dart';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class ThemeColor {
  static final lightGrey = HexColor.fromHex('#F1F1F1');
  static final grey = HexColor.fromHex('#ABABAB');
}

class ThemeTextStyle {
  static final defaultText = TextStyle(color: Colors.black54, fontSize: 12);
}

ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: HexColor.fromHex('#FF7200'),
  fontFamily: "DMSans",
  textTheme: TextTheme(
    headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
    headline6: TextStyle(
        fontSize: 40.0, fontFamily: "DMSans", fontWeight: FontWeight.w700),
    bodyText1: TextStyle(color: Colors.black54, fontSize: 12),
  ),
);
