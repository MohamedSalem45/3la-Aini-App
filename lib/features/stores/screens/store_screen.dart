import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/store_model.dart';
import '../models/store_order_model.dart';
import '../services/store_service.dart';
import '../../profile/services/profile_service.dart';
import 'cart_screen.dart';
import '../../../core/constants/app_colors.dart';

class StoreScreen extends StatefulWidget {
  final StoreModel store;
  const StoreScreen({super.key, required this.store});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final Map<String, int> _cart = {}; // productId → quantity
  final Map<String, ProductModel> _products = {};
  String? _selectedCategoryId;
  bool _isFavorite = false;
  bool _favoriteLoading = false;

  int get _cartCount => _cart.values.fold(0, (s, q) => s + q);
  double get _cartTotal => _cart.entries.fold(0, (s, e) {
        final p = _products[e.key];
        return s + (p?.price ?? 0) * e.value;
      });

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
    if (_favoriteLoading) return;

    setState(() => _favoriteLoading = true);
    try {
      if (_isFavorite) {
        await ProfileService.instance
            .removeFromFavorites(widget.store.id, 'store');
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
      setState(() => _favoriteLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: StreamBuilder<List<CategoryModel>>(
          stream: StoreService.instance.watchCategories(widget.store.id),
          builder: (context, catSnap) {
            final categories = catSnap.data ?? [];
            if (categories.isNotEmpty && _selectedCategoryId == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() => _selectedCategoryId = categories.first.id);
                }
              });
            }
            return CustomScrollView(
              slivers: [
                _buildAppBar(context),
                SliverToBoxAdapter(child: _buildCategoryTabs(categories)),
                if (_selectedCategoryId != null)
                  _buildProductsGrid(_selectedCategoryId!),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
        bottomNavigationBar: _cartCount > 0 ? _buildCartBar(context) : null,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward_ios_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          onPressed: _favoriteLoading ? null : _toggleFavorite,
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : Colors.white,
            size: 24,
          ),
          tooltip: _isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            widget.store.logoUrl != null
                ? Image.network(widget.store.logoUrl!, fit: BoxFit.cover)
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                  ),
            Container(color: Colors.black.withValues(alpha: 0.4)),
            Positioned(
              bottom: 16,
              right: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.store.name,
                      style: const TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  if (widget.store.description.isNotEmpty)
                    Text(widget.store.description,
                        style: const TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 13,
                            color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(List<CategoryModel> categories) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final cat = categories[i];
          final isSelected = _selectedCategoryId == cat.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryId = cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.primary : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(cat.name,
                      style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsGrid(String categoryId) {
    return StreamBuilder<List<ProductModel>>(
      stream: StoreService.instance.watchProducts(widget.store.id, categoryId),
      builder: (context, snap) {
        final products = snap.data ?? [];
        // حفظ المنتجات للسلة
        for (final p in products) {
          _products[p.id] = p;
        }

        if (products.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                    '\u0645\u0627 \u0641\u064a \u0645\u0646\u062a\u062c\u0627\u062a \u0628\u0647\u0627\u0644\u0642\u0633\u0645',
                    style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        color: AppColors.textHint)),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _ProductCard(
                product: products[i],
                quantity: _cart[products[i].id] ?? 0,
                onAdd: () => setState(() =>
                    _cart[products[i].id] = (_cart[products[i].id] ?? 0) + 1),
                onRemove: () => setState(() {
                  final q = (_cart[products[i].id] ?? 0) - 1;
                  if (q <= 0) {
                    _cart.remove(products[i].id);
                  } else {
                    _cart[products[i].id] = q;
                  }
                }),
              ).animate().fadeIn(delay: Duration(milliseconds: i * 60)),
              childCount: products.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _goToCart(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$_cartCount',
                  style: const TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
            const Text('\u0639\u0631\u0636 \u0627\u0644\u0633\u0644\u0629',
                style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            Text('${_cartTotal.toStringAsFixed(0)} \u0644.\u0633',
                style: const TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  void _goToCart(BuildContext context) {
    final items = _cart.entries.map((e) {
      final p = _products[e.key]!;
      return CartItem(
        productId: p.id,
        productName: p.name,
        price: p.price,
        quantity: e.value,
      );
    }).toList();

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CartScreen(store: widget.store, items: items),
        ));
  }
}

class _ProductCard extends StatefulWidget {
  final ProductModel product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _ProductCard({
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isFavorite = false;
  bool _favoriteLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final isFav = await ProfileService.instance
          .isFavorite(widget.product.id, 'product');
      if (mounted) {
        setState(() => _isFavorite = isFav);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _toggleFavorite() async {
    if (_favoriteLoading) return;

    setState(() => _favoriteLoading = true);
    try {
      if (_isFavorite) {
        await ProfileService.instance
            .removeFromFavorites(widget.product.id, 'product');
        setState(() => _isFavorite = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إزالة المنتج من المفضلة')),
        );
      } else {
        await ProfileService.instance.addToFavorites(
          widget.product.id,
          'product',
          itemName: widget.product.name,
          itemImageUrl: widget.product.imageUrl,
        );
        setState(() => _isFavorite = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة المنتج إلى المفضلة')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحديث المفضلة: $e')),
      );
    } finally {
      setState(() => _favoriteLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المنتج مع زر المفضلة
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: widget.product.imageUrl != null
                      ? Image.network(widget.product.imageUrl!,
                          width: double.infinity, fit: BoxFit.cover)
                      : Container(
                          color: AppColors.surfaceVariant,
                          child: const Center(
                              child: Icon(Icons.image_outlined,
                                  color: AppColors.textHint, size: 36))),
                ),
                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _favoriteLoading ? null : _toggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.grey,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('${widget.product.price.toStringAsFixed(0)} \u0644.\u0633',
                    style: const TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
                const SizedBox(height: 8),
                // أزرار الإضافة
                if (!widget.product.isAvailable)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                        '\u063a\u064a\u0631 \u0645\u062a\u0648\u0641\u0631',
                        style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 11,
                            color: Colors.red)),
                  )
                else if (widget.quantity == 0)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onAdd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('\u0623\u0636\u0641',
                          style: TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _QtyButton(icon: Icons.remove, onTap: widget.onRemove),
                      Text('${widget.quantity}',
                          style: const TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      _QtyButton(
                          icon: Icons.add,
                          onTap: widget.onAdd,
                          color: AppColors.primary),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    this.color = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
