import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../models/favorite_model.dart';
import '../../../core/constants/app_colors.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<FavoriteModel>>(
        stream: ProfileService.instance.getUserFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('خطأ في تحميل المفضلة: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'لا توجد عناصر مفضلة',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'اضف متاجر أو منتجات إلى مفضلتك',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Group favorites by type
          final storeFavorites =
              favorites.where((f) => f.itemType == 'store').toList();
          final productFavorites =
              favorites.where((f) => f.itemType == 'product').toList();

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'المتاجر المفضلة'),
                    Tab(text: 'المنتجات المفضلة'),
                  ],
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildFavoritesList(storeFavorites, 'store'),
                      _buildFavoritesList(productFavorites, 'product'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesList(List<FavoriteModel> favorites, String type) {
    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'store' ? Icons.store : Icons.shopping_bag,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              type == 'store' ? 'لا توجد متاجر مفضلة' : 'لا توجد منتجات مفضلة',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final favorite = favorites[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _navigateToItem(context, favorite),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Item Image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: favorite.itemImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(favorite.itemImageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Colors.grey[200],
                    ),
                    child: favorite.itemImageUrl == null
                        ? Icon(
                            type == 'store' ? Icons.store : Icons.shopping_bag,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),

                  // Item Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          favorite.itemName ?? 'عنصر غير محدد',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type == 'store' ? 'متجر' : 'منتج',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Remove from favorites
                  IconButton(
                    onPressed: () => _removeFromFavorites(favorite),
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    tooltip: 'إزالة من المفضلة',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToItem(BuildContext context, FavoriteModel favorite) {
    // TODO: Navigate to store or product details
    // This will depend on how navigation is set up in the app
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('الانتقال إلى ${favorite.itemName ?? 'العنصر'}')),
    );
  }

  Future<void> _removeFromFavorites(FavoriteModel favorite) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إزالة من المفضلة'),
        content: Text(
            'هل تريد إزالة "${favorite.itemName ?? 'هذا العنصر'}" من المفضلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('إزالة'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ProfileService.instance
            .removeFromFavorites(favorite.itemId, favorite.itemType);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إزالة العنصر من المفضلة')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في إزالة العنصر: $e')),
          );
        }
      }
    }
  }
}
