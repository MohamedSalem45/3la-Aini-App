enum StoreOrderStatus {
  pending,    // بانتظار المتجر
  accepted,   // قبل المتجر
  rejected,   // رفض منتج
  ready,      // جاهز للتوصيل
  delivered,  // تم التسليم
}

extension StoreOrderStatusExt on StoreOrderStatus {
  String get label {
    switch (this) {
      case StoreOrderStatus.pending: return '\u0628\u0627\u0646\u062a\u0638\u0627\u0631 \u0627\u0644\u0645\u062a\u062c\u0631';
      case StoreOrderStatus.accepted: return '\u062a\u0645 \u0627\u0644\u0642\u0628\u0648\u0644 \u2705';
      case StoreOrderStatus.rejected: return '\u0645\u0646\u062a\u062c \u063a\u064a\u0631 \u0645\u062a\u0648\u0641\u0631';
      case StoreOrderStatus.ready: return '\u062c\u0627\u0647\u0632 \u0644\u0644\u062a\u0648\u0635\u064a\u0644 \ud83d\udce6';
      case StoreOrderStatus.delivered: return '\u062a\u0645 \u0627\u0644\u062a\u0633\u0644\u064a\u0645 \ud83c\udf89';
    }
  }
}

class CartItem {
  final String productId;
  final String productName;
  final double price;
  int quantity;

  CartItem({
    required this.productId, required this.productName,
    required this.price, this.quantity = 1,
  });

  double get total => price * quantity;

  Map<String, dynamic> toMap() => {
    'productId': productId, 'productName': productName,
    'price': price, 'quantity': quantity,
  };

  factory CartItem.fromMap(Map<String, dynamic> m) => CartItem(
    productId: m['productId'] ?? '',
    productName: m['productName'] ?? '',
    price: (m['price'] ?? 0).toDouble(),
    quantity: m['quantity'] ?? 1,
  );
}

class StoreOrderMessage {
  final String text;
  final bool fromStore;
  final DateTime sentAt;

  const StoreOrderMessage({
    required this.text, required this.fromStore, required this.sentAt,
  });

  Map<String, dynamic> toMap() => {
    'text': text, 'fromStore': fromStore,
    'sentAt': sentAt.toIso8601String(),
  };

  factory StoreOrderMessage.fromMap(Map<String, dynamic> m) => StoreOrderMessage(
    text: m['text'] ?? '', fromStore: m['fromStore'] ?? false,
    sentAt: DateTime.parse(m['sentAt']),
  );
}

class StoreOrderModel {
  final String id;
  final String storeId;
  final String storeName;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final List<CartItem> items;
  final StoreOrderStatus status;
  final String? invoiceUrl;
  final List<StoreOrderMessage> messages;
  final DateTime createdAt;

  const StoreOrderModel({
    required this.id, required this.storeId, required this.storeName,
    required this.customerId, required this.customerName,
    required this.customerPhone, required this.deliveryAddress,
    required this.items, this.status = StoreOrderStatus.pending,
    this.invoiceUrl, this.messages = const [], required this.createdAt,
  });

  double get totalPrice => items.fold(0, (sum, i) => sum + i.total);

  StoreOrderModel copyWith({
    StoreOrderStatus? status, String? invoiceUrl,
    List<StoreOrderMessage>? messages,
  }) => StoreOrderModel(
    id: id, storeId: storeId, storeName: storeName,
    customerId: customerId, customerName: customerName,
    customerPhone: customerPhone, deliveryAddress: deliveryAddress,
    items: items, status: status ?? this.status,
    invoiceUrl: invoiceUrl ?? this.invoiceUrl,
    messages: messages ?? this.messages,
    createdAt: createdAt,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'storeId': storeId, 'storeName': storeName,
    'customerId': customerId, 'customerName': customerName,
    'customerPhone': customerPhone, 'deliveryAddress': deliveryAddress,
    'items': items.map((i) => i.toMap()).toList(),
    'status': status.name,
    'invoiceUrl': invoiceUrl,
    'messages': messages.map((m) => m.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory StoreOrderModel.fromMap(Map<String, dynamic> m) => StoreOrderModel(
    id: m['id'] ?? '', storeId: m['storeId'] ?? '',
    storeName: m['storeName'] ?? '',
    customerId: m['customerId'] ?? '', customerName: m['customerName'] ?? '',
    customerPhone: m['customerPhone'] ?? '',
    deliveryAddress: m['deliveryAddress'] ?? '',
    items: (m['items'] as List? ?? [])
        .map((i) => CartItem.fromMap(i)).toList(),
    status: StoreOrderStatus.values.firstWhere(
      (e) => e.name == m['status'], orElse: () => StoreOrderStatus.pending),
    invoiceUrl: m['invoiceUrl'],
    messages: (m['messages'] as List? ?? [])
        .map((msg) => StoreOrderMessage.fromMap(msg)).toList(),
    createdAt: DateTime.parse(m['createdAt']),
  );
}
