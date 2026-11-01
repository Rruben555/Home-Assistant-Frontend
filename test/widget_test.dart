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

  testWidgets('Aplikasi dibuka di layar Masuk', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text('Masuk'), findsWidgets); // judul + tombol
    expect(find.text('Belum punya akun? '), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);
  });

  testWidgets('Login', (tester) async {
    await tester.pumpWidget(buildApp());

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'ven@example.com');
    await tester.enterText(fields.at(1), 'ven12345');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
    await tester.pumpAndSettle(); // melewati jeda simulasi repository
    await tester.tap(find.text('Lanjut ke Beranda')); // layar keluarga sementara
    await tester.pumpAndSettle();

    expect(find.text('Anggota'), findsOneWidget); // label tab
  });
}
