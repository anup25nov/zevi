import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

// ─────────────────────────────────────────────
// Colours for light theme
// ─────────────────────────────────────────────
const _textDark = Color(0xFF131318);
const _textMid = Color(0xFF888888);
const _textLabel = Color(0xFF484556);
const _divider = AppColors.ashBg;
const _chevron = Color(0xFFCCCCCC);

// ─────────────────────────────────────────────
// Settings Screen
// ─────────────────────────────────────────────
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final auth = ref.watch(authProvider);
    final user = auth.user;

    final String displayName = user?.displayName ?? 'Guest User';
    final String email = user?.email ?? '';
    final String? photoUrl = user?.photoUrl;
    final String initials = displayName.isNotEmpty
        ? displayName.trim().split(' ').map((e) => e[0]).take(2).join()
        : 'G';

    // Subscription tier: treat as Free until we wire up subProvider
    const bool isPro = false;

    String themeModeLabel() {
      switch (settings.themeMode) {
        case ThemeMode.light:
          return 'Light';
        case ThemeMode.dark:
          return 'Dark';
        case ThemeMode.system:
          return 'System';
      }
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.ashBg,
        bottomNavigationBar: _BottomNavBar(onChatTap: () => context.go('/chat'),
          onBriefingTap: () => context.go('/briefing')),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
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
                  child: Container(
                    color: Colors.white.withOpacity(0.82),
                  ),
                ),
              ),
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
                      const SizedBox(height: 6),
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
                  'Settings',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Profile ────────────────────────────────────
                _buildProfileCard(
                  displayName: displayName,
                  email: email,
                  photoUrl: photoUrl,
                  initials: initials,
                  isPro: isPro,
                ),
                const SizedBox(height: 24),

                // ── ASSISTANT ──────────────────────────────────
                const _SectionLabel('ASSISTANT'),
                _SettingsGroup(
                  children: [
                    _SettingsToggleRow(
                      icon: Symbols.wb_sunny,
                      iconColor: AppColors.violet,
                      label: 'Morning briefing',
                      value: settings.briefingEnabled,
                      onChanged: (_) => notifier.toggleBriefing(),
                    ),
                    _SettingsRow(
                      icon: Symbols.schedule,
                      iconColor: AppColors.violet,
                      label: 'Briefing time',
                      value: settings.briefingTime.format(context),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: settings.briefingTime,
                          builder: (ctx, child) => Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.violet,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) notifier.setBriefingTime(picked);
                      },
                    ),
                    _SettingsRow(
                      icon: Symbols.language,
                      iconColor: AppColors.outline,
                      label: 'Language',
                      value: settings.language,
                      onTap: () => _showLanguageSheet(context, notifier, settings.language),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── ACCOUNTS ───────────────────────────────────
                const _SectionLabel('ACCOUNTS'),
                _SettingsGroup(
                  children: [
                    _SettingsRow(
                      icon: Symbols.manage_accounts,
                      iconColor: AppColors.outline,
                      label: 'Google accounts',
                      onTap: () => context.push('/connected-accounts'),
                    ),
                    _SettingsRow(
                      icon: Symbols.link,
                      iconColor: AppColors.outline,
                      label: 'Linked services',
                      value: '2 active',
                      onTap: () => context.push('/connected-accounts'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── APP ────────────────────────────────────────
                const _SectionLabel('APP'),
                _SettingsGroup(
                  children: [
                    _SettingsRow(
                      icon: Symbols.palette,
                      iconColor: AppColors.outline,
                      label: 'Appearance',
                      value: themeModeLabel(),
                      onTap: () => _showAppearanceSheet(context, notifier, settings.themeMode),
                    ),
                    _SettingsToggleRow(
                      icon: Symbols.notifications,
                      iconColor: AppColors.outline,
                      label: 'Notifications',
                      value: settings.notificationsEnabled,
                      onChanged: (_) => notifier.toggleNotifications(),
                    ),
                    _SettingsRow(
                      icon: Symbols.lock,
                      iconColor: AppColors.outline,
                      label: 'Privacy',
                      onTap: () {},
                    ),
                    _SettingsRow(
                      icon: Symbols.description,
                      iconColor: AppColors.outline,
                      label: 'Terms of Service',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── SUBSCRIPTION ───────────────────────────────
                const _SectionLabel('SUBSCRIPTION'),
                _buildSubscriptionCard(context, isPro),
                const SizedBox(height: 32),

                // ── LOGOUT ─────────────────────────────────────
                _buildLogoutButton(context, ref),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Profile card ─────────────────────────────────────────────────────────
  Widget _buildProfileCard({
    required String displayName,
    required String email,
    required String? photoUrl,
    required String initials,
    required bool isPro,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.violet,
            backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                ? NetworkImage(photoUrl)
                : null,
            child: photoUrl == null || photoUrl.isEmpty
                ? Text(
                    initials,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: _textMid,
                  ),
                ),
              ],
            ),
          ),
          _TierPill(isPro: isPro),
          const SizedBox(height: 8),
          const Icon(Symbols.chevron_right, color: _chevron, size: 18),
        ],
      ),
    );
  }

  // ── Subscription card ─────────────────────────────────────────────────────
  Widget _buildSubscriptionCard(BuildContext context, bool isPro) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.violet.withOpacity(0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.violet.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Symbols.workspace_premium,
              fill: 1,
              color: AppColors.violet,
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPro ? 'Zevi Pro' : 'Zevi Free',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPro ? 'Next billing Oct 24, 2025' : 'Upgrade for unlimited access',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.push(isPro ? '/subscription' : '/upgrade'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _textDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isPro ? 'Manage' : 'Upgrade',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Logout button ─────────────────────────────────────────────────────────
  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _confirmLogout(context, ref),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Symbols.logout, color: AppColors.danger, size: 20),
            const SizedBox(height: 8),
            Text(
              'Log out',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log out?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        content: Text(
          "You'll need to sign in again to use Zevi.",
          style: GoogleFonts.inter(fontSize: 14, color: _textMid),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.outline),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Log out',
              style: GoogleFonts.inter(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).signOut();
      if (context.mounted) context.go('/sign-in');
    }
  }

  // ── Language picker sheet ─────────────────────────────────────────────────
  void _showLanguageSheet(
      BuildContext context, SettingsNotifier notifier, String current) {
    const languages = [
      'English (US)',
      'English (UK)',
      'Hindi',
      'Spanish',
      'French',
      'German',
      'Japanese',
      'Chinese (Simplified)',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: _chevron,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Language',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),
          ...languages.map(
            (lang) => ListTile(
              title: Text(lang, style: GoogleFonts.inter(fontSize: 15)),
              trailing: lang == current
                  ? const Icon(Symbols.check_circle, fill: 1,
                      color: AppColors.violet, size: 20)
                  : null,
              onTap: () {
                notifier.setLanguage(lang);
                Navigator.pop(ctx);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Appearance picker sheet ───────────────────────────────────────────────
  void _showAppearanceSheet(
      BuildContext context, SettingsNotifier notifier, ThemeMode current) {
    const options = [
      (ThemeMode.system, Symbols.phone_android, 'System default'),
      (ThemeMode.light, Symbols.light_mode, 'Light'),
      (ThemeMode.dark, Symbols.dark_mode, 'Dark'),
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: _chevron,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Appearance',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),
          for (final (mode, icon, label) in options)
            ListTile(
              leading: Icon(icon, color: AppColors.outline, size: 22),
              title: Text(label, style: GoogleFonts.inter(fontSize: 15)),
              trailing: mode == current
                  ? const Icon(Symbols.check_circle, fill: 1,
                      color: AppColors.violet, size: 20)
                  : null,
              onTap: () {
                notifier.setThemeMode(mode);
                Navigator.pop(ctx);
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable: Section label
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
// Reusable: Settings group (white card)
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
                  color: _divider,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable: Settings row (tappable)
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
                const SizedBox(height: 12),
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
                  Text(
                    value!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: _textMid,
                    ),
                  ),
                if (onTap != null) ...[
                  const SizedBox(height: 4),
                  const Icon(Symbols.chevron_right, color: _chevron, size: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable: Settings toggle row
// ─────────────────────────────────────────────
class _SettingsToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggleRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 12),
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
            CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.violet,
              trackColor: AppColors.ashBg,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable: Tier pill
// ─────────────────────────────────────────────
class _TierPill extends StatelessWidget {
  final bool isPro;
  const _TierPill({required this.isPro});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isPro ? const Color(0xFFE8E3FF) : const Color(0xFFF4F3F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPro ? 'Pro' : 'Free',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isPro ? AppColors.violet : _textMid,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Bottom nav bar (light theme)
// ─────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  final VoidCallback onChatTap;
  final VoidCallback onBriefingTap;

  const _BottomNavBar({
    required this.onChatTap,
    required this.onBriefingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.ashBg, width: 1),
        ),
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
          _NavItem(
            icon: Symbols.chat_bubble,
            active: false,
            onTap: onChatTap,
          ),
          _NavItem(
            icon: Symbols.wb_sunny,
            active: false,
            onTap: onBriefingTap,
          ),
          _NavItem(
            icon: Symbols.settings,
            active: true,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.active,
    this.onTap,
  });

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
