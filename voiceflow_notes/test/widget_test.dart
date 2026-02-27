import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voiceflow_notes/presentation/app.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: VoiceFlowApp(),
      ),
    );

    // Verify that our app title appears.
    expect(find.text('VoiceFlow Notes - Ready to build'), findsOneWidget);
  });
}
