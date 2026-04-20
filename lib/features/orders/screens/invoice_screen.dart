import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/order_model.dart';
import '../../../core/constants/app_colors.dart';

class InvoiceScreen extends StatelessWidget {
  final OrderModel order;
  const InvoiceScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('\u0641\u0627\u062a\u0648\u0631\u0629 \u0637\u0644\u0628 #${order.orderNumber}',
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusBadge(),
              const SizedBox(height: 20),
              _buildOrderDetails(),
              const SizedBox(height: 20),
              _buildInvoiceImage(context),
              const SizedBox(height: 20),
              _buildItemsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: order.status.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: order.status.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(width: 10, height: 10,
              decoration: BoxDecoration(color: order.status.color, shape: BoxShape.circle))
              .animate(onPlay: (c) => c.repeat())
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 800.ms)
              .then()
              .scale(begin: const Offset(1.2, 1.2), end: const Offset(0.8, 0.8), duration: 800.ms),
          const SizedBox(width: 10),
          Text(order.status.label,
              style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: order.status.color)),
          const Spacer(),
          Text('#${order.orderNumber}',
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          _detailRow(Icons.person_outline, '\u0627\u0644\u0627\u0633\u0645', order.customerName),
          const Divider(height: 20),
          _detailRow(Icons.phone_outlined, '\u0627\u0644\u0647\u0627\u062a\u0641', order.phoneNumber),
          const Divider(height: 20),
          _detailRow(Icons.location_on_outlined, '\u0627\u0644\u0639\u0646\u0648\u0627\u0646', order.deliveryAddress),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 11, color: AppColors.textSecondary)),
            Text(value, style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildInvoiceImage(BuildContext context) {
    if (order.invoiceImageUrl == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Column(
          children: [
            Icon(Icons.hourglass_empty_rounded,
                size: 48, color: AppColors.textHint),
            SizedBox(height: 12),
            Text('\u0627\u0644\u0641\u0627\u062a\u0648\u0631\u0629 \u0644\u0645 \u062a\u0635\u0644 \u0628\u0639\u062f',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 15, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('\u0633\u062a\u0635\u0644\u0643 \u0628\u0639\u062f \u0627\u0644\u0634\u0631\u0627\u0621 \u0645\u0628\u0627\u0634\u0631\u0629\u064b',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 12, color: AppColors.textHint)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('\u0635\u0648\u0631\u0629 \u0627\u0644\u0641\u0627\u062a\u0648\u0631\u0629',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _showFullImage(context),
          child: Hero(
            tag: 'invoice_${order.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CachedNetworkImage(
                imageUrl: order.invoiceImageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2)),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(child: Icon(Icons.broken_image_outlined,
                      color: AppColors.textHint, size: 40)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text('\u0627\u0636\u063a\u0637 \u0639\u0644\u0649 \u0627\u0644\u0635\u0648\u0631\u0629 \u0644\u0644\u062a\u0643\u0628\u064a\u0631',
              style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 11, color: AppColors.textHint)),
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    final items = order.itemsText.split('\n').where((l) => l.trim().isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('\u0642\u0627\u0626\u0645\u0629 \u0627\u0644\u0645\u0634\u062a\u0631\u064a\u0627\u062a',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: items.length > 1
              ? Column(
                  children: items.asMap().entries.map((e) => Padding(
                    padding: EdgeInsets.only(bottom: e.key < items.length - 1 ? 10 : 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('${e.key + 1}',
                                style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                                    fontSize: 10, fontWeight: FontWeight.w700,
                                    color: AppColors.primary)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(e.value.replaceAll(RegExp(r'^[-•]\s*'), ''),
                              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 14, height: 1.5)),
                        ),
                      ],
                    ),
                  )).toList(),
                )
              : Text(order.itemsText,
                  style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 14, height: 1.6)),
        ),
      ],
    );
  }

  void _showFullImage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Hero(
            tag: 'invoice_${order.id}',
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: order.invoiceImageUrl!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
