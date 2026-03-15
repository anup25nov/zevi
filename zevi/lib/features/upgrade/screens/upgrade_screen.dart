import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/subscription_provider.dart';

class UpgradeScreen extends ConsumerWidget {
  const UpgradeScreen({super.key});

  static const _features = [
    'Unlimited messages',
    'Email drafting',
    'Document creation',
    'Unlimited web search',
    'All Google integrations',
    'Voice input',
    'Morning briefing',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subState = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: AppColors.inkBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 8),
                child: IconButton(
                  icon: const Icon(Symbols.close,
                      color: AppColors.onSurfaceVariant, size: 24),
                  onPressed: () => context.pop(),
                ),
              ),
            ),

            // ── Body ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Crown icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLow,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.violet.withOpacity(0.2),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Symbols.crown,
                            color: AppColors.violet, size: 30, fill: 1),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Upgrade to Zevi Pro',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "You've used all 50 free messages this month.",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Pro Plan Card ──
                    _ProPlanCard(isLoading: subState.isLoading, ref: ref),
                    const SizedBox(height: 16),

                    // ── Free Tier Comparison ──
                    _FreeTierComparison(state: subState),
                    const SizedBox(height: 20),

                    // Footer text
                    Text(
                      'Then ₹99/month · Cancel anytime',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: AppColors.outline,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment logos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _PaymentLogo('UPI'),
                        const SizedBox(width: 20),
                        _PaymentLogo('Visa'),
                        const SizedBox(width: 20),
                        _PaymentLogo('Mastercard'),
                        const SizedBox(width: 20),
                        _PaymentLogo('RuPay'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Terms
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        "By starting your trial, you agree to Zevi's Terms of Service. Auto-renews at ₹99/mo after 7 days unless cancelled.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant.withOpacity(0.6),
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// Pro Plan Card
// ═══════════════════════════════════════════
class _ProPlanCard extends StatelessWidget {
  final bool isLoading;
  final WidgetRef ref;
  const _ProPlanCard({required this.isLoading, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.violet, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Left – title
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pro',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'For the power users',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Right – price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₹99',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ month',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(
                  color: AppColors.white.withOpacity(0.08),
                  height: 1,
                  thickness: 0.5,
                ),
                const SizedBox(height: 20),

                // Features
                ...UpgradeScreen._features.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        const Icon(Symbols.check_circle,
                            color: AppColors.violet, size: 16, fill: 1),
                        const SizedBox(width: 10),
                        Text(
                          f,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // CTA
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => _handleUpgrade(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.violet,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.violet.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.violet.withOpacity(0.3),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            'Start 7-day free trial',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // "Most Popular" badge
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: const BoxDecoration(
                color: AppColors.violet,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: Text(
                'MOST POPULAR',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleUpgrade(BuildContext context) async {
    // For demo: directly upgrade
    ref.read(subscriptionProvider.notifier).upgradeToPro();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🎉 Welcome to Zevi Pro!',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.violet,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 800));
    if (context.mounted) context.pop();
  }
}

// ═══════════════════════════════════════════
// Free Tier Comparison
// ═══════════════════════════════════════════
class _FreeTierComparison extends StatelessWidget {
  final SubscriptionState state;
  const _FreeTierComparison({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CURRENTLY ON FREE TIER',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'ACTIVE',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    color: AppColors.violetDim,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Usage grid
          Row(
            children: [
              // Messages bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: state.usageRatio.clamp(0.0, 1.0),
                        minHeight: 4,
                        backgroundColor: AppColors.surfaceHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          state.usageRatio >= 1.0
                              ? AppColors.danger
                              : AppColors.violet,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${state.messagesUsed} / ${state.messagesLimit} Messages used',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Limits
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Standard Model only',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Standard response speed',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// Payment Logo (text-based for web compat)
// ═══════════════════════════════════════════
class _PaymentLogo extends StatelessWidget {
  final String label;
  const _PaymentLogo(this.label);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.35,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
