import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:TimeliNUS/screens/myHomeScreen.dart';

void main() {
  testWidgets('home page is created', (WidgetTester tester) async {
    final testWidget = MaterialApp(
      home: MyHomeScreen('Flutter Demo Home Page'),
    );

    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();
  });
}
