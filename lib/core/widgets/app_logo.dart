import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool animate;
  final bool darkBg; // لو الخلفية داكنة

  const AppLogo({
    super.key,
    this.size = 80,
    this.showText = true,
    this.animate = true,
    this.darkBg = false,
  });

  @override
  Widget build(BuildContext context) {
    final logo = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(),
        if (showText) ...[
          const SizedBox(height: 12),
          _buildText(),
        ],
      ],
    );

    if (!animate) return logo;
    return logo
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 400.ms);
  }

  Widget _buildIcon() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: darkBg ? Colors.white : AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // دائرة زخرفية
          Positioned(
            top: -size * 0.08,
            right: -size * 0.08,
            child: Container(
              width: size * 0.55,
              height: size * 0.55,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // أيقونة اليد + الحقيبة
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // حقيبة التسوق بلون ذهبي
              Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.secondaryLight,
                size: size * 0.35,
              ),
              // يد بيضاء
              Icon(
                Icons.back_hand_outlined,
                color: Colors.white,
                size: size * 0.28,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildText() {
    final textColor = darkBg ? Colors.white : AppColors.textPrimary;
    return Column(
      children: [
        Text(
          '\u0639\u0644\u0649 \u0639\u064a\u0646\u064a',
          style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
            fontSize: size * 0.26,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: 1,
          ),
        ),
        Text(
          '\u062a\u0633\u0648\u0642 \u0634\u062e\u0635\u064a \u2022 \u062a\u0648\u0635\u064a\u0644 \u0641\u0648\u0631\u064a',
          style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
            fontSize: size * 0.12,
            color: darkBg
                ? Colors.white70
                : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
