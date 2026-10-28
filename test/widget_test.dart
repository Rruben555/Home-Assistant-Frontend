// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:home_assistant_frontend/app/app.dart';
import 'package:home_assistant_frontend/app/di/injection.dart';

void main() {
  Widget buildApp() => HouseChoreApp(dependencies: Injection.build());

  testWidgets('Aplikasi dibuka di Beranda', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text('Beranda'), findsOneWidget);
  });
}
