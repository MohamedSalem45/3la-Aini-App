import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String id;
  final String orderId;
  final String userId;
  final String storeId;
  final int rating; // 1-5
  final String comment;
  final List<String> images;
  final DateTime createdAt;
  final String driverName;
  final int driverRating; // 1-5

  RatingModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.storeId,
    required this.rating,
    required this.comment,
    required this.images,
    required this.createdAt,
    required this.driverName,
    required this.driverRating,
  });

  factory RatingModel.fromMap(Map<String, dynamic> map, String docId) {
    return RatingModel(
      id: docId,
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      storeId: map['storeId'] ?? '',
      rating: map['rating'] ?? 0,
      comment: map['comment'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      driverName: map['driverName'] ?? '',
      driverRating: map['driverRating'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'storeId': storeId,
      'rating': rating,
      'comment': comment,
      'images': images,
      'createdAt': Timestamp.fromDate(createdAt),
      'driverName': driverName,
      'driverRating': driverRating,
    };
  }

  RatingModel copyWith({
    String? id,
    String? orderId,
    String? userId,
    String? storeId,
    int? rating,
    String? comment,
    List<String>? images,
    DateTime? createdAt,
    String? driverName,
    int? driverRating,
  }) {
    return RatingModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      storeId: storeId ?? this.storeId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      driverName: driverName ?? this.driverName,
      driverRating: driverRating ?? this.driverRating,
    );
  }
}
