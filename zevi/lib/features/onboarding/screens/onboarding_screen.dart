import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.inkBg,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              physics: const ClampingScrollPhysics(),
              onPageChanged: _onPageChanged,
              children: [
                _Slide1(pageController: _pageController),
                _Slide2(pageController: _pageController),
                const _Slide3(),
              ],
            ),
            
            // Fixed Page Indicator
            Positioned(
              left: 0,
              right: 0,
              bottom: 124, 
              child: _DotIndicator(currentPage: _currentPage),
            ),

            // Top right skip button
            Positioned(
              top: 8,
              right: 16,
              child: TextButton(
                onPressed: () => context.go('/sign-in'),
                child: Text(
                  'Skip',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: AppColors.white.withOpacity(0.35),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final int currentPage;

  const _DotIndicator({required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.violet : AppColors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ==========================================
// Slide 1: Tell it what to do.
// ==========================================
class _Slide1 extends StatelessWidget {
  final PageController pageController;

  const _Slide1({required this.pageController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        
        // Visual (Stacked rotating cards)
        SizedBox(
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: -0.14,
                child: const _ActionCard('Meeting scheduled', offset: Offset(-30, 10)),
              ),
              Transform.rotate(
                angle: 0.10,
                child: const _ActionCard('Reminder set', offset: Offset(30, -10)),
              ),
              const _ActionCard('Email sent', offset: Offset.zero),
            ],
          ),
        ),
        
        const Expanded(flex: 2, child: SizedBox()),
        
        Text('Tell it what to do.', style: AppTextStyles.headline(28)),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Zevi handles your calendar, emails, reminders — all from one chat.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(15, color: AppColors.white.withOpacity(0.5)),
          ),
        ),
        
        const SizedBox(height: 80), // Space for dot indicator
        
        // Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.violet,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(
                'Get started',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        GestureDetector(
          onTap: () => context.go('/sign-in'),
          child: RichText(
            text: TextSpan(
              text: 'Already have an account? ',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.white.withOpacity(0.35)),
              children: [
                TextSpan(
                  text: 'Sign in',
                  style: GoogleFonts.inter(decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String label;
  final Offset offset;

  const _ActionCard(this.label, {required this.offset});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.violet.withOpacity(0.5), width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.bolt, color: AppColors.violet, size: 14),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.label(11, color: AppColors.white)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// Slide 2: One message. Real actions.
// ==========================================
class _Slide2 extends StatelessWidget {
  final PageController pageController;

  const _Slide2({required this.pageController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        
        // Visual (Chat mockup)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: const BoxDecoration(
                    color: AppColors.violet,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    'Schedule lunch with Rahul tomorrow 1pm',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.violet.withOpacity(0.25), width: 0.5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Done. Rahul confirmed for 1pm. Calendar updated.',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFE8E3FF)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Symbols.check_circle, fill: 1.0, color: AppColors.success, size: 16),
                  const SizedBox(width: 4),
                  Text('Action completed', style: AppTextStyles.label(10, color: AppColors.success)),
                ],
              ),
            ],
          ),
        ),
        
        const Expanded(flex: 2, child: SizedBox()),
        
        Text('One message. Real actions.', style: AppTextStyles.headline(28)),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Zevi doesn\'t just answer. It connects to your calendar, Gmail, maps, and more to actually get things done.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(15, color: AppColors.white.withOpacity(0.5)),
          ),
        ),
        
        const SizedBox(height: 80), // Space for dot indicator
        
        // Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.violet,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(
                'Next →',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 48), // Padding equivalent to bottom login
      ],
    );
  }
}

// ==========================================
// Slide 3: Ready in 30 seconds.
// ==========================================
class _Slide3 extends StatelessWidget {
  const _Slide3();

  @override
  Widget build(BuildContext context) {
    return Column(
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
        
        const SizedBox(height: 32), // Space for dot indicator (visual alignment)
        
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
              onPressed: () => context.go('/sign-in'),
              child: Row(
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
    );
  }
}
