import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  Future<void> _completeSetup(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_permissions', true);
    
    if (context.mounted) {
      context.go('/chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.inkBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_ios_new, size: 18),
          color: AppColors.white,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Setup',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: 0.6,
            backgroundColor: AppColors.white.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.violet),
            minHeight: 3,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                children: [
                  Text('Zevi needs access to', style: AppTextStyles.headline(24)),
                  const SizedBox(height: 8),
                  Text(
                    'To act on your behalf, Zevi requires secure connections to your core services.',
                    style: AppTextStyles.body(14, color: AppColors.white.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(height: 32),
                  
                  _PermissionCard(
                    icon: Symbols.calendar_today,
                    title: 'Google Calendar',
                    description: 'Schedule, update, and manage your events.',
                  ),
                  const SizedBox(height: 12),
                  _PermissionCard(
                    icon: Symbols.mail,
                    title: 'Gmail',
                    description: 'Draft, search, and organize your emails.',
                  ),
                  const SizedBox(height: 12),
                  _PermissionCard(
                    icon: Symbols.person,
                    title: 'Google Contacts',
                    description: 'Find team members and schedule meetings.',
                  ),
                  const SizedBox(height: 12),
                  _PermissionCard(
                    icon: Symbols.folder,
                    title: 'Google Drive',
                    description: 'Access document titles for context awareness.',
                  ),
                  const SizedBox(height: 12),
                  _PermissionCard(
                    icon: Symbols.location_on,
                    title: 'Location Data',
                    description: 'Determine contextual travel times.',
                  ),
                ],
              ),
            ),
            
            // Bottom Action Area
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: AppColors.inkBg,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.inkBg.withValues(alpha: 0.8),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.violet,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _completeSetup(context),
                      child: Text(
                        'Allow access & continue',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _completeSetup(context),
                    child: Text(
                      'Skip for now',
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.white.withValues(alpha: 0.4)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.violet.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.violet, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppColors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
