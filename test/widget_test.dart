import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:foodshare/main.dart';
import 'package:foodshare/providers/app_providers.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Obtain SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // Build the app with MultiProvider
    await tester.pumpWidget(
      MultiProvider(
        providers: AppProviders.providers,
        child: LeftoverFoodShareApp(prefs: prefs),
      ),
    );


    // For now, this test assumes there's a Text widget showing '0' and a '+' icon

    // Verify initial state
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Simulate a tap on the '+' icon
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify incremented state
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
