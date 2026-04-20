import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/store_model.dart';
import '../models/store_order_model.dart';
import '../services/store_service.dart';
import '../../../core/constants/app_colors.dart';

class CartScreen extends StatefulWidget {
  final StoreModel store;
  final List<CartItem> items;
  const CartScreen({super.key, required this.store, required this.items});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _placing = false;

  double get _total => widget.items.fold(0, (s, i) => s + i.total);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _placing = true);

    final order = StoreOrderModel(
      id: const Uuid().v4(),
      storeId: widget.store.id,
      storeName: widget.store.name,
      customerId: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      deliveryAddress: _addressController.text.trim(),
      items: widget.items,
      createdAt: DateTime.now(),
    );

    await StoreService.instance.placeOrder(order);
    _sendWhatsApp(order);

    if (!mounted) return;
    setState(() => _placing = false);
    _showSuccess();
  }

  void _sendWhatsApp(StoreOrderModel order) {
    final itemsList = order.items
        .map((i) => '- ${i.productName} x${i.quantity} = ${i.total.toStringAsFixed(0)} \u0644.\u0633')
        .join('\n');
    final msg = Uri.encodeComponent(
      '\ud83d\uded2 \u0637\u0644\u0628 \u062c\u062f\u064a\u062f \u0645\u0646 \u062a\u0637\u0628\u064a\u0642 \u0639\u0644\u0649 \u0639\u064a\u0646\u064a\n\n'
      '\ud83d\udc64 \u0627\u0644\u0632\u0628\u0648\u0646: ${order.customerName}\n'
      '\ud83d\udcde \u0627\u0644\u0647\u0627\u062a\u0641: ${order.customerPhone}\n'
      '\ud83d\udccd \u0627\u0644\u0639\u0646\u0648\u0627\u0646: ${order.deliveryAddress}\n\n'
      '\ud83d\udce6 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a:\n$itemsList\n\n'
      '\ud83d\udcb0 \u0627\u0644\u0645\u062c\u0645\u0648\u0639: ${order.totalPrice.toStringAsFixed(0)} \u0644.\u0633',
    );
    final phone = widget.store.phone.replaceAll(RegExp(r'\D'), '');
    debugPrint('https://wa.me/963$phone?text=$msg');
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded,
                color: AppColors.primary, size: 64),
            SizedBox(height: 16),
            Text('\u062a\u0645 \u0625\u0631\u0633\u0627\u0644 \u0637\u0644\u0628\u0643!',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                    fontSize: 20, fontWeight: FontWeight.w800)),
            SizedBox(height: 8),
            Text('\u0633\u064a\u062a\u0648\u0627\u0635\u0644 \u0645\u0639\u0643 \u0635\u0627\u062d\u0628 \u0627\u0644\u0645\u062a\u062c\u0631 \u0642\u0631\u064a\u0628\u0627\u064b',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                    fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('\u062a\u0645\u0627\u0645',
                  style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('\u062a\u0623\u0643\u064a\u062f \u0627\u0644\u0637\u0644\u0628',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ملخص الطلب
            _buildOrderSummary(),
            const SizedBox(height: 24),

            // بيانات الزبون
            _buildSectionTitle('\u0628\u064a\u0627\u0646\u0627\u062a\u0643'),
            const SizedBox(height: 12),
            _buildField(
              controller: _nameController,
              hint: '\u0627\u0633\u0645\u0643 \u0627\u0644\u0643\u0631\u064a\u0645',
              icon: Icons.person_outline,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? '\u0623\u062f\u062e\u0644 \u0627\u0633\u0645\u0643' : null,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _phoneController,
              hint: '\u0631\u0642\u0645 \u0647\u0627\u062a\u0641\u0643',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              ltr: true,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return '\u0623\u062f\u062e\u0644 \u0631\u0642\u0645 \u0647\u0627\u062a\u0641\u0643';
                if (v.replaceAll(RegExp(r'\D'), '').length < 7) return '\u0631\u0642\u0645 \u063a\u064a\u0631 \u0635\u062d\u064a\u062d';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _addressController,
              hint: '\u0645\u0639\u0631\u0628\u0627\u060c \u0634\u0627\u0631\u0639..\u060c \u0628\u0646\u0627\u064a\u0629..',
              icon: Icons.location_on_outlined,
              maxLines: 2,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? '\u0623\u062f\u062e\u0644 \u0639\u0646\u0648\u0627\u0646 \u0627\u0644\u062a\u0648\u0635\u064a\u0644' : null,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _placing ? null : _placeOrder,
                child: _placing
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('\u062a\u0623\u0643\u064a\u062f \u0627\u0644\u0637\u0644\u0628 \ud83d\ude80',
                        style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                            fontSize: 17, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(
            color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_outlined,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(widget.store.name,
                  style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ],
          ),
          const Divider(height: 16),
          ...widget.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(child: Text(item.productName,
                    style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13))),
                Text('x${item.quantity}',
                    style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(width: 12),
                Text('${item.total.toStringAsFixed(0)} \u0644.\u0633',
                    style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ],
            ),
          )),
          const Divider(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('\u0627\u0644\u0645\u062c\u0645\u0648\u0639',
                  style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                      fontSize: 15, fontWeight: FontWeight.w700)),
              Text('${_total.toStringAsFixed(0)} \u0644.\u0633',
                  style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                      fontSize: 17, fontWeight: FontWeight.w800,
                      color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
            fontSize: 15, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary));
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool ltr = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        prefixIcon: maxLines > 1
            ? Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Icon(icon, color: AppColors.textSecondary, size: 20))
            : Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
      validator: validator,
    );
  }
}
