import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- الأزرق الداكن (اللون الأساسي من الشعار) ---
  static const primary = Color(0xFF1B3A6B);
  static const primaryLight = Color(0xFF2A5298);
  static const primaryDark = Color(0xFF0F2347);

  // --- الذهبي (اللون الثانوي من الشعار) ---
  static const secondary = Color(0xFFB8922A);
  static const secondaryLight = Color(0xFFD4A853);
  static const secondaryDark = Color(0xFF8B6914);

  // --- خلفيات ---
  static const background = Color(0xFFF4F6FB);  // أزرق فاتح جداً
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFEEF2FA); // أزرق فاتح للحقول

  // --- حالات الطلب ---
  static const statusNew = Color(0xFF2A5298);       // أزرق: جديد
  static const statusShopping = Color(0xFFB8922A);  // ذهبي: قيد التسوق
  static const statusPurchased = Color(0xFF6B4EAA); // بنفسجي: تم الشراء
  static const statusOnWay = Color(0xFFE07B2A);     // برتقالي: في الطريق
  static const statusDelivered = Color(0xFF2E7D52); // أخضر: تم التسليم

  // --- نصوص ---
  static const textPrimary = Color(0xFF0F2347);
  static const textSecondary = Color(0xFF5A6A8A);
  static const textHint = Color(0xFFAABBCC);

  // --- متفرقات ---
  static const divider = Color(0xFFDDE4F0);
  static const shadow = Color(0x1A1B3A6B);
}
