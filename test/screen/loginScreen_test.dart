import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:TimeliNUS/screens/landingScreen.dart';
import 'package:provider/provider.dart';

void main() {
  // testWidgets('login page is created', (WidgetTester tester) async {
  //   final testWidget = MaterialApp(
  //     home: LandingScreen(),
  //   );

  //   await tester.pumpWidget(testWidget);
  //   await tester.pumpAndSettle();
  //   final titleFinder = find.text('Register');
  //   expect(titleFinder, findsOneWidget);
  // });

  // testWidgets('user name input is found', (WidgetTester tester) async {
  //   final testWidget = MaterialApp(
  //     home: LandingScreen(),
  //   );
  //   await tester.pumpWidget(testWidget);
  //   expect(
  //       find.byWidgetPredicate(
  //         (Widget widget) => widget is TextField && widget.key == Key('Email'),
  //       ),
  //       findsOneWidget);
  // });

  // testWidgets('password input is found', (WidgetTester tester) async {
  //   final testWidget = MaterialApp(
  //     home: LandingScreen(),
  //   );
  //   await tester.pumpWidget(testWidget);
  //   expect(
  //       find.byWidgetPredicate((Widget widget) =>
  //           widget is TextField &&
  //           widget.key == Key('Password') &&
  //           widget.obscureText),
  //       findsOneWidget);
  // });

  testWidgets('carousel is found', (WidgetTester tester) async {
    // expect(true, true);
    final testWidget = MaterialApp(
      home: LandingScreen(),
    );
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();
    expect(find.byWidgetPredicate((Widget widget) => widget is CarouselSlider),
        findsOneWidget);
  });
}
