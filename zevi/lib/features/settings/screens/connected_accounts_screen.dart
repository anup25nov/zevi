import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';

// ─────────────────────────────────────────────
// Light theme tokens
// ─────────────────────────────────────────────
const _textDark    = Color(0xFF131318);
const _textSubtitle = Color(0xFF47445A);
const _textLabel   = Color(0xFF484556);
const _cardBg      = Colors.white;
const _permBg      = AppColors.ashBg;
const _darkAvatar  = Color(0xFF0E0E13);

// ─────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────
class _Permission {
  final String label;
  final bool enabled;
  const _Permission(this.label, {this.enabled = true});
}

class _GoogleAccount {
  final String email;
  final String connectedLabel;
  final bool isPrimary;
  final List<_Permission> permissions;
  const _GoogleAccount({
    required this.email,
    required this.connectedLabel,
    required this.isPrimary,
    required this.permissions,
  });
}

const _accounts = [
  _GoogleAccount(
    email: 'alex.design@gmail.com',
    connectedLabel: 'Connected 12 days ago',
    isPrimary: true,
    permissions: [
      _Permission('Read access to Google Drive files'),
      _Permission('Sync with Google Calendar events'),
      _Permission('Write access to Gmail (Disabled)', enabled: false),
    ],
  ),
  _GoogleAccount(
    email: 'work.hq@company.com',
    connectedLabel: 'Enterprise managed',
    isPrimary: false,
    permissions: [
      _Permission('Read access to Calendar'),
      _Permission('Company email sync'),
      _Permission('Admin panel access', enabled: false),
    ],
  ),
];

// ─────────────────────────────────────────────
// Connected Accounts Screen
// ─────────────────────────────────────────────
class ConnectedAccountsScreen extends StatefulWidget {
  const ConnectedAccountsScreen({super.key});

  @override
  State<ConnectedAccountsScreen> createState() =>
      _ConnectedAccountsScreenState();
}

