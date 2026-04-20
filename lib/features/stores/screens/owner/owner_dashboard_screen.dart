import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/store_model.dart';
import '../../models/store_order_model.dart';
import '../../services/store_service.dart';
import '../../../auth/services/auth_service.dart';
import '../../../../core/constants/app_colors.dart';
import 'owner_categories_screen.dart';
import 'owner_orders_screen.dart';
import 'owner_register_screen.dart';
import 'owner_edit_store_screen.dart';
import 'reports/owner_reports_screen.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const OwnerRegisterScreen();

    return StreamBuilder<StoreModel?>(
      stream: StoreService.instance.watchMyStore(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2)),
          );
        }
        final store = snapshot.data;
        if (store == null) return const OwnerRegisterScreen();
        return _OwnerHome(store: store);
      },
    );
  }
}

class _OwnerHome extends StatelessWidget {
  final StoreModel store;
  const _OwnerHome({required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _buildOpenToggle()),
          SliverToBoxAdapter(child: _buildSubscriptionBanner()),
          SliverToBoxAdapter(child: _buildStatsSection()),
          SliverToBoxAdapter(child: _buildMenuSection(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
          ),
          onPressed: () async {
            await AuthService.instance.logout();
            if (context.mounted) Navigator.pop(context);
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
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
              Positioned(top: -40, left: -40,
                child: Container(width: 180, height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    shape: BoxShape.circle))),
              Positioned(bottom: -20, right: -20,
                child: Container(width: 140, height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight.withValues(alpha: 0.1),
                    shape: BoxShape.circle))),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.secondaryLight.withValues(alpha: 0.4),
                                width: 1.5),
                          ),
                          child: store.logoUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(store.logoUrl!, fit: BoxFit.cover))
                              : const Icon(Icons.storefront_rounded,
                                  color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(store.name,
                                  style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                                      fontSize: 20, fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                              const Text('\u0644\u0648\u062d\u0629 \u062a\u062d\u0643\u0645 \u0627\u0644\u0645\u062a\u062c\u0631',
                                  style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                                      fontSize: 12, color: Colors.white60)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      title: Text(store.name,
          style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
              fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
    );
  }

  // ===== زر فتح/إغلاق المتجر =====
  Widget _buildOpenToggle() {
    return GestureDetector(
      onTap: () => StoreService.instance.toggleStoreOpen(store.id, !store.isOpen),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: store.isOpen
              ? AppColors.statusDelivered.withValues(alpha: 0.08)
              : Colors.redAccent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: store.isOpen
                ? AppColors.statusDelivered.withValues(alpha: 0.3)
                : Colors.redAccent.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: store.isOpen ? AppColors.statusDelivered : Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                store.isOpen ? Icons.storefront_rounded : Icons.store_mall_directory_outlined,
                color: Colors.white, size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.isOpen ? '\u0627\u0644\u0645\u062a\u062c\u0631 \u0645\u0641\u062a\u0648\u062d \ud83d\udfe2' : '\u0627\u0644\u0645\u062a\u062c\u0631 \u0645\u063a\u0644\u0642 \ud83d\udd34',
                    style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                        fontSize: 16, fontWeight: FontWeight.w800,
                        color: store.isOpen ? AppColors.statusDelivered : Colors.redAccent),
                  ),
                  Text(
                    store.isOpen ? '\u0627\u0636\u063a\u0637 \u0644\u0625\u063a\u0644\u0627\u0642 \u0627\u0644\u0645\u062a\u062c\u0631' : '\u0627\u0636\u063a\u0637 \u0644\u0641\u062a\u062d \u0627\u0644\u0645\u062a\u062c\u0631 \u0644\u0644\u0632\u0628\u0627\u0626\u0646',
                    style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 52, height: 28,
              decoration: BoxDecoration(
                color: store.isOpen ? AppColors.statusDelivered : AppColors.divider,
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: store.isOpen ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  width: 22, height: 22,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ===== بانر الاشتراك =====
  Widget _buildSubscriptionBanner() {
    final isExpiringSoon = store.daysLeft <= 3 && store.isAccessible;
    final isExpired = !store.isAccessible;

    final Color bgColor = isExpired
        ? Colors.redAccent
        : isExpiringSoon
            ? Colors.orange
            : AppColors.statusDelivered;

    final IconData icon = isExpired
        ? Icons.warning_amber_rounded
        : isExpiringSoon
            ? Icons.access_time_rounded
            : Icons.verified_rounded;

    final String title = isExpired
        ? '\u0627\u0634\u062a\u0631\u0627\u0643\u0643 \u0645\u0646\u062a\u0647\u064a \u26a0\ufe0f'
        : isExpiringSoon
            ? '\u064a\u0646\u062a\u0647\u064a \u0627\u0634\u062a\u0631\u0627\u0643\u0643 \u0642\u0631\u064a\u0628\u0627\u064b'
            : store.status == StoreStatus.trial
                ? '\u0641\u062a\u0631\u0629 \u062a\u062c\u0631\u064a\u0628\u064a\u0629 \u0646\u0634\u0637\u0629'
                : '\u0627\u0634\u062a\u0631\u0627\u0643 \u0646\u0634\u0637 \u2705';

    final String sub = isExpired
        ? '\u062a\u0648\u0627\u0635\u0644 \u0645\u0639 \u0627\u0644\u0625\u062f\u0627\u0631\u0629 \u0644\u062a\u062c\u062f\u064a\u062f \u0627\u0634\u062a\u0631\u0627\u0643\u0643'
        : '\u064a\u0646\u062a\u0647\u064a \u062e\u0644\u0627\u0644 ${store.daysLeft} \u064a\u0648\u0645';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bgColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: bgColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                    fontSize: 13, fontWeight: FontWeight.w700, color: bgColor)),
                Text(sub, style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                    fontSize: 11, color: bgColor.withValues(alpha: 0.8))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Text(store.status.label,
                style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                    fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ===== الإحصائيات =====
  Widget _buildStatsSection() {
    return StreamBuilder<List<StoreOrderModel>>(
      stream: StoreService.instance.watchStoreOrders(store.id),
      builder: (context, snapshot) {
        final orders = snapshot.data ?? [];
        final now = DateTime.now();
        final pending = orders.where((o) => o.status == StoreOrderStatus.pending).length;
        final today = orders.where((o) =>
            o.createdAt.day == now.day &&
            o.createdAt.month == now.month &&
            o.createdAt.year == now.year).length;
        final delivered = orders.where((o) => o.status == StoreOrderStatus.delivered).length;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('\u0625\u062d\u0635\u0627\u0626\u064a\u0627\u062a \u0633\u0631\u064a\u0639\u0629',
                  style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _StatCard(value: '$pending', label: '\u062c\u062f\u064a\u062f\u0629',
                      icon: Icons.notifications_active_outlined, color: AppColors.statusNew),
                  const SizedBox(width: 10),
                  _StatCard(value: '$today', label: '\u0627\u0644\u064a\u0648\u0645',
                      icon: Icons.today_outlined, color: AppColors.secondary),
                  const SizedBox(width: 10),
                  _StatCard(value: '$delivered', label: '\u0645\u0633\u0644\u0651\u0645\u0629',
                      icon: Icons.check_circle_outline_rounded, color: AppColors.statusDelivered),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms);
      },
    );
  }

  // ===== القائمة =====
  void _shareStore(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('\u062a\u0645 \u0646\u0633\u062e \u0631\u0633\u0627\u0644\u0629 \u0627\u0644\u0645\u0634\u0627\u0631\u0643\u0629 \u2705',
          style: TextStyle(fontFamily: 'IBMPlexSansArabic', )),
      backgroundColor: AppColors.statusDelivered,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0645\u062a\u062c\u0631',
              style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _BigMenuCard(
                  icon: Icons.category_rounded,
                  label: '\u0627\u0644\u0623\u0642\u0633\u0627\u0645 \u0648\u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a',
                  sub: '\u0623\u0636\u0641 \u0648\u0639\u062f\u0651\u0644 \u0645\u0646\u062a\u062c\u0627\u062a\u0643',
                  color: AppColors.primary,
                  icon2: Icons.arrow_forward_ios_rounded,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => OwnerCategoriesScreen(store: store))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SmallMenuCard(
                  icon: Icons.receipt_long_rounded,
                  label: '\u0627\u0644\u0637\u0644\u0628\u0627\u062a',
                  color: AppColors.secondary,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => OwnerOrdersScreen(store: store))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SmallMenuCard(
                  icon: Icons.bar_chart_rounded,
                  label: '\u0627\u0644\u062a\u0642\u0627\u0631\u064a\u0631',
                  color: AppColors.statusPurchased,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => OwnerReportsScreen(store: store))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SmallMenuCard(
                  icon: Icons.edit_note_rounded,
                  label: '\u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u0645\u062a\u062c\u0631',
                  color: AppColors.statusOnWay,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => OwnerEditStoreScreen(store: store))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SmallMenuCard(
                  icon: Icons.share_rounded,
                  label: '\u0645\u0634\u0627\u0631\u0643\u0629',
                  color: AppColors.statusDelivered,
                  onTap: () => _shareStore(context),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatCard({required this.value, required this.label,
      required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(
              color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                fontSize: 10, color: AppColors.textSecondary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _BigMenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final IconData icon2;
  final VoidCallback onTap;
  const _BigMenuCard({required this.icon, required this.label,
      required this.sub, required this.color, required this.icon2,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
            begin: Alignment.topRight, end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                Icon(icon2, color: Colors.white54, size: 16),
              ],
            ),
            const SizedBox(height: 14),
            Text(label, style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _SmallMenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SmallMenuCard({required this.icon, required this.label,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(
              color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
