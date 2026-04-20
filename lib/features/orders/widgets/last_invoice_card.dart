import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/order_model.dart';
import '../screens/invoice_screen.dart';
import '../../../core/constants/app_colors.dart';

class LastInvoiceCard extends StatelessWidget {
  final OrderModel order;
  const LastInvoiceCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => InvoiceScreen(order: order))),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: -20, left: -20,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildInvoiceImage(),
                  const SizedBox(width: 14),
                  Expanded(child: _buildDetails()),
                  const Icon(Icons.chevron_left_rounded, color: Colors.white38, size: 22),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceImage() {
    return Container(
      width: 76, height: 76,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: order.invoiceImageUrl != null
            ? CachedNetworkImage(
                imageUrl: order.invoiceImageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _imagePlaceholder(),
                errorWidget: (_, __, ___) => _imagePlaceholder(),
              )
            : _imagePlaceholder(),
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text('\u062a\u0645 \u0627\u0644\u062a\u0633\u0644\u064a\u0645 \u2705',
              style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                  fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 6),
        Text(
          order.itemsText,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
              fontSize: 14, color: Colors.white,
              fontWeight: FontWeight.w600, height: 1.4),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 12, color: Colors.white54),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                order.deliveryAddress,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 11, color: Colors.white60),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _imagePlaceholder() => Container(
    color: Colors.white.withValues(alpha: 0.1),
    child: const Center(
      child: Icon(Icons.receipt_long_outlined, color: Colors.white38, size: 30),
    ),
  );
}
