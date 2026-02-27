import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Database initialization will be added per-platform
  // For now, skip to allow web builds

  runApp(
    const ProviderScope(
      child: VoiceFlowApp(),
    ),
  );
}
