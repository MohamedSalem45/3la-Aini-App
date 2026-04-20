import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/store_model.dart';
import '../models/store_order_model.dart';

class StoreService {
  StoreService._();
  static final StoreService instance = StoreService._();

  final _db = FirebaseFirestore.instance;
  CollectionReference get _stores => _db.collection('stores');
  CollectionReference get _storeOrders => _db.collection('store_orders');

  // ==================== المتاجر (Stores) ====================

  Future<void> createStore(StoreModel store) async {
    await _stores.doc(store.id).set(store.toMap());
  }

  // جلب المتاجر المفتوحة والمتاحة فقط (تحسين: الفلترة في السيرفر)
  Stream<List<StoreModel>> watchActiveStores() {
    return _stores
        .where('isAccessible', isEqualTo: true)
        .where('isOpen', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => StoreModel.fromMap(d.data() as Map<String, dynamic>))
            .toList());
  }

  // جلب كل المتاجر المتاحة (حتى لو كانت مغلقة حالياً)
  Stream<List<StoreModel>> watchAllActiveStores() {
    return _stores.where('isAccessible', isEqualTo: true).snapshots().map((s) =>
        s.docs
            .map((d) => StoreModel.fromMap(d.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<StoreModel?> watchMyStore(String ownerId) {
    return _stores.where('ownerId', isEqualTo: ownerId).snapshots().map((s) =>
        s.docs.isEmpty
            ? null
            : StoreModel.fromMap(s.docs.first.data() as Map<String, dynamic>));
  }

  Future<StoreModel?> getStoreById(String storeId) async {
    final doc = await _stores.doc(storeId).get();
    if (!doc.exists) return null;
    return StoreModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  // ==================== الأقسام والمنتجات ====================

  CollectionReference _categories(String storeId) =>
      _stores.doc(storeId).collection('categories');

  CollectionReference _products(String storeId) =>
      _stores.doc(storeId).collection('products');

  Future<void> addCategory(String storeId, CategoryModel cat) async {
    await _categories(storeId).doc(cat.id).set(cat.toMap());
  }

  Stream<List<CategoryModel>> watchCategories(String storeId) {
    return _categories(storeId).orderBy('order').snapshots().map((s) => s.docs
        .map((d) => CategoryModel.fromMap(d.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> addProduct(String storeId, ProductModel product) async {
    await _products(storeId).doc(product.id).set(product.toMap());
  }

  Stream<List<ProductModel>> watchProducts(String storeId, String categoryId) {
    return _products(storeId)
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((s) => s.docs
            .map((d) => ProductModel.fromMap(d.data() as Map<String, dynamic>))
            .toList());
  }

  // ==================== نظام الطلبات والمحادثة ====================

  Future<void> placeOrder(StoreOrderModel order) async {
    await _storeOrders.doc(order.id).set({
      ...order.toMap(),
      'createdAt': FieldValue.serverTimestamp(), // توقيت السيرفر
    });
  }

  // تحسين إرسال الرسائل باستخدام Atomic Update
  Future<void> sendMessage(String orderId, StoreOrderMessage msg) async {
    await _storeOrders.doc(orderId).update({
      'messages': FieldValue.arrayUnion([msg.toMap()])
    });
  }

  Future<void> updateOrderStatus(
      String orderId, StoreOrderStatus status) async {
    await _storeOrders.doc(orderId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== نظام الاشتراكات والتحكم (Admin) ====================

  // تحسين: فحص الاشتراكات المنتهية فقط بدلاً من جلب كل المتاجر
  Future<void> checkExpiredSubscriptions() async {
    final now = DateTime.now().toIso8601String();

    // فحص اشتراكات Trial المنتهية
    final trialSnap = await _stores
        .where('status', isEqualTo: StoreStatus.trial.name)
        .where('trialEnd', isLessThan: now)
        .get();

    // فحص اشتراكات Active المنتهية
    final activeSnap = await _stores
        .where('status', isEqualTo: StoreStatus.active.name)
        .where('subscriptionEnd', isLessThan: now)
        .get();

    final batch = _db.batch();
    for (var doc in [...trialSnap.docs, ...activeSnap.docs]) {
      batch.update(doc.reference, {'status': StoreStatus.expired.name});
    }
    await batch.commit();
  }

  Future<void> toggleStoreOpen(String storeId, bool isOpen) async {
    await _stores.doc(storeId).update({'isOpen': isOpen});
  }

  Future<void> updateStore(String storeId, Map<String, dynamic> data) async {
    await _stores.doc(storeId).update(data);
  }
}
