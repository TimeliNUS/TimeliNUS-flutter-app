import 'package:TimeliNUS/main.dart';
import 'package:TimeliNUS/screens/landingScreen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App created with LandingScreen as initial screen',
      (WidgetTester tester) async {
    final testWidget = App(
      authenticationRepository: null,
    );
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();
    expect(find.byType(LandingScreen), findsOneWidget);
  });
}
