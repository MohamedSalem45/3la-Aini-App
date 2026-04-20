import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/store_model.dart';
import '../../models/store_order_model.dart';
import '../../services/store_service.dart';
import '../../../../../core/services/cloudinary_service.dart';
import '../../../../../core/constants/app_colors.dart';

class OwnerOrdersScreen extends StatelessWidget {
  final StoreModel store;
  const OwnerOrdersScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('\u0627\u0644\u0637\u0644\u0628\u0627\u062a \u0627\u0644\u0648\u0627\u0631\u062f\u0629',
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
          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 56, color: AppColors.textHint),
                  SizedBox(height: 12),
                  Text('\u0645\u0627 \u0641\u064a \u0637\u0644\u0628\u0627\u062a \u0628\u0639\u062f',
                      style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                          fontSize: 15, color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (_, i) => _OwnerOrderCard(order: orders[i])
                .animate()
                .fadeIn(delay: Duration(milliseconds: i * 60))
                .slideY(begin: 0.05),
          );
        },
      ),
    );
  }
}

class _OwnerOrderCard extends StatefulWidget {
  final StoreOrderModel order;
  const _OwnerOrderCard({required this.order});

  @override
  State<_OwnerOrderCard> createState() => _OwnerOrderCardState();
}

class _OwnerOrderCardState extends State<_OwnerOrderCard> {
  final _msgCtrl = TextEditingController();
  bool _uploadingInvoice = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.order.status) {
      case StoreOrderStatus.pending: return AppColors.statusNew;
      case StoreOrderStatus.accepted: return AppColors.statusDelivered;
      case StoreOrderStatus.rejected: return Colors.redAccent;
      case StoreOrderStatus.ready: return AppColors.statusShopping;
      case StoreOrderStatus.delivered: return AppColors.statusDelivered;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(
            color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildCustomerInfo(),
          _buildItems(),
          _buildMessages(),
          _buildReplyField(),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8,
              decoration: BoxDecoration(
                  color: _statusColor, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(widget.order.status.label,
              style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: _statusColor)),
          const Spacer(),
          Text(DateFormat('dd/MM hh:mm a').format(widget.order.createdAt),
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                  fontSize: 11, color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(widget.order.customerName,
                  style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                      fontSize: 14, fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: () => _openWhatsApp(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 14, color: Color(0xFF25D366)),
                      const SizedBox(width: 4),
                      Text(widget.order.customerPhone,
                          style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                              fontSize: 12, color: Color(0xFF25D366),
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(child: Text(widget.order.deliveryAddress,
                  style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                      fontSize: 13, color: AppColors.textSecondary))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItems() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 10),
          ...widget.order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(child: Text(item.productName,
                    style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13))),
                Text('x${item.quantity}',
                    style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(width: 10),
                Text('${item.total.toStringAsFixed(0)} \u0644.\u0633',
                    style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ],
            ),
          )),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('\u0627\u0644\u0645\u062c\u0645\u0648\u0639',
                  style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
              Text('${widget.order.totalPrice.toStringAsFixed(0)} \u0644.\u0633',
                  style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                      fontSize: 15, fontWeight: FontWeight.w800,
                      color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (widget.order.messages.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 8),
          const Text('\u0627\u0644\u0631\u0633\u0627\u0626\u0644',
              style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                  fontSize: 12, color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          ...widget.order.messages.map((msg) => Align(
            alignment: msg.fromStore
                ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: msg.fromStore
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(msg.text,
                  style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13)),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildReplyField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _msgCtrl,
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13),
              decoration: const InputDecoration(
                hintText: '\u0631\u062f \u0639\u0644\u0649 \u0627\u0644\u0632\u0628\u0648\u0646...',
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // أزرار تغيير الحالة
          if (widget.order.status == StoreOrderStatus.pending)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => StoreService.instance.updateOrderStatus(
                        widget.order.id, StoreOrderStatus.accepted),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusDelivered,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('\u0642\u0628\u0648\u0644 \u0627\u0644\u0637\u0644\u0628',
                        style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => StoreService.instance.updateOrderStatus(
                        widget.order.id, StoreOrderStatus.rejected),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('\u0631\u0641\u0636',
                        style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          if (widget.order.status == StoreOrderStatus.accepted) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => StoreService.instance.updateOrderStatus(
                    widget.order.id, StoreOrderStatus.ready),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusShopping,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('\u062c\u0627\u0647\u0632 \u0644\u0644\u062a\u0648\u0635\u064a\u0644',
                    style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
              ),
            ),
          ],
          if (widget.order.status == StoreOrderStatus.ready) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => StoreService.instance.updateOrderStatus(
                    widget.order.id, StoreOrderStatus.delivered),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusDelivered,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('\u062a\u0645 \u0627\u0644\u062a\u0633\u0644\u064a\u0645',
                    style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
              ),
            ),
          ],
          // رفع الفاتورة
          if (widget.order.status != StoreOrderStatus.pending) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _uploadingInvoice ? null : _uploadInvoice,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.3)),
                ),
                child: _uploadingInvoice
                    ? const Center(child: SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(
                            color: AppColors.secondary, strokeWidth: 2)))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long_outlined,
                              color: AppColors.secondary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            widget.order.invoiceUrl != null
                                ? '\u062a\u063a\u064a\u064a\u0631 \u0627\u0644\u0641\u0627\u062a\u0648\u0631\u0629'
                                : '\u0631\u0641\u0639 \u0627\u0644\u0641\u0627\u062a\u0648\u0631\u0629 \ud83d\udcf8',
                            style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: AppColors.secondary),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_msgCtrl.text.trim().isEmpty) return;
    final msg = StoreOrderMessage(
      text: _msgCtrl.text.trim(),
      fromStore: true,
      sentAt: DateTime.now(),
    );
    await StoreService.instance.sendMessage(widget.order.id, msg);
    _msgCtrl.clear();
  }

  void _openWhatsApp() {
    final phone = widget.order.customerPhone.replaceAll(RegExp(r'\D'), '');
    debugPrint('https://wa.me/963$phone');
  }

  void _uploadInvoice() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    setState(() => _uploadingInvoice = true);
    final bytes = await picked.readAsBytes();
    final url = await CloudinaryService.instance
        .uploadInvoice(bytes, widget.order.id);
    if (url != null) {
      await StoreService.instance.uploadInvoice(widget.order.id, url);
    }
    if (mounted) setState(() => _uploadingInvoice = false);
  }
}
