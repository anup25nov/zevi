import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/sign_in_screen.dart';
import '../features/auth/screens/permissions_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/chat/screens/morning_briefing_screen.dart';
import '../features/upgrade/screens/upgrade_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/screens/subscription_screen.dart';
import '../features/settings/screens/connected_accounts_screen.dart';
import '../features/onboarding/screens/splash_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';

// Simple placeholder widget for unimplemented routes
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Placeholder: $title')),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/permissions',
        builder: (context, state) => const PermissionsScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/briefing',
        builder: (context, state) => const MorningBriefingScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/upgrade',
        builder: (context, state) => const UpgradeScreen(),
      ),
      GoRoute(
        path: '/connected-accounts',
        builder: (context, state) => const ConnectedAccountsScreen(),
      ),
    ],
  );
});
