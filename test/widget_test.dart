import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_crudnote/main.dart';

void main() {
  testWidgets('shows a light loading screen while Firebase initializes', (
    WidgetTester tester,
  ) async {
    final initialization = Completer<FirebaseApp>();
    await tester.pumpWidget(
      MyApp(firebaseInitialization: initialization.future),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      Colors.white,
    );
  });

  testWidgets(
    'shows Firebase initialization errors instead of a blank screen',
    (WidgetTester tester) async {
      final initialization = Completer<FirebaseApp>();
      await tester.pumpWidget(
        MyApp(firebaseInitialization: initialization.future),
      );

      initialization.completeError(StateError('Firebase init failed'));
      await tester.pump();

      expect(
        find.text(
          'Firebase could not be initialized.\nBad state: Firebase init failed',
        ),
        findsOneWidget,
      );
    },
  );
}
