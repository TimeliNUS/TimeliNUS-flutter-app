import 'package:TimeliNUS/widgets/landingScreen/carousel.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/widgetTest_util.dart';

void main() {
  testWidgets('carousel has 3 indicators', (WidgetTester tester) async {
    final testWidget = makeTesteableWidget(child: CarouselWithIndicatorDemo());
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();
    expect(
        find.byWidgetPredicate((Widget widget) => widget is AnimatedContainer),
        findsNWidgets(3));
  });

  testWidgets('carousel init current correctly', (WidgetTester tester) async {
    final testWidget =
        makeTesteableWidget(child: new CarouselWithIndicatorDemo());
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();
    CarouselWithIndicatorState carouselState =
        tester.state(find.byType(CarouselWithIndicatorDemo));
    expect(carouselState.current, 0);
    // await tester.drag(find.byType(CarouselSlider), Offset(-500.0, 0.0));
    // carouselState = tester.state(find.byType(CarouselWithIndicatorDemo));
    // await tester.pumpAndSettle();
    // expect(carouselState.current, 1);
  });
}
