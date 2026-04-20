import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_profile_model.dart';
import '../models/favorite_model.dart';
import '../../orders/models/order_model.dart';

class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  // Collection references
  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _favorites => _firestore.collection('favorites');
  CollectionReference get _orders => _firestore.collection('orders');

  // Get current user profile
  Future<UserProfileModel?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _users.doc(user.uid).get();
    if (!doc.exists) return null;

    return UserProfileModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  // Update user profile
  Future<void> updateProfile(UserProfileModel profile) async {
    await _users.doc(profile.uid).update({
      ...profile.toMap(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Upload profile image
  Future<String?> uploadProfileImage(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final ref = _storage.ref().child('profile_images/${user.uid}.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // Get user favorites
  Stream<List<FavoriteModel>> getUserFavorites() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _favorites
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                FavoriteModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Add to favorites
  Future<void> addToFavorites(String itemId, String itemType,
      {String? itemName, String? itemImageUrl}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final favoriteId = '${user.uid}_${itemId}_$itemType';
    final favorite = FavoriteModel(
      id: favoriteId,
      userId: user.uid,
      itemId: itemId,
      itemType: itemType,
      itemName: itemName,
      itemImageUrl: itemImageUrl,
      createdAt: DateTime.now(),
    );

    await _favorites.doc(favoriteId).set(favorite.toMap());
  }

  // Remove from favorites
  Future<void> removeFromFavorites(String itemId, String itemType) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final favoriteId = '${user.uid}_${itemId}_$itemType';
    await _favorites.doc(favoriteId).delete();
  }

  // Check if item is favorite
  Future<bool> isFavorite(String itemId, String itemType) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final favoriteId = '${user.uid}_${itemId}_$itemType';
    final doc = await _favorites.doc(favoriteId).get();
    return doc.exists;
  }

  // Get user order history
  Stream<List<OrderModel>> getUserOrderHistory() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _orders
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(
                (doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await _orders.doc(orderId).get();
    if (!doc.exists) return null;
    return OrderModel.fromMap(doc.data() as Map<String, dynamic>);
  }
}
