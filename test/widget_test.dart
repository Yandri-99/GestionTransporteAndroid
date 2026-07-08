import 'package:flutter_test/flutter_test.dart';

import 'package:movicore/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MoviCoreApp());
    expect(find.text('MoviCore'), findsOneWidget);
  });
}