class _ConnectedAccountsScreenState extends State<ConnectedAccountsScreen> {
  // Track which account's permissions panel is expanded
  final Map<int, bool> _expanded = {0: true, 1: false};

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.ashBg,
        body: Stack(
          children: [
            NestedScrollView(
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
                      child: Container(
                        color: AppColors.ashBg.withOpacity(0.82),
                      ),
                    ),
                  ),
                  title: Text(
                    'Zevi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
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
                            color: AppColors.violet,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              body: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────────────────────────
                    Text(
                      'Google\naccounts',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your connected workspaces and synchronize AI preferences across your Google ecosystem.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _textSubtitle,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Account Cards ───────────────────────────────────
                    for (int i = 0; i < _accounts.length; i++) ...[
                      _AccountCard(
                        account: _accounts[i],
                        expanded: _expanded[i] ?? false,
                        onToggle: () {
                          setState(() {
                            _expanded[i] = !(_expanded[i] ?? false);
                          });
                        },
                        onRemove: _accounts[i].isPrimary
                            ? null
                            : () => _showRemoveDialog(context, _accounts[i].email),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Add account button ───────────────────────────────
                    _AddAccountButton(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Google sign-in coming soon',
                                style: GoogleFonts.inter()),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // ── Footer ───────────────────────────────────────────
                    _buildFooter(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Floating pill nav ──────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 24 + MediaQuery.of(context).padding.bottom,
              child: Center(
                child: _FloatingPillNav(
                  onChatTap: () => context.go('/chat'),
                  onBriefingTap: () => context.go('/briefing'),
                  onSettingsTap: () => context.go('/settings'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, String email) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Remove account?',
          style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700, color: _textDark),
        ),
        content: Text(
          'Remove $email from Zevi? This will disconnect all associated permissions.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.outline),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppColors.outline)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Remove',
                style: GoogleFonts.inter(
                    color: AppColors.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: const Color(0xFF484556).withOpacity(0.1), height: 1),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SECURITY PROTOCOL',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.outline,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Zevi uses 256-bit encryption to protect your account tokens. We never store your Google password.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _textSubtitle,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Privacy Policy',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Terms of Access',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Account Card
// ─────────────────────────────────────────────
class _AccountCard extends StatelessWidget {
  final _GoogleAccount account;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback? onRemove;

  const _AccountCard({
    required this.account,
    required this.expanded,
    required this.onToggle,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Google icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _darkAvatar.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Symbols.account_circle,
                      color: AppColors.violet,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.email,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        account.connectedLabel,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: AppColors.outline,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (account.isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.violet,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PRIMARY',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: onRemove,
                    child: Text(
                      'Remove',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Expand toggle row (non-primary only) ─────────────
          if (!account.isPrimary)
            InkWell(
              onTap: onToggle,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      expanded
                          ? 'COLLAPSE PERMISSIONS'
                          : 'EXPAND PERMISSIONS',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: AppColors.outline,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      expanded
                          ? Symbols.expand_less
                          : Symbols.expand_more,
                      color: AppColors.outline,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

          // ── Permissions panel ────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, account.isPrimary ? 0 : 4, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _permBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'ACTIVE PERMISSIONS',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.surfaceHighest,
                            letterSpacing: 1,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Symbols.expand_less,
                          color: AppColors.outline,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final perm in account.permissions)
                      _PermissionItem(perm),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Permission item
// ─────────────────────────────────────────────
class _PermissionItem extends StatelessWidget {
  final _Permission permission;
  const _PermissionItem(this.permission);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          permission.enabled
              ? const Icon(
                  Symbols.check_circle,
                  fill: 1,
                  color: AppColors.violet,
                  size: 18,
                )
              : Opacity(
                  opacity: 0.5,
                  child: Icon(
                    Symbols.radio_button_unchecked,
                    color: AppColors.outline,
                    size: 18,
                  ),
                ),
          const SizedBox(width: 10),
          Expanded(
            child: Opacity(
              opacity: permission.enabled ? 1.0 : 0.5,
              child: Text(
                permission.label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.surfaceHighest,
                  fontStyle: permission.enabled
                      ? FontStyle.normal
                      : FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Dashed border painter
// ─────────────────────────────────────────────
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  const _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
    required this.dashWidth,
    required this.dashGap,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
          strokeWidth / 2, strokeWidth / 2,
          size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final start = distance;
        final end = math.min(distance + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(start, end), paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// Add account button
// ─────────────────────────────────────────────
class _AddAccountButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AddAccountButton({required this.onTap});

  @override
  State<_AddAccountButton> createState() => _AddAccountButtonState();
}

class _AddAccountButtonState extends State<_AddAccountButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.violet.withOpacity(0.04)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: AppColors.violet.withOpacity(0.3),
              borderRadius: 12,
              dashWidth: 8,
              dashGap: 6,
              strokeWidth: 2,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: _hovered ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.violet.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Symbols.add,
                      color: AppColors.violet,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '+ Add another Google account',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.violet,
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
// Floating pill navigation (dark, from test.html)
// ─────────────────────────────────────────────
class _FloatingPillNav extends StatelessWidget {
  final VoidCallback onChatTap;
  final VoidCallback onBriefingTap;
  final VoidCallback onSettingsTap;

  const _FloatingPillNav({
    required this.onChatTap,
    required this.onBriefingTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceHighest,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _PillNavBtn(
            icon: Symbols.chat_bubble,
            active: false,
            onTap: onChatTap,
          ),
          _PillNavBtn(
            icon: Symbols.wb_sunny,
            active: false,
            onTap: onBriefingTap,
          ),
          _PillNavBtn(
            icon: Symbols.settings,
            active: false,
            onTap: onSettingsTap,
          ),
        ],
      ),
    );
  }
}

class _PillNavBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _PillNavBtn({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: active ? AppColors.violet : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          fill: active ? 1 : 0,
          color: active ? Colors.white : AppColors.onSurfaceVariant,
          size: 24,
        ),
      ),
    );
  }
}
