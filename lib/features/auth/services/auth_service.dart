import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _auth = FirebaseAuth.instance;
  final _users = FirebaseFirestore.instance.collection('users');

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // نحوّل رقم الهاتف لـ email وهمي
  String _phoneToEmail(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return '$digits@alaainy.app';
  }

  Future<UserCredential> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    final email = _phoneToEmail(phone);
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // حفظ بيانات المستخدم في Firestore
    await _users.doc(cred.user!.uid).set({
      'uid': cred.user!.uid,
      'name': name,
      'phone': phone,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await cred.user!.updateDisplayName(name);
    return cred;
  }

  Future<UserCredential> login({
    required String phone,
    required String password,
  }) async {
    final email = _phoneToEmail(phone);
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async => await _auth.signOut();

  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser == null) return null;
    final doc = await _users.doc(currentUser!.uid).get();
    return doc.data();
  }
}
