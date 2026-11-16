import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsi/screens/auth_screen.dart';
import 'package:responsi/models/berita.dart';

void main() {
  testWidgets('login screen can switch to registration', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: AuthScreen(onLogin: () {})));

    expect(find.text('Berita Luar Angkasa'), findsOneWidget);
    await tester.tap(find.text('Belum punya akun? Register'));
    await tester.pumpAndSettle();

    expect(find.text('Buat Akun'), findsOneWidget);
    expect(find.text('DAFTAR'), findsOneWidget);
  });
}
