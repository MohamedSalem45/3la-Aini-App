import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum OrderStatus {
  newOrder,
  shopping,
  purchased,
  onTheWay,
  delivered,
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.newOrder:
        return 'طلب جديد';
      case OrderStatus.shopping:
        return 'قيد التسوق 🛒';
      case OrderStatus.purchased:
        return 'تم الشراء ✅';
      case OrderStatus.onTheWay:
        return 'في الطريق إليك 🚗';
      case OrderStatus.delivered:
        return 'تم التسليم 🎉';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.newOrder:
        return AppColors.statusNew;
      case OrderStatus.shopping:
        return AppColors.statusShopping;
      case OrderStatus.purchased:
        return AppColors.statusPurchased;
      case OrderStatus.onTheWay:
        return AppColors.statusOnWay;
      case OrderStatus.delivered:
        return AppColors.statusDelivered;
    }
  }

  int get step => index; // 0..4 للـ progress indicator
}

class OrderModel {
  final String id;
  final int? orderNumber;
  final String customerName;
  final String phoneNumber;
  final String deliveryAddress;
  final String itemsText; // قائمة المشتريات كنص حر
  final OrderStatus status;
  final String? invoiceImageUrl; // رابط صورة الفاتورة (Firebase Storage)
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    this.orderNumber,
    required this.customerName,
    required this.phoneNumber,
    required this.deliveryAddress,
    required this.itemsText,
    this.status = OrderStatus.newOrder,
    this.invoiceImageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  OrderModel copyWith({
    int? orderNumber,
    String? phoneNumber,
    OrderStatus? status,
    String? invoiceImageUrl,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      deliveryAddress: deliveryAddress,
      itemsText: itemsText,
      status: status ?? this.status,
      invoiceImageUrl: invoiceImageUrl ?? this.invoiceImageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // جاهز للدمج مع Firestore لاحقاً
  Map<String, dynamic> toMap() => {
        'id': id,
        'orderNumber': orderNumber,
        'customerName': customerName,
        'phoneNumber': phoneNumber,
        'deliveryAddress': deliveryAddress,
        'itemsText': itemsText,
        'status': status.name,
        'invoiceImageUrl': invoiceImageUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory OrderModel.fromMap(Map<String, dynamic> map) => OrderModel(
        id: map['id'] as String? ?? '',
        orderNumber: map['orderNumber'] as int?,
        customerName: map['customerName'] as String? ?? '',
        phoneNumber: map['phoneNumber'] as String? ?? '',
        deliveryAddress: map['deliveryAddress'] as String? ?? '',
        itemsText: map['itemsText'] as String? ?? '',
        status: OrderStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => OrderStatus.newOrder,
        ),
        invoiceImageUrl: map['invoiceImageUrl'] as String?,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : DateTime.now(),
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : null,
      );
}
