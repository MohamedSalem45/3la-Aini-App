import 'package:flutter/material.dart';

enum StoreStatus { active, trial, expired, suspended }

extension StoreStatusExt on StoreStatus {
  String get label {
    switch (this) {
      case StoreStatus.active: return '\u0646\u0634\u0637';
      case StoreStatus.trial: return '\u062a\u062c\u0631\u064a\u0628\u064a';
      case StoreStatus.expired: return '\u0645\u0646\u062a\u0647\u064a';
      case StoreStatus.suspended: return '\u0645\u0648\u0642\u0648\u0641';
    }
  }

  Color get color {
    switch (this) {
      case StoreStatus.active: return const Color(0xFF4A7C59);
      case StoreStatus.trial: return const Color(0xFF5B8DEF);
      case StoreStatus.expired: return const Color(0xFFE74C3C);
      case StoreStatus.suspended: return const Color(0xFF95A5A6);
    }
  }
}

class StoreModel {
  final String id;
  final String ownerId;
  final String name;
  final String phone;
  final String? logoUrl;
  final String description;
  final String category;
  final StoreStatus status;
  final bool isOpen;
  final DateTime trialEnd;
  final DateTime? subscriptionEnd;
  final DateTime createdAt;

  const StoreModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.phone,
    this.logoUrl,
    this.description = '',
    this.category = 'other',
    this.status = StoreStatus.trial,
    this.isOpen = false,
    required this.trialEnd,
    this.subscriptionEnd,
    required this.createdAt,
  });

  bool get isAccessible =>
      status == StoreStatus.active || status == StoreStatus.trial;

  int get daysLeft {
    final end = status == StoreStatus.trial ? trialEnd : (subscriptionEnd ?? trialEnd);
    return end.difference(DateTime.now()).inDays.clamp(0, 999);
  }

  StoreModel copyWith({
    StoreStatus? status,
    bool? isOpen,
    DateTime? subscriptionEnd,
    String? logoUrl,
  }) => StoreModel(
    id: id, ownerId: ownerId, name: name, phone: phone,
    logoUrl: logoUrl ?? this.logoUrl,
    description: description,
    category: category,
    status: status ?? this.status,
    isOpen: isOpen ?? this.isOpen,
    trialEnd: trialEnd,
    subscriptionEnd: subscriptionEnd ?? this.subscriptionEnd,
    createdAt: createdAt,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'ownerId': ownerId, 'name': name, 'phone': phone,
    'logoUrl': logoUrl, 'description': description,
    'category': category,
    'status': status.name,
    'isOpen': isOpen,
    'trialEnd': trialEnd.toIso8601String(),
    'subscriptionEnd': subscriptionEnd?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory StoreModel.fromMap(Map<String, dynamic> m) => StoreModel(
    id: m['id'] ?? '',
    ownerId: m['ownerId'] ?? '',
    name: m['name'] ?? '',
    phone: m['phone'] ?? '',
    logoUrl: m['logoUrl'],
    description: m['description'] ?? '',
    category: m['category'] ?? 'other',
    status: StoreStatus.values.firstWhere(
      (e) => e.name == m['status'], orElse: () => StoreStatus.trial),
    isOpen: m['isOpen'] ?? false,
    trialEnd: DateTime.parse(m['trialEnd']),
    subscriptionEnd: m['subscriptionEnd'] != null
        ? DateTime.parse(m['subscriptionEnd']) : null,
    createdAt: DateTime.parse(m['createdAt']),
  );
}

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int order;

  const CategoryModel({
    required this.id, required this.name,
    this.icon = '\ud83d\udce6', this.order = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'icon': icon, 'order': order,
  };

  factory CategoryModel.fromMap(Map<String, dynamic> m) => CategoryModel(
    id: m['id'] ?? '', name: m['name'] ?? '',
    icon: m['icon'] ?? '\ud83d\udce6', order: m['order'] ?? 0,
  );
}

class ProductModel {
  final String id;
  final String categoryId;
  final String name;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final String description;

  const ProductModel({
    required this.id, required this.categoryId,
    required this.name, required this.price,
    this.imageUrl, this.isAvailable = true, this.description = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'categoryId': categoryId, 'name': name,
    'price': price, 'imageUrl': imageUrl,
    'isAvailable': isAvailable, 'description': description,
  };

  factory ProductModel.fromMap(Map<String, dynamic> m) => ProductModel(
    id: m['id'] ?? '', categoryId: m['categoryId'] ?? '',
    name: m['name'] ?? '', price: (m['price'] ?? 0).toDouble(),
    imageUrl: m['imageUrl'], isAvailable: m['isAvailable'] ?? true,
    description: m['description'] ?? '',
  );
}
