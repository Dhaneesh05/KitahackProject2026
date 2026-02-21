import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hydrovision_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HydroVisionApp());

    // Verify that the Flood Forecast title is present.
    expect(find.text('Flood Forecast'), findsOneWidget);
    
    // Verify that the Report Drain FAB is present.
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
