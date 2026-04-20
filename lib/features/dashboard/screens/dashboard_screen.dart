import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../orders/models/order_model.dart';
import '../../orders/services/order_service.dart';
import '../widgets/dashboard_order_card.dart';
import '../../admin/screens/admin_subscriptions_screen.dart';
import '../../../core/constants/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  OrderStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: StreamBuilder<List<OrderModel>>(
          stream: OrderService.instance.watchAllOrders(),
          builder: (context, snapshot) {
            final allOrders = snapshot.data ?? [];
            return CustomScrollView(
              slivers: [
                _buildAppBar(context, allOrders),
                SliverToBoxAdapter(child: _buildStats(allOrders)),
                SliverToBoxAdapter(child: _buildFilterChips()),
                _buildOrdersList(allOrders),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, List<OrderModel> orders) {
    final newCount =
        orders.where((o) => o.status == OrderStatus.newOrder).length;
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      snap: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
        color: AppColors.textPrimary,
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.storefront_outlined,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('لوحة التحكم',
                  style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              Text('على عيني 🛒',
                  style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 11,
                      color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.card_membership_outlined),
            color: AppColors.secondary,
            tooltip: 'الاشتراكات',
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminSubscriptionsScreen())),
          ),
          if (newCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.statusNew,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$newCount جديد',
                  style: const TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(0.95, 0.95), duration: 800.ms),
        ],
      ),
    );
  }

  Widget _buildStats(List<OrderModel> orders) {
    final active =
        orders.where((o) => o.status != OrderStatus.delivered).length;
    final delivered =
        orders.where((o) => o.status == OrderStatus.delivered).length;
    final onWay = orders.where((o) => o.status == OrderStatus.onTheWay).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          _statCard('نشط', '$active', AppColors.statusShopping),
          const SizedBox(width: 10),
          _statCard('بالطريق', '$onWay', AppColors.statusOnWay),
          const SizedBox(width: 10),
          _statCard('مسلّم', '$delivered', AppColors.statusDelivered),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 11,
                    color: color.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      null,
      OrderStatus.newOrder,
      OrderStatus.shopping,
      OrderStatus.purchased,
      OrderStatus.onTheWay,
      OrderStatus.delivered,
    ];

    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filters.length,
        itemBuilder: (_, i) {
          final status = filters[i];
          final isSelected = _filterStatus == status;
          final label = status == null ? 'الكل' : status.label;
          final color = status == null ? AppColors.primary : status.color;

          return GestureDetector(
            onTap: () => setState(() => _filterStatus = status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isSelected ? color : color.withValues(alpha: 0.2)),
              ),
              child: Text(label,
                  style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : color)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> allOrders) {
    var orders = _filterStatus == null
        ? allOrders
        : allOrders.where((o) => o.status == _filterStatus).toList();

    if (allOrders.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
            child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2)),
      );
    }

    if (orders.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, size: 56, color: AppColors.textHint),
              SizedBox(height: 12),
              Text('ما في طلبات بهالحالة',
                  style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 16,
                      color: AppColors.textHint)),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => DashboardOrderCard(order: orders[i])
              .animate()
              .fadeIn(delay: Duration(milliseconds: i * 80))
              .slideY(begin: 0.05),
          childCount: orders.length,
        ),
      ),
    );
  }
}
