import 'package:flutter_test/flutter_test.dart';

import 'package:keepcalm/main.dart';

void main() {
  testWidgets('KeepCalm app loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const KeepCalmApp());

    expect(find.text('KeepCalm'), findsOneWidget);
    expect(find.text('How are you feeling today?'), findsOneWidget);
    expect(find.text('Start Daily Calm Check'), findsOneWidget);
  });
}