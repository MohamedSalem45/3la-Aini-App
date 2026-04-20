import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';

class RatingService {
  static final RatingService _instance = RatingService._internal();

  factory RatingService() {
    return _instance;
  }

  RatingService._internal();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // إضافة تقييم جديد
  Future<void> addRating(RatingModel rating) async {
    try {
      await _firestore.collection('ratings').add(rating.toMap());

      // تحديث متوسط التقييم للمتجر
      await _updateStoreRating(rating.storeId);
    } catch (e) {
      // Debug: Error adding rating
      rethrow;
    }
  }

  // الحصول على تقييمات المتجر
  Stream<List<RatingModel>> getStoreRatings(String storeId) {
    return _firestore
        .collection('ratings')
        .where('storeId', isEqualTo: storeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RatingModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // الحصول على تقييمات المستخدم
  Stream<List<RatingModel>> getUserRatings(String userId) {
    return _firestore
        .collection('ratings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RatingModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // الحصول على متوسط تقييم المتجر
  Future<double> getStoreAverageRating(String storeId) async {
    try {
      final snapshot = await _firestore
          .collection('ratings')
          .where('storeId', isEqualTo: storeId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      final total = snapshot.docs.fold<int>(
        0,
        (previousSum, doc) => previousSum + (doc['rating'] as int? ?? 0),
      );

      return total / snapshot.docs.length;
    } catch (e) {
      return 0.0;
    }
  }

  // الحصول على عدد التقييمات
  Future<int> getStoreRatingCount(String storeId) async {
    try {
      final snapshot = await _firestore
          .collection('ratings')
          .where('storeId', isEqualTo: storeId)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // تحديث التقييم
  Future<void> updateRating(String ratingId, RatingModel rating) async {
    try {
      await _firestore
          .collection('ratings')
          .doc(ratingId)
          .update(rating.toMap());

      await _updateStoreRating(rating.storeId);
    } catch (e) {
      rethrow;
    }
  }

  // حذف التقييم
  Future<void> deleteRating(String ratingId, String storeId) async {
    try {
      await _firestore.collection('ratings').doc(ratingId).delete();

      await _updateStoreRating(storeId);
    } catch (e) {
      print('خطأ في حذف التقييم: $e');
      rethrow;
    }
  }

  // تحديث متوسط التقييم في مجموعة المتاجر
  Future<void> _updateStoreRating(String storeId) async {
    try {
      final average = await getStoreAverageRating(storeId);
      final count = await getStoreRatingCount(storeId);

      await _firestore.collection('stores').doc(storeId).update({
        'rating': average,
        'ratingCount': count,
      });
    } catch (e) {
      // Error updating store rating
    }
  }

  // التحقق من إمكانية تقييم الطلبية
  Future<bool> canRateOrder(String userId, String orderId) async {
    try {
      final snapshot = await _firestore
          .collection('ratings')
          .where('userId', isEqualTo: userId)
          .where('orderId', isEqualTo: orderId)
          .get();

      return snapshot.docs.isEmpty;
    } catch (e) {
      return false;
    }
  }
}
