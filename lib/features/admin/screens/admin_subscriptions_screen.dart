import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../stores/models/store_model.dart';
import '../../stores/services/store_service.dart';
import '../../../core/constants/app_colors.dart';

class AdminSubscriptionsScreen extends StatelessWidget {
  const AdminSubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0627\u0634\u062a\u0631\u0627\u0643\u0627\u062a',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => StoreService.instance.checkExpiredSubscriptions(),
          ),
        ],
      ),
      body: StreamBuilder<List<StoreModel>>(
        stream: StoreService.instance.watchAllStores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2));
          }
          final stores = snapshot.data ?? [];
          final active = stores.where((s) => s.status == StoreStatus.active).length;
          final trial = stores.where((s) => s.status == StoreStatus.trial).length;
          final expired = stores.where((s) =>
              s.status == StoreStatus.expired ||
              s.status == StoreStatus.suspended).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  _StatCard('\u0646\u0634\u0637', '$active', AppColors.statusDelivered),
                  const SizedBox(width: 10),
                  _StatCard('\u062a\u062c\u0631\u064a\u0628\u064a', '$trial', AppColors.statusNew),
                  const SizedBox(width: 10),
                  _StatCard('\u0645\u0646\u062a\u0647\u064a', '$expired', Colors.redAccent),
                ],
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 8),
              Text('\u0627\u0644\u062f\u062e\u0644 \u0627\u0644\u0634\u0647\u0631\u064a: \$${active * 20}',
                  style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                      fontSize: 13, color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              ...stores.asMap().entries.map((e) =>
                  _StoreSubscriptionCard(store: e.value)
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: e.key * 60))
                      .slideY(begin: 0.05)),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                fontSize: 24, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                fontSize: 11, color: color.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}

class _StoreSubscriptionCard extends StatelessWidget {
  final StoreModel store;
  const _StoreSubscriptionCard({required this.store});

  @override
  Widget build(BuildContext context) {
    final endDate = store.status == StoreStatus.trial
        ? store.trialEnd : store.subscriptionEnd;
    final isExpiringSoon = endDate != null &&
        endDate.difference(DateTime.now()).inDays <= 3 &&
        store.isAccessible;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: isExpiringSoon
            ? Border.all(color: Colors.orange, width: 1.5) : null,
        boxShadow: const [BoxShadow(
            color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store.name, style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                          fontSize: 16, fontWeight: FontWeight.w700)),
                      Text(store.phone, style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                          fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: store.status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(store.status.label, style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: store.status.color)),
                ),
              ],
            ),
            if (endDate != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    isExpiringSoon ? Icons.warning_amber_rounded
                        : Icons.calendar_today_outlined,
                    size: 14,
                    color: isExpiringSoon ? Colors.orange : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${store.status == StoreStatus.trial ? "\u062a\u062c\u0631\u064a\u0628\u064a" : "\u0627\u0634\u062a\u0631\u0627\u0643"} \u064a\u0646\u062a\u0647\u064a: ${DateFormat('dd/MM/yyyy').format(endDate)}'
                      '${store.isAccessible ? " (\u0628\u0642\u064a ${store.daysLeft} \u064a\u0648\u0645)" : ""}',
                      style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                          fontSize: 12,
                          color: isExpiringSoon ? Colors.orange : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _renewDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('\u062a\u062c\u062f\u064a\u062f',
                        style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                            fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
                if (store.status != StoreStatus.suspended) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _suspendConfirm(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('\u0625\u064a\u0642\u0627\u0641',
                          style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                              fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _renewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('\u062a\u062c\u062f\u064a\u062f \u0627\u0634\u062a\u0631\u0627\u0643 ${store.name}',
            style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1, 3, 6, 12].map((months) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('$months \u0634\u0647\u0631 - \$${months * 20}',
                style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textHint),
            onTap: () async {
              Navigator.pop(ctx);
              await StoreService.instance.activateSubscription(store.id, months);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('\u062a\u0645 \u062a\u062c\u062f\u064a\u062f \u0627\u0634\u062a\u0631\u0627\u0643 ${store.name} \u0644\u0640 $months \u0634\u0647\u0631 \u2705',
                      style: const TextStyle(fontFamily: 'IBMPlexSansArabic', )),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ));
              }
            },
          )).toList(),
        ),
      ),
    );
  }

  void _suspendConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('\u0625\u064a\u0642\u0627\u0641 \u0627\u0644\u0645\u062a\u062c\u0631\u061f',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
        content: Text('\u0633\u064a\u062e\u062a\u0641\u064a ${store.name} \u0645\u0646 \u0642\u0627\u0626\u0645\u0629 \u0627\u0644\u0645\u062a\u0627\u062c\u0631 \u0641\u0648\u0631\u0627\u064b',
            style: const TextStyle(fontFamily: 'IBMPlexSansArabic', color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('\u0625\u0644\u063a\u0627\u0621',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await StoreService.instance.suspendStore(store.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('\u0625\u064a\u0642\u0627\u0641',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
