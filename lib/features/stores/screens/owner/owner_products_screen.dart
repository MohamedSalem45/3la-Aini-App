import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/store_model.dart';
import '../../services/store_service.dart';
import '../../../../../core/services/cloudinary_service.dart';
import '../../../../../core/constants/app_colors.dart';

class OwnerProductsScreen extends StatelessWidget {
  final StoreModel store;
  final CategoryModel category;
  const OwnerProductsScreen({
      super.key, required this.store, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${category.icon}  ${category.name}',
            style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: TextButton.icon(
              onPressed: () => _showAddProduct(context),
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              label: const Text('\u0645\u0646\u062a\u062c',
                  style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: StoreService.instance.watchProducts(store.id, category.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2));
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) return _buildEmpty(context);

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (_, i) => _ProductCard(
              store: store,
              product: products[i],
            )
                .animate()
                .fadeIn(delay: Duration(milliseconds: i * 60))
                .scale(begin: const Offset(0.92, 0.92)),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProduct(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('\u0625\u0636\u0627\u0641\u0629 \u0645\u0646\u062a\u062c',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inventory_2_outlined,
                size: 48, color: AppColors.secondary),
          ),
          const SizedBox(height: 16),
          const Text('\u0645\u0627 \u0641\u064a \u0645\u0646\u062a\u062c\u0627\u062a \u0628\u0639\u062f',
              style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                  fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('\u0627\u0628\u062f\u0623 \u0628\u0625\u0636\u0627\u0641\u0629 \u0645\u0646\u062a\u062c\u0627\u062a\u0643 \u0627\u0644\u0622\u0646',
              style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showAddProduct(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('\u0623\u0636\u0641 \u0645\u0646\u062a\u062c\u0627\u064b',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showAddProduct(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddProductSheet(
          store: store, categoryId: category.id),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final StoreModel store;
  final ProductModel product;

  const _ProductCard({required this.store, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(
            color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المنتج
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18)),
                  child: product.imageUrl != null
                      ? Image.network(
                          product.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
                // badge التوفر
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: product.isAvailable
                          ? AppColors.statusDelivered
                          : Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.isAvailable
                          ? '\u0645\u062a\u0648\u0641\u0631'
                          : '\u063a\u064a\u0631 \u0645\u062a\u0648\u0641\u0631',
                      style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                          fontSize: 9, color: Colors.white,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // تفاصيل المنتج
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                        fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${product.price.toStringAsFixed(0)} \u0644.\u0633',
                      style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                          fontSize: 13, fontWeight: FontWeight.w800,
                          color: AppColors.secondary),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // زر تفعيل/تعطيل
                        GestureDetector(
                          onTap: () => _toggleAvailability(),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: product.isAvailable
                                  ? AppColors.statusDelivered.withValues(alpha: 0.1)
                                  : Colors.redAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              product.isAvailable
                                  ? Icons.toggle_on_rounded
                                  : Icons.toggle_off_rounded,
                              size: 18,
                              color: product.isAvailable
                                  ? AppColors.statusDelivered
                                  : Colors.redAccent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // زر حذف
                        GestureDetector(
                          onTap: () => StoreService.instance
                              .deleteProduct(store.id, product.id),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.delete_outline,
                                size: 16, color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
    color: AppColors.surfaceVariant,
    child: const Center(
      child: Icon(Icons.image_outlined,
          color: AppColors.textHint, size: 36),
    ),
  );

  void _toggleAvailability() {
    StoreService.instance.updateProduct(
      store.id,
      ProductModel(
        id: product.id,
        categoryId: product.categoryId,
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        isAvailable: !product.isAvailable,
        description: product.description,
      ),
    );
  }
}

// ===== Bottom Sheet إضافة منتج =====
class _AddProductSheet extends StatefulWidget {
  final StoreModel store;
  final String categoryId;
  const _AddProductSheet({required this.store, required this.categoryId});

  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _imageUrl;
  bool _uploading = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() => _uploading = true);
    final bytes = await picked.readAsBytes();
    final url = await CloudinaryService.instance
        .uploadInvoice(bytes, const Uuid().v4());
    setState(() { _imageUrl = url; _uploading = false; });
  }

  void _save() async {
    if (_nameCtrl.text.trim().isEmpty || _priceCtrl.text.trim().isEmpty) {
      return;
    }
    setState(() => _saving = true);
    await StoreService.instance.addProduct(
      widget.store.id,
      ProductModel(
        id: const Uuid().v4(),
        categoryId: widget.categoryId,
        name: _nameCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
        imageUrl: _imageUrl,
        description: _descCtrl.text.trim(),
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 8, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // handle
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text('\u0625\u0636\u0627\u0641\u0629 \u0645\u0646\u062a\u062c \u062c\u062f\u064a\u062f',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                    fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),

            // صورة المنتج
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity, height: 140,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _imageUrl != null
                        ? AppColors.primary
                        : AppColors.divider,
                    width: _imageUrl != null ? 2 : 1,
                  ),
                ),
                child: _uploading
                    ? const Center(child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2))
                    : _imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(_imageUrl!,
                                fit: BoxFit.cover, width: double.infinity))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: AppColors.primary, size: 28),
                              ),
                              const SizedBox(height: 8),
                              const Text('\u0627\u0636\u063a\u0637 \u0644\u0625\u0636\u0627\u0641\u0629 \u0635\u0648\u0631\u0629',
                                  style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                                      fontSize: 13, color: AppColors.primary,
                                      fontWeight: FontWeight.w600)),
                              const Text('\u0627\u062e\u062a\u064a\u0627\u0631\u064a \u2014 \u064a\u062c\u0639\u0644 \u0645\u0646\u062a\u062c\u0643 \u0623\u062c\u0645\u0644',
                                  style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                                      fontSize: 11, color: AppColors.textHint)),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 16),

            // اسم المنتج
            _buildLabel('\u0627\u0633\u0645 \u0627\u0644\u0645\u0646\u062a\u062c *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameCtrl,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 15),
              decoration: const InputDecoration(
                hintText: '\u0645\u062b\u0627\u0644: \u062e\u0628\u0632 \u062a\u0646\u0648\u0631',
                prefixIcon: Icon(Icons.inventory_2_outlined,
                    color: AppColors.primary, size: 20),
              ),
            ),
            const SizedBox(height: 14),

            // السعر
            _buildLabel('\u0627\u0644\u0633\u0639\u0631 \u0628\u0627\u0644\u0644\u064a\u0631\u0629 \u0627\u0644\u0633\u0648\u0631\u064a\u0629 *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 15),
              decoration: const InputDecoration(
                hintText: '5000',
                hintTextDirection: TextDirection.ltr,
                prefixIcon: Icon(Icons.attach_money_rounded,
                    color: AppColors.secondary, size: 20),
                suffixText: '\u0644.\u0633',
                suffixStyle: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            const SizedBox(height: 14),

            // الوصف
            _buildLabel('\u0648\u0635\u0641 \u0627\u062e\u062a\u064a\u0627\u0631\u064a'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descCtrl,
              textDirection: TextDirection.rtl,
              maxLines: 2,
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 14),
              decoration: const InputDecoration(
                hintText: '\u0623\u0636\u0641 \u0648\u0635\u0641\u0627\u064b \u0644\u0644\u0645\u0646\u062a\u062c...',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Icon(Icons.description_outlined,
                      color: AppColors.textSecondary, size: 20)),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _saving
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('\u062d\u0641\u0638 \u0627\u0644\u0645\u0646\u062a\u062c',
                              style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                                  fontSize: 16, fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
          fontSize: 13, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary));
}
