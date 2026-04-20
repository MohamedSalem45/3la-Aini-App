import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/constants/app_colors.dart';
import '../orders/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 700),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Stack(
            children: [
              _buildDecorativeCircles(),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 110, height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 30, offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const AppLogo(size: 70, showText: false, animate: false),
                    )
                        .animate()
                        .scale(begin: const Offset(0.3, 0.3), duration: 700.ms, curve: Curves.elasticOut)
                        .fadeIn(duration: 400.ms),
                    const SizedBox(height: 28),
                    const Text('\u0639\u0644\u0649 \u0639\u064a\u0646\u064a',
                        style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                            fontSize: 40, fontWeight: FontWeight.w800,
                            color: Colors.white, letterSpacing: 2))
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 500.ms)
                        .slideY(begin: 0.3, curve: Curves.easeOut),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('\u062a\u0633\u0648\u0642 \u0634\u062e\u0635\u064a  \u2022  \u062a\u0648\u0635\u064a\u0644 \u0641\u0648\u0631\u064a  \u2022  \u0645\u0639\u0631\u0628\u0627',
                          style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                              fontSize: 13, color: Colors.white70,
                              fontWeight: FontWeight.w500)),
                    )
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 500.ms)
                        .slideY(begin: 0.2),
                    const SizedBox(height: 56),
                    _buildScooterRow(),
                    const SizedBox(height: 44),
                    _buildLoadingDots(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        Positioned(top: -80, right: -80,
          child: Container(width: 260, height: 260,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(0.88, 0.88), duration: 3000.ms)),
        Positioned(bottom: -100, left: -60,
          child: Container(width: 320, height: 320,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04), shape: BoxShape.circle))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(0.93, 0.93), duration: 2500.ms, delay: 500.ms)),
        Positioned(top: 120, left: -40,
          child: Container(width: 160, height: 160,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12), shape: BoxShape.circle))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(0.8, 0.8), duration: 2000.ms, delay: 300.ms)),
      ],
    );
  }

  Widget _buildScooterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Expanded(child: Container(height: 2,
            decoration: BoxDecoration(gradient: LinearGradient(
              colors: [Colors.transparent, Colors.white.withValues(alpha: 0.3)])))),
          const SizedBox(width: 12),
          const Text('\ud83d\udef5', style: TextStyle(fontSize: 40))
              .animate(onPlay: (c) => c.repeat())
              .moveY(begin: 0, end: -8, duration: 450.ms, curve: Curves.easeInOut)
              .then()
              .moveY(begin: -8, end: 0, duration: 450.ms, curve: Curves.easeInOut),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 2,
            decoration: BoxDecoration(gradient: LinearGradient(
              colors: [Colors.white.withValues(alpha: 0.3), Colors.transparent])))),
        ],
      ),
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) => Container(
        width: 8, height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle),
      )
          .animate(onPlay: (c) => c.repeat())
          .fadeIn(delay: Duration(milliseconds: i * 220), duration: 400.ms)
          .then()
          .fadeOut(duration: 400.ms)),
    );
  }
}
