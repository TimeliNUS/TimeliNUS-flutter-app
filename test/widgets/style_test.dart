import 'package:TimeliNUS/widgets/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/widgetTest_util.dart';

void main() {
  test('Generate correct Color instance from hex', () async {
    expect(Color.fromARGB(255, 0, 0, 0), HexColor.fromHex('#000000'));
    expect(Color.fromARGB(255, 255, 255, 255), HexColor.fromHex('#FFFFFF'));
  });

  test('Correct theme colors', () async {
    expect(ThemeColor.lightGrey, Color.fromARGB(255, 241, 241, 241));
    expect(ThemeColor.grey, Color.fromARGB(255, 171, 171, 171));
  });

  test('Correct textstyle', () async {
    expect(ThemeTextStyle.defaultText.color, Colors.black54);
    expect(ThemeTextStyle.defaultText.fontSize, 12);
  });

  testWidgets('ColoredSafeArea takes in child and set colour correctly', (WidgetTester tester) async {
    final testWidget = makeTesteableWidget(child: new ColoredSafeArea(Colors.orange, Text('testString')));
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();
    expect(find.byType(Text), findsOneWidget);
    expect((tester.firstWidget(find.byType(Container)) as Container).color, Colors.orange);
  });
}
