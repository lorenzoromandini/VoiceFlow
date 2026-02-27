import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension NavigationExtensions on GoRouter {
  void goHome() => go('/');
  void goNoteNew() => go('/note/new');
  void goNoteEdit(String id) => go('/note/$id');
  void goSettings() => go('/settings');
  void goAbout() => go('/about');
}

extension BuildContextNavigation on BuildContext {
  void popSafely() {
    if (canPop()) pop();
  }
}
