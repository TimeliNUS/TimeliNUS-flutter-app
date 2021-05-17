import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:TimeliNUS/screens/loginScreen.dart';

void main() {
  testWidgets('login page is created', (WidgetTester tester) async {
    final testWidget = MaterialApp(
      home: LoginScreen(),
    );

    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();
    final titleFinder = find.text('Login');
    expect(titleFinder, findsOneWidget);
  });

  testWidgets('user name input is found', (WidgetTester tester) async {
    final testWidget = MaterialApp(
      home: LoginScreen(),
    );
    await tester.pumpWidget(testWidget);
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is TextField && widget.key == Key('Username'),
        ),
        findsOneWidget);
  });

  testWidgets('password input is found', (WidgetTester tester) async {
    final testWidget = MaterialApp(
      home: LoginScreen(),
    );
    await tester.pumpWidget(testWidget);
    expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is TextField &&
            widget.key == Key('Password') &&
            widget.obscureText),
        findsOneWidget);
  });
}
