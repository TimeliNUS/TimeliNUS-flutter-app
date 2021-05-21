import 'package:TimeliNUS/screens/landingScreen.dart';
import 'package:TimeliNUS/widgets/registerGroup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/widgetTest_util.dart';

void main() {
  testWidgets('toggling checkbox changes state', (WidgetTester tester) async {
    // expect(true, true);
    final testWidget =
        makeTesteableWidget(child: RegisterGroup(AuthenticationAction.login));
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();
    RegisterGroupState registerGroupState =
        tester.state(find.byType(RegisterGroup));
    expect(registerGroupState.isRemembered, false);
    await tester.tap(find.byType(Checkbox));
    expect(registerGroupState.isRemembered, true);
  });

  testWidgets('clicking "Remember me" changes state',
      (WidgetTester tester) async {
    // expect(true, true);
    final testWidget =
        makeTesteableWidget(child: RegisterGroup(AuthenticationAction.login));
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();
    RegisterGroupState registerGroupState =
        tester.state(find.byType(RegisterGroup));
    expect(registerGroupState.isRemembered, false);
    final test = tester
        .element(find.text("Remember me"))
        .findAncestorWidgetOfExactType<InkWell>();
    await tester.tap(find.byWidget(test));
    expect(registerGroupState.isRemembered, true);
  });
}
