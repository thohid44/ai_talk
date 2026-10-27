import 'package:ai_talk_test/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('launch shows the splash instead of a blank screen', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('AI Talk'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
