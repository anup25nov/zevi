import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle headline(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.plusJakartaSans(
          fontSize: size,
          fontWeight: weight ?? FontWeight.w700,
          color: color ?? AppColors.onSurface,
          letterSpacing: -0.02);

  static TextStyle body(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.inter(
          fontSize: size,
          fontWeight: weight ?? FontWeight.w400,
          color: color ?? AppColors.onSurface,
          height: 1.6);

  static TextStyle label(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.spaceGrotesk(
          fontSize: size,
          fontWeight: weight ?? FontWeight.w500,
          color: color ?? AppColors.outline,
          letterSpacing: 0.1);
}
