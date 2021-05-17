import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:TimeliNUS/screens/myHomePage.dart';

void main() {
  testWidgets('login page is created', (WidgetTester tester) async {
    final testWidget = MaterialApp(
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );

    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();
  });
}
