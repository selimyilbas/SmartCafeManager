// lib/services/shift_admin_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ShiftAdminService {
  final _db = FirebaseFirestore.instance;

  /// Tüm employee’leri çeken stream
  Stream<QuerySnapshot<Map<String, dynamic>>> streamEmployees() {
    return _db
      .collection('users')
      .where('role', isEqualTo: 'employee')
      .snapshots();
  }

  /// Bir çalışanın tüm shift geçmişini, başlama zamanına göre sıralı getirir.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamShifts(String uid) {
    return _db
      .collection('shifts')
      .where('employeeId', isEqualTo: uid)        // <— employeeId ile filtre
      .orderBy('startedAt', descending: true)     // <— startedAt’a göre (serverTimestamp)
      .snapshots();
  }
}
