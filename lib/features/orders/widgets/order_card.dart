import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../screens/invoice_screen.dart';
import '../../../core/constants/app_colors.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => InvoiceScreen(order: order))),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: order.status.color.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            const BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildBody(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: order.status.color.withValues(alpha: 0.07),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Row(
        children: [
          // مؤشر الحالة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: order.status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 7, height: 7,
                    decoration: BoxDecoration(
                        color: order.status.color, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(order.status.label,
                    style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: order.status.color)),
              ],
            ),
          ),
          const Spacer(),
          Text(
            order.orderNumber != null ? '#${order.orderNumber}' : '#${order.id.substring(0, 6).toUpperCase()}',
            style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                fontSize: 13, color: AppColors.textSecondary,
                fontWeight: FontWeight.w600),
          ),
          if (order.status == OrderStatus.delivered) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _confirmDelete(context),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.itemsText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                fontSize: 14, color: AppColors.textPrimary,
                height: 1.5, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.primary),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 10),
          _StatusProgressBar(currentStep: order.status.step),
          const SizedBox(height: 8),
          // تسميات المراحل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              '\u062c\u062f\u064a\u062f',
              '\u062a\u0633\u0648\u0642',
              '\u0634\u0631\u0627\u0621',
              '\u0637\u0631\u064a\u0642',
              '\u062a\u0633\u0644\u064a\u0645',
            ].asMap().entries.map((e) => Text(
              e.value,
              style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                fontSize: 9,
                color: e.key <= order.status.step
                    ? order.status.color
                    : AppColors.textHint,
                fontWeight: e.key == order.status.step
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('\u062d\u0630\u0641 \u0627\u0644\u0637\u0644\u0628\u061f',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
        content: Text('\u0647\u0644 \u062a\u0631\u064a\u062f \u062d\u0630\u0641 \u0627\u0644\u0637\u0644\u0628 #${order.orderNumber}\u061f',
            style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 14, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('\u0625\u0644\u063a\u0627\u0621',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await OrderService.instance.deleteOrder(order.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('\u0627\u062d\u0630\u0641',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _StatusProgressBar extends StatelessWidget {
  final int currentStep;
  const _StatusProgressBar({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const totalSteps = 5;
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        final isCurrent = index == currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 4 : 0),
            height: isCurrent ? 6 : 4,
            decoration: BoxDecoration(
              color: isActive ? OrderStatus.values[currentStep].color : AppColors.divider,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}
