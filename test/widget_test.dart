// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

import 'package:barangay_meter_reader/main.dart';
import 'package:barangay_meter_reader/presentation/splash_screen/splash_screen.dart';

void main() {
  testWidgets('Splash screen displays correctly', (WidgetTester tester) async {
    // Build the splash screen and trigger a frame.
    await tester.pumpWidget(Sizer(
      builder: (context, orientation, deviceType) =>
          const MaterialApp(home: SplashScreen()),
    ));

    // Verify that the splash screen is displayed.
    expect(find.text('Barangay Meter Reader'), findsOneWidget);
    expect(find.text('Utility Management System'), findsOneWidget);

    // Wait for initialization to complete
    await tester.pump(const Duration(milliseconds: 300));
  });
}
