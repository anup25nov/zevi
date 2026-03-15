import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  Future<void> _handleSignInSuccess(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenPermissions = prefs.getBool('has_seen_permissions') ?? false;

    if (context.mounted) {
      if (!hasSeenPermissions) {
        context.go('/permissions');
      } else {
        context.go('/chat');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Listen to auth state changes to trigger navigation or show errors
    ref.listen(authProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.danger,
          ),
        );
      } else if (next.isSignedIn && (previous?.isSignedIn != true)) {
        _handleSignInSuccess(context);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.inkBg,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            
            // Visual
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.violet.withOpacity(0.4),
                        blurRadius: 80,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
                Text(
                  'Z',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 120,
                    color: AppColors.violet,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Ze',
                    style: AppTextStyles.headline(32, color: AppColors.white, weight: FontWeight.w700).copyWith(letterSpacing: -0.04),
                  ),
                  TextSpan(
                    text: 'vi',
                    style: AppTextStyles.headline(32, color: AppColors.violet, weight: FontWeight.w700).copyWith(letterSpacing: -0.04),
                  ),
                ],
              ),
            ),
            
            const Expanded(flex: 2, child: SizedBox()),
            
            Text('Ready in 30 seconds.', style: AppTextStyles.headline(28)),
            const SizedBox(height: 16),
            Text(
              'Sign in with Google. No passwords. No setup.',
              style: AppTextStyles.body(15, color: AppColors.white.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            
            // Privacy Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Symbols.lock_outline, color: AppColors.violet, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Zevi never stores your emails or calendar data.',
                        style: AppTextStyles.label(12, color: AppColors.white.withOpacity(0.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: authState.isLoading ? null : () {
                    ref.read(authProvider.notifier).signIn();
                  },
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.violet,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/google_g.png', width: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Continue with Google',
                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A)),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              'By continuing you agree to our Terms & Privacy Policy',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.white.withOpacity(0.3)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
