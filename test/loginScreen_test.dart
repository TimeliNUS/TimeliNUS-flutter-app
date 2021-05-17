import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:TimeliNUS/screens/loginScreen.dart';
import 'package:provider/provider.dart';

class MockAPI {
  Future<FirebaseApp> getFirebase() {
    return Future.value(Firebase.initializeApp());
  }
}

void main() {
  testWidgets('login page is created', (WidgetTester tester) async {
    final testWidget = MaterialApp(
      home: LoginScreen(),
    );

    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();
    final titleFinder = find.text('Register');
    expect(titleFinder, findsOneWidget);
  });

  testWidgets('user name input is found', (WidgetTester tester) async {
    final testWidget = MaterialApp(
      home: LoginScreen(),
    );
    await tester.pumpWidget(testWidget);
    expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is TextField && widget.key == Key('Email'),
        ),
        findsOneWidget);
  });

  // testWidgets('user name input is bounded to a variable',
  //     (WidgetTester tester) async {
  //   final testWidget = MaterialApp(
  //     home: LoginScreen(),
  //   );
  //   await tester.pumpWidget(testWidget);
  //   await tester.enterText(
  //       find.byWidgetPredicate(
  //         (Widget widget) => widget is TextField && widget.key == Key('Email'),
  //       ),
  //       'hi');
  //   expect(
  //       find.byWidgetPredicate(
  //         (Widget widget) => widget is TextField && widget.key == Key('Email'),
  //       ),
  //       findsOneWidget);
  // });

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
