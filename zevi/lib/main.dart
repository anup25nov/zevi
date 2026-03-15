import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env.dev');
  } catch (e) {
    debugPrint('Failed to load .env file: $e');
  }

  // Stripe MUST be initialized before runApp on web.
  // Falls back to a placeholder key if not configured — keeps app functional.
  Stripe.publishableKey = dotenv.env['STRIPE_KEY']?.isNotEmpty == true
      ? dotenv.env['STRIPE_KEY']!
      : 'pk_test_placeholder_zevi_dev';

  runApp(
    const ProviderScope(
      child: ZeviApp(),
    ),
  );
}
