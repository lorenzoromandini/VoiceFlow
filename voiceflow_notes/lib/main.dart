import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voiceflow_notes/core/di/providers.dart';
import 'package:voiceflow_notes/presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  final db = container.read(localDatabaseProvider);
  await db.initialize();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const VoiceFlowApp(),
    ),
  );
}
