import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.mic,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // App name
              Text(
                'VoiceFlow',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tagline
              Text(
                'Speak naturally.\nCapture instantly.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Description
              Text(
                'Create notes with your voice.\n'
                'Access them anywhere when you sign in.\n'
                'Or use locally without an account.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              
              const Spacer(),
              
              // Start without auth button (primary action)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.mic),
                  label: const Text('Start Using VoiceFlow'),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or sign in to sync',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Sign in button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to login (Phase 11)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Login coming in Phase 11'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In'),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Register button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    // TODO: Navigate to register (Phase 11)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Registration coming in Phase 11'),
                      ),
                    );
                  },
                  child: const Text('Create Account'),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
