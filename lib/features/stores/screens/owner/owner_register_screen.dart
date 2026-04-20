import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/store_model.dart';
import '../../models/store_categories.dart';
import '../../services/store_service.dart';
import '../../../../../core/services/cloudinary_service.dart';
import '../../../../core/constants/app_colors.dart';

class OwnerRegisterScreen extends StatefulWidget {
  const OwnerRegisterScreen({super.key});

  @override
  State<OwnerRegisterScreen> createState() => _OwnerRegisterScreenState();
}

class _OwnerRegisterScreenState extends State<OwnerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descController = TextEditingController();
  String? _logoUrl;
  String _selectedCategory = 'other';
  bool _uploadingLogo = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() => _uploadingLogo = true);
    final bytes = await picked.readAsBytes();
    final url = await CloudinaryService.instance
        .uploadInvoice(bytes, 'logo_${const Uuid().v4()}');
    if (mounted) setState(() { _logoUrl = url; _uploadingLogo = false; });
  }

  void _createStore() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final store = StoreModel(
      id: const Uuid().v4(),
      ownerId: uid,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      description: _descController.text.trim(),
      logoUrl: _logoUrl,
      category: _selectedCategory,
      status: StoreStatus.trial,
      trialEnd: DateTime.now().add(const Duration(days: 10)),
      createdAt: DateTime.now(),
    );

    await StoreService.instance.createStore(store);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('\u062a\u0633\u062c\u064a\u0644 \u0645\u062a\u062c\u0631\u0643',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // هيدر
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.storefront_outlined,
                        color: Colors.white, size: 36),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('\u0633\u062c\u0651\u0644 \u0645\u062a\u062c\u0631\u0643',
                              style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                                  fontSize: 18, fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          Text('\u062a\u062c\u0631\u064a\u0628\u064a \u0645\u062c\u0627\u0646\u064a 10 \u0623\u064a\u0627\u0645 \ud83c\udf89',
                              style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                                  fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 28),

              // صورة المتجر
              Center(
                child: GestureDetector(
                  onTap: _pickLogo,
                  child: Stack(
                    children: [
                      Container(
                        width: 110, height: 110,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _logoUrl != null
                                ? AppColors.secondary
                                : AppColors.primary.withValues(alpha: 0.3),
                            width: 2.5,
                          ),
                        ),
                        child: _uploadingLogo
                            ? const Center(child: CircularProgressIndicator(
                                color: AppColors.primary, strokeWidth: 2))
                            : _logoUrl != null
                                ? ClipOval(
                                    child: Image.network(_logoUrl!,
                                        fit: BoxFit.cover,
                                        width: 110, height: 110))
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.storefront_rounded,
                                          color: AppColors.primary, size: 36),
                                      SizedBox(height: 4),
                                      Text('\u0635\u0648\u0631\u0629',
                                          style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                                              fontSize: 10,
                                              color: AppColors.primary)),
                                    ],
                                  ),
                      ),
                      Positioned(
                        bottom: 2, left: 2,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms).scale(
                  begin: const Offset(0.8, 0.8)),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _logoUrl != null
                      ? '\u062a\u0645 \u0631\u0641\u0639 \u0627\u0644\u0635\u0648\u0631\u0629 \u2705'
                      : '\u0627\u0636\u063a\u0637 \u0644\u0625\u0636\u0627\u0641\u0629 \u0635\u0648\u0631\u0629 \u0627\u0644\u0645\u062a\u062c\u0631 (\u0627\u062e\u062a\u064a\u0627\u0631\u064a)',
                  style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                    fontSize: 12,
                    color: _logoUrl != null
                        ? AppColors.statusDelivered
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('\u0627\u0633\u0645 \u0627\u0644\u0645\u062a\u062c\u0631 *'),
              const SizedBox(height: 8),
              _buildField(
                controller: _nameController,
                hint: '\u0645\u062b\u0627\u0644: \u0645\u062a\u062c\u0631 \u0623\u0628\u0648 \u0639\u0644\u064a',
                icon: Icons.storefront_outlined,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? '\u0623\u062f\u062e\u0644 \u0627\u0633\u0645 \u0627\u0644\u0645\u062a\u062c\u0631' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('\u0631\u0642\u0645 \u0627\u0644\u0648\u0627\u062a\u0633\u0627\u0628 *'),
              const SizedBox(height: 8),
              _buildField(
                controller: _phoneController,
                hint: '0931xxxxxx',
                icon: Icons.phone_outlined,
                ltr: true,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return '\u0623\u062f\u062e\u0644 \u0631\u0642\u0645 \u0627\u0644\u0648\u0627\u062a\u0633\u0627\u0628';
                  }
                  if (v.replaceAll(RegExp(r'\D'), '').length < 7) {
                    return '\u0631\u0642\u0645 \u063a\u064a\u0631 \u0635\u062d\u064a\u062d';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildLabel('\u0648\u0635\u0641 \u0627\u0644\u0645\u062a\u062c\u0631 (\u0627\u062e\u062a\u064a\u0627\u0631\u064a)'),
              const SizedBox(height: 8),
              _buildField(
                controller: _descController,
                hint: '\u0645\u062b\u0627\u0644: \u0628\u0642\u0627\u0644\u0629 \u0634\u0627\u0645\u0644\u0629 \u0641\u064a \u0645\u0639\u0631\u0628\u0627',
                icon: Icons.description_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              _buildCategorySelector(),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _createStore,
                  child: _loading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.storefront_rounded,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('\u0625\u0646\u0634\u0627\u0621 \u0627\u0644\u0645\u062a\u062c\u0631',
                                style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                                    fontSize: 17, fontWeight: FontWeight.w700)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
          fontSize: 14, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary));

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

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: StoreCategories.all.map((cat) {
        final isSelected = _selectedCategory == cat['id'];
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat['id']!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.secondary : AppColors.divider,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(cat['icon']!, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(cat['label']!,
                    style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
