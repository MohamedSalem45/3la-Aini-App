import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/profile_service.dart';
import '../models/user_profile_model.dart';
import 'profile_screen.dart';
import 'order_history_screen.dart';
import 'favorites_screen.dart';
import '../../../core/constants/app_colors.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  UserProfileModel? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final profile = await ProfileService.instance.getCurrentUserProfile();
      setState(() => _profile = profile);
    } catch (e) {
      // Handle error silently
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الحساب'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('تسجيل الخروج'),
                  content: const Text('هل تريد تسجيل الخروج من التطبيق؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('تسجيل الخروج'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await FirebaseAuth.instance.signOut();
                // Navigation will be handled by AuthGate
              }
            },
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Header
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profile?.profileImageUrl != null
                        ? NetworkImage(_profile!.profileImageUrl!)
                        : null,
                    backgroundColor: AppColors.primary,
                    child: _profile?.profileImageUrl == null
                        ? Text(
                            _profile?.displayName?.isNotEmpty == true
                                ? _profile!.displayName![0].toUpperCase()
                                : user?.email?[0].toUpperCase() ?? '?',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _profile?.displayName ?? 'مستخدم',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Account Options
                  _buildMenuItem(
                    icon: Icons.person,
                    title: 'الملف الشخصي',
                    subtitle: 'تحرير معلوماتك الشخصية',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProfileScreen()),
                      );
                      _loadProfile(); // Refresh profile after editing
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildMenuItem(
                    icon: Icons.receipt_long,
                    title: 'سجل الطلبات',
                    subtitle: 'عرض طلباتك السابقة',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const OrderHistoryScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildMenuItem(
                    icon: Icons.favorite,
                    title: 'المفضلة',
                    subtitle: 'متاجرك ومنتجاتك المفضلة',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FavoritesScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildMenuItem(
                    icon: Icons.location_on,
                    title: 'العناوين المحفوظة',
                    subtitle: 'إدارة عناوين التسليم',
                    onTap: () {
                      // TODO: Implement saved addresses screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('قريباً - إدارة العناوين')),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildMenuItem(
                    icon: Icons.notifications,
                    title: 'الإشعارات',
                    subtitle: 'إعدادات الإشعارات',
                    onTap: () {
                      // TODO: Implement notifications settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('قريباً - إعدادات الإشعارات')),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildMenuItem(
                    icon: Icons.help,
                    title: 'المساعدة والدعم',
                    subtitle: 'الحصول على المساعدة',
                    onTap: () {
                      // TODO: Implement help & support
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('قريباً - المساعدة والدعم')),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildMenuItem(
                    icon: Icons.info,
                    title: 'حول التطبيق',
                    subtitle: 'معلومات عن التطبيق',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'على عيني',
                        applicationVersion: '1.0.0',
                        applicationLegalese:
                            '© 2024 على عيني. جميع الحقوق محفوظة.',
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // App Version
                  const Text(
                    'الإصدار 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
