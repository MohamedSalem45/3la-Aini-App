import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../../../core/constants/app_colors.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemsController = TextEditingController();
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _itemsController.dispose();
    _addressController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final order = OrderModel(
      id: const Uuid().v4(),
      customerName: _nameController.text.trim(),
      deliveryAddress: _addressController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      itemsText: _itemsController.text.trim(),
      status: OrderStatus.newOrder,
      createdAt: DateTime.now(),
    );

    await OrderService.instance.addOrder(order);

    // اجلب الرقم التسلسلي بعد الحفظ
    final counterSnap = await FirebaseFirestore.instance
        .collection('meta')
        .doc('counter')
        .get();
    final orderNumber = counterSnap.data()?['orderCount'] as int? ?? 0;
    final savedOrder = order.copyWith(orderNumber: orderNumber);

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    _showSuccessSheet(savedOrder);
  }

  void _showSuccessSheet(OrderModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => _SuccessSheet(
        order: order,
        onDone: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('طلب جديد',
              style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontWeight: FontWeight.w700)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              _buildHeroHeader(),
              const SizedBox(height: 28),
              _buildLabel('اسمك الكريم'),
              const SizedBox(height: 8),
              _buildNameField(),
              const SizedBox(height: 20),
              _buildLabel('رقم التواصل 📞'),
              const SizedBox(height: 8),
              _buildPhoneField(),
              const SizedBox(height: 20),
              _buildLabel('عنوان التوصيل'),
              const SizedBox(height: 8),
              _buildAddressField(),
              const SizedBox(height: 20),
              _buildLabel('قائمة مشترياتك 🛒'),
              const SizedBox(height: 4),
              _buildItemsHint(),
              const SizedBox(height: 8),
              _buildItemsField(),
              const SizedBox(height: 12),
              _buildTrustNote(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.edit_note_rounded,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اكتب وخلّي الباقي علينا',
                    style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                SizedBox(height: 2),
                Text('سنتسوق لك ونوصّل الفاتورة الحقيقية',
                    style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 12,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary));
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textDirection: TextDirection.rtl,
      style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 15),
      decoration: const InputDecoration(
        hintText: 'مثال: أبو محمد',
        prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'من فضلك أدخل اسمك' : null,
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      textDirection: TextDirection.ltr,
      keyboardType: TextInputType.phone,
      style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 15),
      decoration: const InputDecoration(
        hintText: 'مثال: 03 123 456',
        hintTextDirection: TextDirection.rtl,
        prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textSecondary),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'من فضلك أدخل رقم التواصل';
        final digits = v.replaceAll(RegExp(r'\D'), '');
        if (digits.length < 7) return 'رقم الهاتف غير صحيح';
        return null;
      },
    ).animate().fadeIn(delay: 150.ms);
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      textDirection: TextDirection.rtl,
      style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 15),
      maxLines: 2,
      decoration: const InputDecoration(
        hintText: 'معربا، شارع..، بناية..، طابق..',
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: 24),
          child:
              Icon(Icons.location_on_outlined, color: AppColors.textSecondary),
        ),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'من فضلك أدخل عنوان التوصيل' : null,
    ).animate().fadeIn(delay: 150.ms);
  }

  Widget _buildItemsHint() {
    return const Text(
      'اكتب كل شيء تريده بحرية تامة — لا قيود على الشكل',
      style: TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontSize: 12,
          color: AppColors.textSecondary),
    );
  }

  Widget _buildItemsField() {
    return TextFormField(
      controller: _itemsController,
      textDirection: TextDirection.rtl,
      style: const TextStyle(
          fontFamily: 'IBMPlexSansArabic', fontSize: 15, height: 1.7),
      maxLines: 7,
      minLines: 5,
      decoration: const InputDecoration(
        hintText:
            'مثال:\n- خبز تنور من فرن أبو علي\n- حليب كامل الدسم\n- بيض بلدي ١٢ حبة\n- جبنة بيضاء نص كيلو',
        alignLabelWithHint: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'من فضلك اكتب ما تريد شراءه' : null,
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildTrustNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.receipt_long_outlined,
              color: AppColors.secondary, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'ستصلك صورة الفاتورة الحقيقية قبل الدفع',
              style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 12,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms);
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : const Text('أرسل طلبك الآن 🚀',
                style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }
}

class _SuccessSheet extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onDone;

  const _SuccessSheet({required this.order, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.primary, size: 40),
            ).animate().scale(
                begin: const Offset(0.5, 0.5),
                duration: 400.ms,
                curve: Curves.elasticOut),
            const SizedBox(height: 16),
            const Text('وصل طلبك! على عيني 🎉',
                style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text(
              'رح نتسوق لك هلق ونبعتلك صورة الفاتورة قبل ما نيجي',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'رقم طلبك: #${order.orderNumber}',
                style: const TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onDone,
                child: const Text('تمام، يسلموا!',
                    style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
