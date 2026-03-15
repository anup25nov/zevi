import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';

// ─────────────────────────────────────────────
// Local colour tokens (light theme)
// ─────────────────────────────────────────────
const _textDark   = Color(0xFF131318);
const _textMid    = Color(0xFF888888);
const _textLabel  = Color(0xFF484556);
const _textBody   = Color(0xFF555555);
const _divColor   = AppColors.ashBg;
const _chevron    = Color(0xFFCCCCCC);
const _successGrn = Color(0xFF12B76A);
const _successBg  = Color(0xFFDCFAEE);

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────
class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.ashBg,
        bottomNavigationBar: _BottomNavBar(
          onChatTap: () => context.go('/chat'),
          onBriefingTap: () => context.go('/briefing'),
          onSettingsTap: () => context.go('/settings'),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leadingWidth: 72,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Symbols.arrow_back,
                      color: _textDark,
                      size: 20,
                    ),
                  ),
                ),
              ),
              flexibleSpace: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(color: Colors.white.withOpacity(0.82)),
                ),
              ),
              title: Text(
                'Subscription',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              centerTitle: false,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: [
                      Text(
                        'ACCOUNT CENTER',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.outline,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Symbols.account_circle,
                        fill: 1,
                        color: _textDark,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page title
                Text(
                  'Subscription',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Current Plan ───────────────────────────────
                _buildPlanCard(context),
                const SizedBox(height: 20),

                // ── Usage ──────────────────────────────────────
                _buildUsageCard(),
                const SizedBox(height: 20),

                // ── Manage ─────────────────────────────────────
                _SectionLabel('MANAGE PLAN'),
                _buildActionsGroup(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Plan card ────────────────────────────────────────────────────────────
  Widget _buildPlanCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan name + active pill
          Row(
            children: [
              Text(
                'Zevi Pro',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _successBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ACTIVE',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _successGrn,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Price
          Text(
            '₹99 / month',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),

          // Renewal date
          Text(
            'Renews on Oct 24, 2025',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: _textMid,
            ),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: _divColor),
          ),

          // Payment method
          Row(
            children: [
              const Icon(Symbols.payment, color: AppColors.violet, size: 18),
              const SizedBox(width: 10),
              Text(
                'UPI  (user@oksbi)',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _textBody,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Usage card ───────────────────────────────────────────────────────────
  Widget _buildUsageCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This month',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 20),
          _UsageBar(
            label: 'Messages',
            valueLabel: '847 sent',
            color: AppColors.violet,
            trackColor: const Color(0xFFE8E3FF),
            value: 0.85,
          ),
          const SizedBox(height: 20),
          _UsageBar(
            label: 'Web searches',
            valueLabel: '124 / 200',
            color: AppColors.success,
            trackColor: const Color(0xFFD1FAE5),
            value: 0.62,
          ),
        ],
      ),
    );
  }

  // ── Actions group ─────────────────────────────────────────────────────────
  Widget _buildActionsGroup(BuildContext context) {
    return _SettingsGroup(
      children: [
        _SettingsRow(
          icon: Symbols.swap_horiz,
          iconColor: AppColors.violet,
          label: 'Change plan',
          onTap: () => context.push('/upgrade'),
        ),
        _SettingsRow(
          icon: Symbols.receipt_long,
          iconColor: AppColors.outline,
          label: 'Billing history',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Billing history coming soon',
                  style: GoogleFonts.inter(),
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
        ),
        _DangerRow(
          icon: Symbols.cancel,
          label: 'Cancel subscription',
          onTap: () => _showCancelDialog(context),
        ),
      ],
    );
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Cancel subscription?',
          style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700, color: _textDark),
        ),
        content: Text(
          "Your Pro access continues until Oct 24, 2025.\nAfter that, you'll be downgraded to the Free plan.",
          style: GoogleFonts.inter(fontSize: 14, color: _textMid),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep Pro',
              style: GoogleFonts.inter(
                  color: AppColors.violet, fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cancellation request sent',
                      style: GoogleFonts.inter()),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppColors.danger,
                ),
              );
            },
            child: Text(
              'Cancel plan',
              style: GoogleFonts.inter(
                  color: AppColors.danger, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Usage bar
// ─────────────────────────────────────────────
class _UsageBar extends StatelessWidget {
  final String label;
  final String valueLabel;
  final Color color;
  final Color trackColor;
  final double value;

  const _UsageBar({
    required this.label,
    required this.valueLabel,
    required this.color,
    required this.trackColor,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
            const Spacer(),
            Text(
              valueLabel,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: trackColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _textLabel,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Settings group card
// ─────────────────────────────────────────────
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 52,
                  color: AppColors.ashBg,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Settings row
// ─────────────────────────────────────────────
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                ),
                if (value != null)
                  Text(value!,
                      style:
                          GoogleFonts.inter(fontSize: 13, color: _textMid)),
                const SizedBox(width: 4),
                const Icon(Symbols.chevron_right, color: _chevron, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Danger row (red text)
// ─────────────────────────────────────────────
class _DangerRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _DangerRow({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.danger, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Bottom nav bar (light, settings active)
// ─────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  final VoidCallback onChatTap;
  final VoidCallback onBriefingTap;
  final VoidCallback onSettingsTap;

  const _BottomNavBar({
    required this.onChatTap,
    required this.onBriefingTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.ashBg, width: 1)),
      ),
      padding: EdgeInsets.only(
        left: 40,
        right: 40,
        top: 10,
        bottom: 10 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(icon: Symbols.chat_bubble, active: false, onTap: onChatTap),
          _NavItem(icon: Symbols.wb_sunny, active: false, onTap: onBriefingTap),
          _NavItem(icon: Symbols.settings, active: true, onTap: onSettingsTap),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;
  const _NavItem({required this.icon, required this.active, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            fill: active ? 1 : 0,
            color: active ? AppColors.violet : AppColors.outline,
            size: 26,
          ),
          if (active) ...[
            const SizedBox(height: 3),
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.violet,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
