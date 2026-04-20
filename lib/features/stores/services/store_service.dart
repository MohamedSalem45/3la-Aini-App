import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/store_model.dart';
import '../models/store_order_model.dart';

class StoreService {
  StoreService._();
  static final StoreService instance = StoreService._();

  final _db = FirebaseFirestore.instance;
  CollectionReference get _stores => _db.collection('stores');
  CollectionReference get _storeOrders => _db.collection('store_orders');

  // ===== المتاجر =====

  Future<void> createStore(StoreModel store) async {
    await _stores.doc(store.id).set(store.toMap());
  }

  Stream<List<StoreModel>> watchActiveStores() {
    return _stores.snapshots().map((s) => s.docs
        .map((d) => StoreModel.fromMap(d.data() as Map<String, dynamic>))
        .where((store) => store.isAccessible && store.isOpen)
        .toList());
  }

  Stream<List<StoreModel>> watchAllActiveStores() {
    return _stores.snapshots().map((s) => s.docs
        .map((d) => StoreModel.fromMap(d.data() as Map<String, dynamic>))
        .where((store) => store.isAccessible)
        .toList());
  }

  Stream<StoreModel?> watchMyStore(String ownerId) {
    return _stores
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((s) => s.docs.isEmpty
            ? null
            : StoreModel.fromMap(s.docs.first.data() as Map<String, dynamic>));
  }

  Future<StoreModel?> getStoreById(String storeId) async {
    final doc = await _stores.doc(storeId).get();
    if (!doc.exists) return null;
    return StoreModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  // ===== الأقسام =====

  CollectionReference _categories(String storeId) =>
      _stores.doc(storeId).collection('categories');

  Future<void> addCategory(String storeId, CategoryModel cat) async {
    await _categories(storeId).doc(cat.id).set(cat.toMap());
  }

  Future<void> deleteCategory(String storeId, String catId) async {
    await _categories(storeId).doc(catId).delete();
  }

  Stream<List<CategoryModel>> watchCategories(String storeId) {
    return _categories(storeId)
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs
            .map((d) => CategoryModel.fromMap(d.data() as Map<String, dynamic>))
            .toList());
  }

  // ===== المنتجات =====

  CollectionReference _products(String storeId) =>
      _stores.doc(storeId).collection('products');

  Future<void> addProduct(String storeId, ProductModel product) async {
    await _products(storeId).doc(product.id).set(product.toMap());
  }

  Future<void> updateProduct(String storeId, ProductModel product) async {
    await _products(storeId).doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String storeId, String productId) async {
    await _products(storeId).doc(productId).delete();
  }

  Stream<List<ProductModel>> watchProducts(String storeId, String categoryId) {
    return _products(storeId)
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((s) => s.docs
            .map((d) => ProductModel.fromMap(d.data() as Map<String, dynamic>))
            .toList());
  }

  // ===== الطلبات =====

  Future<void> placeOrder(StoreOrderModel order) async {
    await _storeOrders.doc(order.id).set(order.toMap());
  }

  Stream<List<StoreOrderModel>> watchStoreOrders(String storeId) {
    return _storeOrders
        .where('storeId', isEqualTo: storeId)
        .snapshots()
        .map((s) => s.docs
            .map((d) => StoreOrderModel.fromMap(d.data() as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  Stream<List<StoreOrderModel>> watchCustomerOrders(String customerId) {
    return _storeOrders
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((s) => s.docs
            .map((d) => StoreOrderModel.fromMap(d.data() as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  Future<void> updateOrderStatus(String orderId, StoreOrderStatus status) async {
    await _storeOrders.doc(orderId).update({'status': status.name});
  }

  Future<void> sendMessage(String orderId, StoreOrderMessage msg) async {
    final doc = await _storeOrders.doc(orderId).get();
    final data = doc.data() as Map<String, dynamic>;
    final messages = (data['messages'] as List? ?? [])
        .map((m) => StoreOrderMessage.fromMap(m).toMap())
        .toList();
    messages.add(msg.toMap());
    await _storeOrders.doc(orderId).update({'messages': messages});
  }

  Future<void> uploadInvoice(String orderId, String url) async {
    await _storeOrders.doc(orderId).update({'invoiceUrl': url});
  }

  Future<void> updateStore(String storeId, Map<String, dynamic> data) async {
    await _stores.doc(storeId).update(data);
  }

  Future<void> toggleStoreOpen(String storeId, bool isOpen) async {
    await _stores.doc(storeId).update({'isOpen': isOpen});
  }

  // ===== الاشتراكات (Admin) =====

  Stream<List<StoreModel>> watchAllStores() {
    return _stores.snapshots().map((s) => s.docs
        .map((d) => StoreModel.fromMap(d.data() as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name)));
  }

  Future<void> activateSubscription(String storeId, int months) async {
    final now = DateTime.now();
    final end = now.add(Duration(days: months * 30));
    await _stores.doc(storeId).update({
      'status': StoreStatus.active.name,
      'subscriptionEnd': end.toIso8601String(),
    });
  }

  Future<void> suspendStore(String storeId) async {
    await _stores.doc(storeId).update({'status': StoreStatus.suspended.name});
  }

  // تحقق تلقائي من انتهاء الاشتراكات
  Future<void> checkExpiredSubscriptions() async {
    final now = DateTime.now();
    final snap = await _stores.get();
    for (final doc in snap.docs) {
      final store = StoreModel.fromMap(doc.data() as Map<String, dynamic>);
      if (store.status == StoreStatus.active &&
          store.subscriptionEnd != null &&
          store.subscriptionEnd!.isBefore(now)) {
        await _stores.doc(store.id).update({'status': StoreStatus.expired.name});
      }
      if (store.status == StoreStatus.trial &&
          store.trialEnd.isBefore(now)) {
        await _stores.doc(store.id).update({'status': StoreStatus.expired.name});
      }
    }
  }
}
