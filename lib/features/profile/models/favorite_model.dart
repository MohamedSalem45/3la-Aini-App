class FavoriteModel {
  final String id;
  final String userId;
  final String itemId; // Could be storeId or productId
  final String itemType; // 'store' or 'product'
  final String? itemName;
  final String? itemImageUrl;
  final DateTime createdAt;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.itemType,
    this.itemName,
    this.itemImageUrl,
    required this.createdAt,
  });

  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    return FavoriteModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      itemId: map['itemId'] ?? '',
      itemType: map['itemType'] ?? '',
      itemName: map['itemName'],
      itemImageUrl: map['itemImageUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'itemId': itemId,
      'itemType': itemType,
      'itemName': itemName,
      'itemImageUrl': itemImageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
