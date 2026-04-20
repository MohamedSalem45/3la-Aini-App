import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../stores/screens/stores_list_screen.dart';
import '../../profile/screens/account_screen.dart';
import '../../../main.dart';
import '../../../core/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 24),
                _buildStoresButton(context),
                const SizedBox(height: 20),
                _buildFeaturesRow(context),
                const SizedBox(height: 20),
                _buildAccountButton(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? '\u0635\u0628\u0627\u062d \u0627\u0644\u062e\u064a\u0631 \u2600\ufe0f'
        : hour < 17
            ? '\u0645\u0633\u0627\u0621 \u0627\u0644\u0646\u0648\u0631 \ud83c\udf24\ufe0f'
            : '\u0645\u0633\u0627\u0621 \u0627\u0644\u062e\u064a\u0631 \ud83c\udf19';

    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.manage_accounts_outlined,
                color: Colors.white, size: 20),
          ),
          tooltip:
              '\u062f\u062e\u0648\u0644 \u0627\u0644\u0645\u062a\u0627\u062c\u0631',
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const AuthGate())),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                  top: -30,
                  left: -30,
                  child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle))),
              Positioned(
                  bottom: 10,
                  right: -20,
                  child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          shape: BoxShape.circle))),
              SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(greeting,
                            style: const TextStyle(
                                fontFamily: 'IBMPlexSansArabic',
                                fontSize: 13,
                                color: Colors.white60,
                                fontWeight: FontWeight.w500))
                        .animate()
                        .fadeIn(duration: 500.ms),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                                '\u0639\u0644\u0649 \u0639\u064a\u0646\u064a',
                                style: TextStyle(
                                    fontFamily: 'IBMPlexSansArabic',
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white))
                            .animate()
                            .fadeIn(delay: 100.ms)
                            .slideX(begin: -0.05),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('\u0645\u0639\u0631\u0628\u0627',
                              style: TextStyle(
                                  fontFamily: 'IBMPlexSansArabic',
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .scale(begin: const Offset(0.8, 0.8)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                            '\u062a\u0633\u0648\u0642 \u0645\u0646 \u0645\u062a\u0627\u062c\u0631\u0643 \u0627\u0644\u0645\u0641\u0636\u0644\u0629 \u0628\u0633\u0647\u0648\u0644\u0629 \ud83d\uded2',
                            style: TextStyle(
                                fontFamily: 'IBMPlexSansArabic',
                                fontSize: 13,
                                color: Colors.white70))
                        .animate()
                        .fadeIn(delay: 150.ms),
                  ],
                ),
              ),
            ),
            ],
          ),
        ),
      ),
      title: const Text('\u0639\u0644\u0649 \u0639\u064a\u0646\u064a',
          style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white)),
    );
  }

  Widget _buildStoresButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const StoresListScreen())),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.secondary, Color(0xFFE8A830)],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 22),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.storefront_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '\u062a\u0635\u0641\u062d \u0627\u0644\u0645\u062a\u0627\u062c\u0631',
                        style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    Text(
                        '\u0627\u062e\u062a\u0631 \u0645\u062a\u062c\u0631\u0643 \u0648\u0627\u0637\u0644\u0628 \u0628\u0633\u0647\u0648\u0644\u0629',
                        style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 13,
                            color: Colors.white70)),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildAccountButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const AccountScreen())),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 22),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.account_circle,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الحساب',
                        style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    Text('الملف الشخصي وسجل الطلبات والمفضلة',
                        style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 13,
                            color: Colors.white70)),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildFeaturesRow(BuildContext context) {
    return const Row(
      children: [
        _FeatureCard(
          icon: '\ud83d\udcf8',
          title:
              '\u0641\u0627\u062a\u0648\u0631\u0629 \u062d\u0642\u064a\u0642\u064a\u0629',
          sub:
              '\u0646\u0631\u0633\u0644\u0647\u0627 \u0642\u0628\u0644 \u0627\u0644\u062f\u0641\u0639',
          color: AppColors.statusShopping,
        ),
        SizedBox(width: 12),
        _FeatureCard(
          icon: '\ud83d\udef5',
          title: '\u062a\u0648\u0635\u064a\u0644 \u0633\u0631\u064a\u0639',
          sub: '\u0644\u0645\u0639\u0631\u0628\u0627 \u0641\u0642\u0637',
          color: AppColors.statusOnWay,
        ),
        SizedBox(width: 12),
        _FeatureCard(
          icon: '\ud83d\udd12',
          title: '\u0622\u0645\u0646 100%',
          sub:
              '\u062f\u0641\u0639 \u0639\u0646\u062f \u0627\u0644\u0627\u0633\u062a\u0644\u0627\u0645',
          color: AppColors.statusDelivered,
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }
}

class _FeatureCard extends StatelessWidget {
  final String icon;
  final String title;
  final String sub;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(sub,
                style: const TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 10,
                    color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
