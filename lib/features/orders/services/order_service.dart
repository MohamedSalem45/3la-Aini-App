import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';

class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();

  final _col = FirebaseFirestore.instance.collection('orders');

  Future<void> addOrder(OrderModel order) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final counterRef = FirebaseFirestore.instance.collection('meta').doc('counter');
    final orderRef = _col.doc(order.id);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final counterSnap = await tx.get(counterRef);
      final nextNumber = (counterSnap.exists ? (counterSnap.data()?['orderCount'] ?? 0) : 0) + 1;
      tx.set(counterRef, {'orderCount': nextNumber}, SetOptions(merge: true));
      tx.set(orderRef, {...order.toMap(), 'orderNumber': nextNumber, 'uid': uid});
    });
  }

  // جلب الطلبات النشطة للمستخدم الحالي فقط
  Stream<List<OrderModel>> watchActiveOrders(String customerName) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _col
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((s) => s.docs
            .map((d) => OrderModel.fromMap(d.data()))
            .where((o) => o.status != OrderStatus.delivered)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  Stream<OrderModel?> watchLastDelivered(String customerName) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _col
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((s) {
          final delivered = s.docs
              .map((d) => OrderModel.fromMap(d.data()))
              .where((o) => o.status == OrderStatus.delivered)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return delivered.isEmpty ? null : delivered.first;
        });
  }

  // كل الطلبات للوحة تحكم المتسوق
  Stream<List<OrderModel>> watchAllOrders() {
    return _col
        .snapshots()
        .map((s) => s.docs
            .map((d) => OrderModel.fromMap(d.data()))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    await _col.doc(orderId).update({
      'status': status.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateInvoiceUrl(String orderId, String url) async {
    await _col.doc(orderId).update({
      'invoiceImageUrl': url,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteOrder(String orderId) async {
    await _col.doc(orderId).delete();
  }
}
