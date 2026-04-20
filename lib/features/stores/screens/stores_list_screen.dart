import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/store_model.dart';
import '../models/store_categories.dart';
import '../services/store_service.dart';
import '../../profile/services/profile_service.dart';
import 'store_screen.dart';
import '../../../core/constants/app_colors.dart';

class StoresListScreen extends StatefulWidget {
  const StoresListScreen({super.key});

  @override
  State<StoresListScreen> createState() => _StoresListScreenState();
}

class _StoresListScreenState extends State<StoresListScreen> {
  bool _showOpenOnly = true;
  String? _selectedCategory; // null = الكل

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('\u0627\u0644\u0645\u062a\u0627\u062c\u0631',
            style: TextStyle(
                fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          GestureDetector(
            onTap: () => setState(() => _showOpenOnly = !_showOpenOnly),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _showOpenOnly
                    ? AppColors.statusDelivered
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                          color: _showOpenOnly ? Colors.white : Colors.white70,
                          shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text(
                      _showOpenOnly
                          ? '\u0645\u0641\u062a\u0648\u062d\u0629 \u0641\u0642\u0637'
                          : '\u0627\u0644\u0643\u0644',
                      style: const TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<StoreModel>>(
        stream: _showOpenOnly
            ? StoreService.instance.watchActiveStores()
            : StoreService.instance.watchAllActiveStores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2));
          }

          final allStores = snapshot.data ?? [];

          // فلترة حسب التصنيف
          final stores = _selectedCategory == null
              ? allStores
              : allStores
                  .where((s) => s.category == _selectedCategory)
                  .toList();

          // استخراج التصنيفات الموجودة فعلاً
          final availableCategories =
              allStores.map((s) => s.category).toSet().toList();

          return Column(
            children: [
              // شريط التصنيفات
              if (availableCategories.isNotEmpty)
                _buildCategoryFilter(availableCategories),

              // قائمة المتاجر
              Expanded(
                child: stores.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: stores.length,
                        itemBuilder: (_, i) => _StoreCard(store: stores[i])
                            .animate()
                            .fadeIn(delay: Duration(milliseconds: i * 60))
                            .slideY(begin: 0.05),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter(List<String> categories) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // زر "الكل"
          _CategoryChip(
            label: '\u0627\u0644\u0643\u0644',
            icon: '\ud83c\udfea',
            isSelected: _selectedCategory == null,
            onTap: () => setState(() => _selectedCategory = null),
          ),
          ...categories.map((catId) => _CategoryChip(
                label: StoreCategories.labelOf(catId),
                icon: StoreCategories.iconOf(catId),
                isSelected: _selectedCategory == catId,
                onTap: () => setState(() => _selectedCategory =
                    _selectedCategory == catId ? null : catId),
              )),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront_outlined,
                size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          Text(
            _selectedCategory != null
                ? '\u0645\u0627 \u0641\u064a \u0645\u062a\u0627\u062c\u0631 \u0628\u0647\u0630\u0627 \u0627\u0644\u062a\u0635\u0646\u064a\u0641'
                : _showOpenOnly
                    ? '\u0645\u0627 \u0641\u064a \u0645\u062a\u0627\u062c\u0631 \u0645\u0641\u062a\u0648\u062d\u0629 \u0627\u0644\u0622\u0646'
                    : '\u0645\u0627 \u0641\u064a \u0645\u062a\u0627\u062c\u0631 \u0628\u0639\u062f',
            style: const TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 15,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600),
          ),
          if (_showOpenOnly) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => setState(() => _showOpenOnly = false),
              child: const Text(
                  '\u0639\u0631\u0636 \u062c\u0645\u064a\u0639 \u0627\u0644\u0645\u062a\u0627\u062c\u0631',
                  style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 13,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline)),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _StoreCard extends StatefulWidget {
  final StoreModel store;
  const _StoreCard({required this.store});

  @override
  State<_StoreCard> createState() => _StoreCardState();
}

class _StoreCardState extends State<_StoreCard> {
  bool _isFavorite = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final isFav =
          await ProfileService.instance.isFavorite(widget.store.id, 'store');
      if (mounted) {
        setState(() => _isFavorite = isFav);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _toggleFavorite() async {
    if (_loading) return;

    setState(() => _loading = true);
    try {
      if (_isFavorite) {
        await ProfileService.instance
            .removeFromFavorites(widget.store.id, 'store');
        if (!mounted) return;
        setState(() => _isFavorite = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إزالة المتجر من المفضلة')),
        );
      } else {
        await ProfileService.instance.addToFavorites(
          widget.store.id,
          'store',
          itemName: widget.store.name,
          itemImageUrl: widget.store.logoUrl,
        );
        if (!mounted) return;
        setState(() => _isFavorite = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة المتجر إلى المفضلة')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحديث المفضلة: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.store.isOpen
          ? () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => StoreScreen(store: widget.store)))
          : null,
      child: Opacity(
        opacity: widget.store.isOpen ? 1.0 : 0.6,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              // لوغو المتجر
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(20)),
                    child: widget.store.logoUrl != null
                        ? Image.network(widget.store.logoUrl!,
                            width: 90, height: 90, fit: BoxFit.cover)
                        : Container(
                            width: 90,
                            height: 90,
                            color: AppColors.primary.withValues(alpha: 0.1),
                            child: Center(
                              child: Text(
                                StoreCategories.iconOf(widget.store.category),
                                style: const TextStyle(fontSize: 36),
                              ),
                            )),
                  ),
                  // badge مفتوح/مغلق
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.store.isOpen
                            ? AppColors.statusDelivered
                            : Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.store.isOpen
                            ? '\u0645\u0641\u062a\u0648\u062d'
                            : '\u0645\u063a\u0644\u0642',
                        style: const TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.store.name,
                          style: const TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      // التصنيف
                      Row(
                        children: [
                          Text(StoreCategories.iconOf(widget.store.category),
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(StoreCategories.labelOf(widget.store.category),
                              style: const TextStyle(
                                  fontFamily: 'IBMPlexSansArabic',
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                      if (widget.store.description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(widget.store.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontFamily: 'IBMPlexSansArabic',
                                fontSize: 11,
                                color: AppColors.textHint)),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: widget.store.isOpen
                              ? AppColors.statusDelivered.withValues(alpha: 0.1)
                              : Colors.redAccent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                    color: widget.store.isOpen
                                        ? AppColors.statusDelivered
                                        : Colors.redAccent,
                                    shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text(
                              widget.store.isOpen
                                  ? '\u0645\u0641\u062a\u0648\u062d \u0627\u0644\u0622\u0646'
                                  : '\u0645\u063a\u0644\u0642 \u0645\u0624\u0642\u062a\u0627\u064b',
                              style: TextStyle(
                                  fontFamily: 'IBMPlexSansArabic',
                                  fontSize: 11,
                                  color: widget.store.isOpen
                                      ? AppColors.statusDelivered
                                      : Colors.redAccent,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Favorite button and navigation arrow
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _loading ? null : _toggleFavorite,
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.grey,
                        size: 24,
                      ),
                      tooltip: _isFavorite
                          ? 'إزالة من المفضلة'
                          : 'إضافة إلى المفضلة',
                    ),
                    Icon(
                      widget.store.isOpen
                          ? Icons.chevron_left_rounded
                          : Icons.lock_outline_rounded,
                      color: widget.store.isOpen
                          ? AppColors.textHint
                          : Colors.redAccent,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
