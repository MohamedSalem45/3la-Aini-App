import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../models/store_model.dart';
import '../../services/store_service.dart';
import '../../../../core/constants/app_colors.dart';
import 'owner_products_screen.dart';

class OwnerCategoriesScreen extends StatelessWidget {
  final StoreModel store;
  const OwnerCategoriesScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('\u0627\u0644\u0623\u0642\u0633\u0627\u0645',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: TextButton.icon(
              onPressed: () => _showAddCategory(context),
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              label: const Text('\u0642\u0633\u0645 \u062c\u062f\u064a\u062f',
                  style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                      color: Colors.white, fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<CategoryModel>>(
        stream: StoreService.instance.watchCategories(store.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2));
          }
          final cats = snapshot.data ?? [];
          if (cats.isEmpty) return _buildEmpty(context);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cats.length,
            itemBuilder: (_, i) => _CategoryTile(
              store: store,
              category: cats[i],
            )
                .animate()
                .fadeIn(delay: Duration(milliseconds: i * 60))
                .slideX(begin: 0.04),
          );
        },
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
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.category_outlined,
                size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text('\u0645\u0627 \u0641\u064a \u0623\u0642\u0633\u0627\u0645 \u0628\u0639\u062f',
              style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('\u0623\u0636\u0641 \u0623\u0642\u0633\u0627\u0645\u0627\u064b \u0644\u062a\u0646\u0638\u064a\u0645 \u0645\u0646\u062a\u062c\u0627\u062a\u0643',
              style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showAddCategory(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('\u0623\u0636\u0641 \u0642\u0633\u0645\u0627\u064b',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategory(BuildContext context) {
    final nameCtrl = TextEditingController();
    String selectedIcon = '\ud83d\udce6';
    final icons = [
      '\ud83d\udce6', '\ud83c\udf5e', '\ud83e\udd69', '\ud83e\uddc4',
      '\ud83e\uddfc', '\ud83e\udd64', '\ud83d\udc8a', '\ud83e\uddf9',
      '\ud83d\udc57', '\ud83d\udcbb', '\ud83c\udf3f', '\ud83e\udd6c',
      '\ud83c\udf4e', '\ud83e\udd5b', '\ud83c\udf6b', '\ud83e\uddc2',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          padding: EdgeInsets.fromLTRB(
              24, 8, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const Text('\u0642\u0633\u0645 \u062c\u062f\u064a\u062f',
                  style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                      fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameCtrl,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 15),
                decoration: const InputDecoration(
                  hintText: '\u0645\u062b\u0627\u0644: \u063a\u0630\u0627\u0626\u064a\u0627\u062a \u2022 \u0645\u0646\u0638\u0641\u0627\u062a \u2022 \u0645\u0641\u0631\u0632\u0627\u062a',
                  prefixIcon: Icon(Icons.label_outline,
                      color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 20),
              const Text('\u0627\u062e\u062a\u0631 \u0623\u064a\u0642\u0648\u0646\u0629',
                  style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: icons.map((ic) => GestureDetector(
                  onTap: () => setS(() => selectedIcon = ic),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: selectedIcon == ic
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: selectedIcon == ic
                          ? Border.all(color: AppColors.secondaryLight, width: 2)
                          : null,
                    ),
                    child: Center(child: Text(ic,
                        style: const TextStyle(fontSize: 22))),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    await StoreService.instance.addCategory(
                      store.id,
                      CategoryModel(
                        id: const Uuid().v4(),
                        name: nameCtrl.text.trim(),
                        icon: selectedIcon,
                      ),
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('\u0625\u0636\u0627\u0641\u0629 \u0627\u0644\u0642\u0633\u0645',
                      style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final StoreModel store;
  final CategoryModel category;

  const _CategoryTile({required this.store, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(
            color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => OwnerProductsScreen(
                  store: store, category: category))),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Text(category.icon,
                      style: const TextStyle(fontSize: 26))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name,
                          style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      const Text('\u0627\u0636\u063a\u0637 \u0644\u0625\u062f\u0627\u0631\u0629 \u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a',
                          style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                              fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('\u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a',
                          style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                              fontSize: 11, color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent, size: 20),
                      onPressed: () => _confirmDelete(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('\u062d\u0630\u0641 \u0627\u0644\u0642\u0633\u0645\u061f',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700)),
        content: Text('\u0633\u064a\u062a\u0645 \u062d\u0630\u0641 \u0642\u0633\u0645 "${category.name}" \u0648\u062c\u0645\u064a\u0639 \u0645\u0646\u062a\u062c\u0627\u062a\u0647',
            style: const TextStyle(fontFamily: 'IBMPlexSansArabic', color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('\u0625\u0644\u063a\u0627\u0621',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await StoreService.instance.deleteCategory(store.id, category.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
