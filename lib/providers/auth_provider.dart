import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? user;
  String? role; // "customer" | "employee" | "manager"

  AuthProvider() {
    _auth.authStateChanges().listen(_handleAuthChanged);
  }

  Future<void> _handleAuthChanged(User? firebaseUser) async {
    user = firebaseUser;
    if (user != null) {
      final snap = await _db.collection('users').doc(user!.uid).get();
      role = snap.data()?['role'] as String?;
    } else {
      role = null;
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners(); // kullanıcı logout olduğunda UI güncellenir
  }

  /// ✅ Yeni: Kullanıcı kaydı (invite code + role doğrulama)
  Future<User?> signUp({
    required String email,
    required String password,
    required String role,
    String? inviteCode,
  }) async {
    if (role != 'customer') {
      if (inviteCode == null || inviteCode.isEmpty) {
        throw 'Davet kodu girilmedi';
      }

      final inviteRef = _db.collection('invites').doc(inviteCode);
      final invite = await inviteRef.get();

      if (!invite.exists) throw 'Kod bulunamadı';
      if (invite['role'] != role) throw 'Kod bu rol için değil';

      final exp = (invite['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(exp)) throw 'Kodun süresi dolmuş';

      if (invite.data()!.containsKey('usedBy')) {
        throw 'Kod daha önce kullanılmış';
      }

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;

      await _db.collection('users').doc(uid).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await inviteRef.update({'usedBy': uid});

      return cred.user;
    } else {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;

      await _db.collection('users').doc(uid).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return cred.user;
    }
  }

  /// 🔐 Giriş işlemi
  Future<User?> signIn(String email, String password) async {
    final creds = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return creds.user;
  }

  /// ✅ Eklenen: /users/{uid} → rol alanını getirir
  Future<String> fetchRole(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists) throw 'Kullanıcı bulunamadı';
    final role = snap.data()?['role'] as String?;
    if (role == null) throw 'Rol alanı boş';
    return role;
  }
}
