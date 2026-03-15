import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Set transparent status bar with light text/icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Fade-in animation (600ms)
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // 2200ms delay then redirect based on auth token
    Future.delayed(const Duration(milliseconds: 2200), () async {
      final prefs = await SharedPreferences.getInstance();
      final hasToken = prefs.containsKey('auth_token');

      if (mounted) {
        if (hasToken) {
          context.go('/chat');
        } else {
          context.go('/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.inkBg,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Violet Glow Effect behind the wordmark
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.violet.withValues(alpha: 0.15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.violet.withValues(alpha: 0.4),
                          blurRadius: 80,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),

                  // 'Zevi' Wordmark
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Ze',
                          style: AppTextStyles.headline(42,
                                  color: AppColors.white,
                                  weight: FontWeight.w700)
                              .copyWith(letterSpacing: -0.04),
                        ),
                        TextSpan(
                          text: 'vi',
                          style: AppTextStyles.headline(42,
                                  color: AppColors.violet,
                                  weight: FontWeight.w700)
                              .copyWith(letterSpacing: -0.04),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Tagline
              Text(
                'Your AI. No setup.',
                style: AppTextStyles.body(14,
                    color: AppColors.white.withValues(alpha: 0.4),
                    weight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
