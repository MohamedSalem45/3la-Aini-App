import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/store_model.dart';
import '../../services/store_service.dart';
import '../../../../../core/services/cloudinary_service.dart';
import '../../../../../core/constants/app_colors.dart';

class OwnerEditStoreScreen extends StatefulWidget {
  final StoreModel store;
  const OwnerEditStoreScreen({super.key, required this.store});

  @override
  State<OwnerEditStoreScreen> createState() => _OwnerEditStoreScreenState();
}

class _OwnerEditStoreScreenState extends State<OwnerEditStoreScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _descCtrl;
  String? _logoUrl;
  bool _uploadingLogo = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.store.name);
    _phoneCtrl = TextEditingController(text: widget.store.phone);
    _descCtrl = TextEditingController(text: widget.store.description);
    _logoUrl = widget.store.logoUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _descCtrl.dispose();
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
        .uploadInvoice(bytes, 'logo_${widget.store.id}');
    setState(() { _logoUrl = url; _uploadingLogo = false; });
  }

  void _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);

    await StoreService.instance.updateStore(widget.store.id, {
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      if (_logoUrl != null) 'logoUrl': _logoUrl,
    });

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('\u062a\u0645 \u062d\u0641\u0638 \u0627\u0644\u062a\u0639\u062f\u064a\u0644\u0627\u062a \u2705',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', )),
        backgroundColor: AppColors.statusDelivered,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('\u062a\u0639\u062f\u064a\u0644 \u0628\u064a\u0627\u0646\u0627\u062a \u0627\u0644\u0645\u062a\u062c\u0631',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
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
            // لوغو المتجر
            Center(
              child: GestureDetector(
                onTap: _pickLogo,
                child: Stack(
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 2),
                      ),
                      child: _uploadingLogo
                          ? const Center(child: CircularProgressIndicator(
                              color: AppColors.primary, strokeWidth: 2))
                          : _logoUrl != null
                              ? ClipOval(child: Image.network(
                                  _logoUrl!, fit: BoxFit.cover,
                                  width: 100, height: 100))
                              : const Icon(Icons.storefront_rounded,
                                  color: AppColors.primary, size: 40),
                    ),
                    Positioned(
                      bottom: 0, left: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
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
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 8),
            const Center(
              child: Text('\u0627\u0636\u063a\u0637 \u0644\u062a\u063a\u064a\u064a\u0631 \u0627\u0644\u0634\u0639\u0627\u0631',
                  style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                      fontSize: 12, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 28),

            _buildLabel('\u0627\u0633\u0645 \u0627\u0644\u0645\u062a\u062c\u0631'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 15),
              decoration: const InputDecoration(
                hintText: '\u0627\u0633\u0645 \u0645\u062a\u062c\u0631\u0643',
                prefixIcon: Icon(Icons.storefront_outlined,
                    color: AppColors.primary, size: 20),
              ),
            ),
            const SizedBox(height: 16),

            _buildLabel('\u0631\u0642\u0645 \u0627\u0644\u0648\u0627\u062a\u0633\u0627\u0628'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 15),
              decoration: const InputDecoration(
                hintText: '0931xxxxxx',
                prefixIcon: Icon(Icons.phone_outlined,
                    color: AppColors.primary, size: 20),
              ),
            ),
            const SizedBox(height: 16),

            _buildLabel('\u0648\u0635\u0641 \u0627\u0644\u0645\u062a\u062c\u0631'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              textDirection: TextDirection.rtl,
              maxLines: 3,
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 14),
              decoration: const InputDecoration(
                hintText: '\u0627\u0643\u062a\u0628 \u0648\u0635\u0641\u0627\u064b \u0645\u062e\u062a\u0635\u0631\u0627\u064b \u0644\u0645\u062a\u062c\u0631\u0643...',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.description_outlined,
                      color: AppColors.textSecondary, size: 20)),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('\u062d\u0641\u0638 \u0627\u0644\u062a\u0639\u062f\u064a\u0644\u0627\u062a',
                        style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                            fontSize: 16, fontWeight: FontWeight.w700)),
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
