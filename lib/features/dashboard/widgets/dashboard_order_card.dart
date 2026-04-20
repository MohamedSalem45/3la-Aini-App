import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../orders/models/order_model.dart';
import '../../orders/services/order_service.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/constants/app_colors.dart';

class DashboardOrderCard extends StatefulWidget {
  final OrderModel order;
  const DashboardOrderCard({super.key, required this.order});

  @override
  State<DashboardOrderCard> createState() => _DashboardOrderCardState();
}

class _DashboardOrderCardState extends State<DashboardOrderCard> {
  bool _uploadingInvoice = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader(), _buildBody(), _buildInvoiceSection(), _buildStatusButtons()],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: widget.order.status.color.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(width: 10, height: 10,
              decoration: BoxDecoration(color: widget.order.status.color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(widget.order.status.label,
              style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13, fontWeight: FontWeight.w600, color: widget.order.status.color)),
          const Spacer(),
          Text(_formatTime(widget.order.createdAt),
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 11, color: AppColors.textHint)),
          const SizedBox(width: 8),
          Text('#${widget.order.orderNumber ?? widget.order.id.substring(0, 6).toUpperCase()}',
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _confirmDelete,
            child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(widget.order.customerName,
                  style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 14, fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: () => _showPhone(widget.order.phoneNumber),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.phone_outlined, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(widget.order.phoneNumber,
                        style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Expanded(child: Text(widget.order.deliveryAddress,
                style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13, color: AppColors.textSecondary))),
          ]),
          const Divider(height: 20),
          const Text('\u0642\u0627\u0626\u0645\u0629 \u0627\u0644\u0645\u0634\u062a\u0631\u064a\u0627\u062a:',
              style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(widget.order.itemsText,
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildInvoiceSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: widget.order.invoiceImageUrl != null ? _buildInvoicePreview() : _buildUploadButton(),
    );
  }

  Widget _buildUploadButton() {
    return GestureDetector(
      onTap: _uploadingInvoice ? null : _pickAndUploadInvoice,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
        ),
        child: _uploadingInvoice
            ? const Center(child: SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(color: AppColors.secondary, strokeWidth: 2)))
            : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.receipt_long_outlined, color: AppColors.secondary, size: 18),
                SizedBox(width: 8),
                Text('\u0631\u0641\u0639 \u0635\u0648\u0631\u0629 \u0627\u0644\u0641\u0627\u062a\u0648\u0631\u0629 \ud83d\udcf8',
                    style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
              ]),
      ),
    );
  }

  Widget _buildInvoicePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Text('\u0627\u0644\u0641\u0627\u062a\u0648\u0631\u0629 \u2705',
              style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
          const Spacer(),
          GestureDetector(
            onTap: _pickAndUploadInvoice,
            child: const Text('\u062a\u063a\u064a\u064a\u0631',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 11, color: AppColors.textSecondary, decoration: TextDecoration.underline)),
          ),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            widget.order.invoiceImageUrl!,
            height: 120, width: double.infinity, fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null ? child
                : const SizedBox(height: 120, child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))),
            errorBuilder: (_, __, ___) => Container(
              height: 80,
              decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(10)),
              child: const Center(child: Icon(Icons.broken_image_outlined, color: AppColors.textHint)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButtons() {
    final nextStatuses = _getNextStatuses();
    if (nextStatuses.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: nextStatuses.asMap().entries.map((e) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: e.key > 0 ? 8 : 0),
            child: ElevatedButton(
              onPressed: () => _updateStatus(e.value),
              style: ElevatedButton.styleFrom(
                backgroundColor: e.value.color,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(e.value.label,
                  style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        )).toList(),
      ),
    );
  }

  List<OrderStatus> _getNextStatuses() {
    switch (widget.order.status) {
      case OrderStatus.newOrder: return [OrderStatus.shopping];
      case OrderStatus.shopping: return [OrderStatus.purchased];
      case OrderStatus.purchased: return [OrderStatus.onTheWay];
      case OrderStatus.onTheWay: return [OrderStatus.delivered];
      case OrderStatus.delivered: return [];
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '\u0627\u0644\u0622\u0646';
    if (diff.inMinutes < 60) return '\u0645\u0646\u0630 ${diff.inMinutes} \u062f';
    if (diff.inHours < 24) return '\u0645\u0646\u0630 ${diff.inHours} \u0633';
    return DateFormat('dd/MM').format(dt);
  }

  void _showPhone(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('\u0631\u0642\u0645 \u0627\u0644\u0632\u0628\u0648\u0646: $phone', style: const TextStyle(fontFamily: 'IBMPlexSansArabic', )),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _updateStatus(OrderStatus newStatus) async {
    await OrderService.instance.updateStatus(widget.order.id, newStatus);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('\u0637\u0644\u0628 #${widget.order.orderNumber} \u2192 ${newStatus.label}', style: const TextStyle(fontFamily: 'IBMPlexSansArabic', )),
        backgroundColor: newStatus.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('\u062d\u0630\u0641 \u0627\u0644\u0637\u0644\u0628\u061f',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
        content: Text(
          '\u0647\u0644 \u062a\u0631\u064a\u062f \u062d\u0630\u0641 \u0627\u0644\u0637\u0644\u0628 #${widget.order.orderNumber}\u061f',
          style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('\u0625\u0644\u063a\u0627\u0621',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await OrderService.instance.deleteOrder(widget.order.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('\u062a\u0645 \u062d\u0630\u0641 \u0627\u0644\u0637\u0644\u0628 #${widget.order.orderNumber}',
                      style: const TextStyle(fontFamily: 'IBMPlexSansArabic', )),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
              }
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

  void _pickAndUploadInvoice() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    setState(() => _uploadingInvoice = true);
    try {
      final bytes = await picked.readAsBytes();
      final url = await CloudinaryService.instance.uploadInvoice(bytes, widget.order.id);
      if (url != null) {
        await OrderService.instance.updateInvoiceUrl(widget.order.id, url);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('\u062a\u0645 \u0631\u0641\u0639 \u0627\u0644\u0641\u0627\u062a\u0648\u0631\u0629 \u0628\u0646\u062c\u0627\u062d \u2705',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', )),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('\u0641\u0634\u0644 \u0631\u0641\u0639 \u0627\u0644\u0635\u0648\u0631\u0629\u060c \u062d\u0627\u0648\u0644 \u0645\u0631\u0629 \u062b\u0627\u0646\u064a\u0629',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', )),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('\u062e\u0637\u0623: $e', style: const TextStyle(fontFamily: 'IBMPlexSansArabic', )),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _uploadingInvoice = false);
    }
  }
}
