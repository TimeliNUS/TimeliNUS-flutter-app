import 'package:TimeliNUS/widgets/carousel.dart';
import 'package:TimeliNUS/widgets/formInput.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/widgetTest_util.dart';

void main() {
  testWidgets('email input has correct hinted text',
      (WidgetTester tester) async {
    final TextEditingController _emailController = new TextEditingController();
    final testWidget =
        makeTesteableWidget(child: getEmailInput(_emailController));
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();
    expect(find.byKey(Key('Email')), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
  });

  testWidgets('password input has correct hinted text',
      (WidgetTester tester) async {
    final TextEditingController _passwordController =
        new TextEditingController();
    final testWidget =
        makeTesteableWidget(child: getPasswordInput(_passwordController));
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();
    expect(find.byKey(Key('Password')), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
  // testWidgets('password input', (WidgetTester tester) async {
  //   final testWidget =
  //       makeTesteableWidget(child: new CarouselWithIndicatorDemo());
  //   await tester.pumpWidget(testWidget);
  //   await tester.pumpAndSettle();
  //   CarouselWithIndicatorState carouselState =
  //       tester.state(find.byType(CarouselWithIndicatorDemo));
  //   expect(carouselState.current, 0);
  //   ;
  // });
}
