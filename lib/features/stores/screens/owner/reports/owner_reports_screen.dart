import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../models/store_model.dart';
import '../../../models/store_order_model.dart';
import '../../../services/store_service.dart';
import '../../../../../../core/constants/app_colors.dart';

class OwnerReportsScreen extends StatelessWidget {
  final StoreModel store;
  const OwnerReportsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('\u0627\u0644\u062a\u0642\u0627\u0631\u064a\u0631',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<StoreOrderModel>>(
        stream: StoreService.instance.watchStoreOrders(store.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2));
          }
          final orders = snapshot.data ?? [];
          return _ReportsBody(orders: orders);
        },
      ),
    );
  }
}

class _ReportsBody extends StatelessWidget {
  final List<StoreOrderModel> orders;
  const _ReportsBody({required this.orders});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // إحصائيات
    final total = orders.length;
    final delivered = orders.where((o) => o.status == StoreOrderStatus.delivered).length;
    final pending = orders.where((o) => o.status == StoreOrderStatus.pending).length;
    final rejected = orders.where((o) => o.status == StoreOrderStatus.rejected).length;

    // اليوم
    final todayOrders = orders.where((o) =>
        o.createdAt.day == now.day &&
        o.createdAt.month == now.month &&
        o.createdAt.year == now.year).toList();

    // هذا الشهر
    final monthOrders = orders.where((o) =>
        o.createdAt.month == now.month &&
        o.createdAt.year == now.year).toList();

    // إجمالي المبيعات
    final totalRevenue = orders
        .where((o) => o.status == StoreOrderStatus.delivered)
        .fold(0.0, (sum, o) => sum + o.totalPrice);

    final todayRevenue = todayOrders
        .where((o) => o.status == StoreOrderStatus.delivered)
        .fold(0.0, (sum, o) => sum + o.totalPrice);

    final monthRevenue = monthOrders
        .where((o) => o.status == StoreOrderStatus.delivered)
        .fold(0.0, (sum, o) => sum + o.totalPrice);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // بطاقة الإيرادات
        _buildRevenueCard(totalRevenue, todayRevenue, monthRevenue),
        const SizedBox(height: 16),

        // إحصائيات الطلبات
        const Text('\u0625\u062d\u0635\u0627\u0626\u064a\u0627\u062a \u0627\u0644\u0637\u0644\u0628\u0627\u062a',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Row(
          children: [
            _StatBox('\u0625\u062c\u0645\u0627\u0644\u064a', '$total',
                Icons.receipt_long_rounded, AppColors.primary),
            const SizedBox(width: 10),
            _StatBox('\u0645\u0633\u0644\u0651\u0645\u0629', '$delivered',
                Icons.check_circle_rounded, AppColors.statusDelivered),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _StatBox('\u0628\u0627\u0646\u062a\u0638\u0627\u0631', '$pending',
                Icons.hourglass_empty_rounded, AppColors.statusShopping),
            const SizedBox(width: 10),
            _StatBox('\u0645\u0631\u0641\u0648\u0636\u0629', '$rejected',
                Icons.cancel_outlined, Colors.redAccent),
          ],
        ),
        const SizedBox(height: 24),

        // آخر الطلبات
        const Text('\u0622\u062e\u0631 \u0627\u0644\u0637\u0644\u0628\u0627\u062a',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        if (orders.isEmpty)
          const Center(
            child: Text('\u0645\u0627 \u0641\u064a \u0637\u0644\u0628\u0627\u062a \u0628\u0639\u062f',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: AppColors.textHint)),
          )
        else
          ...orders.take(10).toList().asMap().entries.map((e) =>
              _OrderRow(order: e.value)
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: e.key * 50))),
      ],
    );
  }

  Widget _buildRevenueCard(double total, double today, double month) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded,
                  color: AppColors.secondaryLight, size: 20),
              SizedBox(width: 8),
              Text('\u0625\u062c\u0645\u0627\u0644\u064a \u0627\u0644\u0645\u0628\u064a\u0639\u0627\u062a',
                  style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                      fontSize: 13, color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 8),
          Text('${total.toStringAsFixed(0)} \u0644.\u0633',
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                  fontSize: 28, fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _RevenueItem(
                  '\u0627\u0644\u064a\u0648\u0645', today, AppColors.secondaryLight)),
              Container(width: 1, height: 40,
                  color: Colors.white.withValues(alpha: 0.2)),
              Expanded(child: _RevenueItem(
                  '\u0647\u0630\u0627 \u0627\u0644\u0634\u0647\u0631', month,
                  Colors.white)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }
}

class _RevenueItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _RevenueItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${value.toStringAsFixed(0)} \u0644.\u0633',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
            fontSize: 11, color: Colors.white60)),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatBox(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(
              color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                    fontSize: 20, fontWeight: FontWeight.w800, color: color)),
                Text(label, style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                    fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final StoreOrderModel order;
  const _OrderRow({required this.order});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (order.status) {
      case StoreOrderStatus.delivered: statusColor = AppColors.statusDelivered; break;
      case StoreOrderStatus.rejected: statusColor = Colors.redAccent; break;
      case StoreOrderStatus.pending: statusColor = AppColors.statusNew; break;
      default: statusColor = AppColors.statusShopping;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(
            color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8,
              decoration: BoxDecoration(
                  color: statusColor, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.customerName,
                    style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                        fontSize: 13, fontWeight: FontWeight.w700)),
                Text(DateFormat('dd/MM hh:mm a').format(order.createdAt),
                    style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text('${order.totalPrice.toStringAsFixed(0)} \u0644.\u0633',
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: AppColors.secondary)),
        ],
      ),
    );
  }
}
