import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_crudnote/main.dart';

void main() {
  testWidgets('shows a light loading screen while Firebase initializes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).scaffoldBackgroundColor,
      Colors.white,
    );
  });
}
