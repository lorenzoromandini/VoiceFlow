import 'package:flutter_riverpod/flutter_riverpod.dart';

final isLoadingProvider = StateProvider<bool>((ref) => false);

final loadingNotesProvider = StateProvider<bool>((ref) => false);
final loadingNoteProvider = StateProvider.family<bool, String>(
  (ref, id) => false,
);
