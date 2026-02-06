import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:student_assistant/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StudentAssistantApp());

    // Verify that the app loads without errors
    await tester.pumpAndSettle();

    // App should have MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
