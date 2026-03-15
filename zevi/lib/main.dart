import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env.dev');
  } catch (e) {
    debugPrint('Failed to load .env file: $e');
  }

  runApp(
    const ProviderScope(
      child: ZeviApp(),
    ),
  );
}
