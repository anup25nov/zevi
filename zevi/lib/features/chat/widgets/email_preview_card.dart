import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class EmailPreviewCard extends StatelessWidget {
  final String to;
  final String subject;
  final String body;
  final VoidCallback onSend;
  final VoidCallback onEdit;

  const EmailPreviewCard({
    super.key,
    required this.to,
    required this.subject,
    required this.body,
    required this.onSend,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final truncated = body.length > 120;
    final displayBody = truncated ? body.substring(0, 120) : body;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0E14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.white.withOpacity(0.08),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // To row
          _MetaRow(label: 'To:', value: to),
          const SizedBox(height: 6),
          // Subject row
          _MetaRow(label: 'Subject:', value: subject),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: 0.5,
            color: AppColors.white.withOpacity(0.08),
          ),

          // Body preview
          truncated
              ? ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.white,
                      AppColors.white.withOpacity(0.0),
                    ],
                    stops: const [0.6, 1.0],
                  ).createShader(bounds),
                  blendMode: BlendMode.dstIn,
                  child: _BodyText(text: '$displayBody...'),
                )
              : _BodyText(text: displayBody),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Edit ghost button
              OutlinedButton(
                onPressed: onEdit,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.white.withOpacity(0.2),
                    width: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Edit',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.white.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Send primary button
              ElevatedButton(
                onPressed: onSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violet,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: 0,
                ),
                child: Text(
                  'Send',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            color: AppColors.white.withOpacity(0.4),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.white.withOpacity(0.75),
            ),
          ),
        ),
      ],
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.white.withOpacity(0.65),
        height: 1.6,
      ),
    );
  }
}
