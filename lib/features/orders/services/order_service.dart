import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';

class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();

  final _col = FirebaseFirestore.instance.collection('orders');

  // إضافة طلب جديد مع عداد تسلسلي
  Future<void> addOrder(OrderModel order) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final counterRef =
        FirebaseFirestore.instance.collection('meta').doc('counter');
    final orderRef = _col.doc(order.id);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final counterSnap = await tx.get(counterRef);
      final nextNumber =
          (counterSnap.exists ? (counterSnap.data()?['orderCount'] ?? 0) : 0) +
              1;

      tx.set(counterRef, {'orderCount': nextNumber}, SetOptions(merge: true));
      tx.set(orderRef, {
        ...order.toMap(),
        'orderNumber': nextNumber,
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(), // توقيت السيرفر لضمان الدقة
      });
    });
  }

  // جلب الطلبات النشطة (التي لم تسلم بعد) - فلترة على مستوى السيرفر
  Stream<List<OrderModel>> watchActiveOrders() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _col
        .where('uid', isEqualTo: uid)
        .where('status',
            isNotEqualTo: 'delivered') // الفلترة هنا توفر في استهلاك البيانات
        .snapshots()
        .map((s) => s.docs.map((d) => OrderModel.fromMap(d.data())).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  // جلب آخر طلب تم تسليمه فقط - فعال جداً في التكلفة
  Stream<OrderModel?> watchLastDelivered() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _col
        .where('uid', isEqualTo: uid)
        .where('status', isEqualTo: 'delivered')
        .orderBy('createdAt', descending: true)
        .limit(1) // يطلب سطر واحد فقط من السيرفر
        .snapshots()
        .map((s) =>
            s.docs.isEmpty ? null : OrderModel.fromMap(s.docs.first.data()));
  }

  // جلب كل الطلبات للوحة التحكم (خاص بالمتسوق/الأدمين)
  Stream<List<OrderModel>> watchAllOrders() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => OrderModel.fromMap(d.data())).toList());
  }

  // تحديث حالة الطلب
  Future<void> updateStatus(String orderId, OrderStatus status) async {
    await _col.doc(orderId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // تحديث رابط فاتورة Cloudinary
  Future<void> updateInvoiceUrl(String orderId, String url) async {
    await _col.doc(orderId).update({
      'invoiceImageUrl': url,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteOrder(String orderId) async {
    await _col.doc(orderId).delete();
  }
}
