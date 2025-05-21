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
}
