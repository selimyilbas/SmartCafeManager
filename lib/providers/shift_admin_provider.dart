import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/shift_admin_service.dart';

/// Manager’ın tüm employee’leri ve onların shift geçmişlerini dinler.
class ShiftAdminProvider extends ChangeNotifier {
  final _srv = ShiftAdminService();

  Stream<QuerySnapshot<Map<String, dynamic>>> streamEmployees() {
    return _srv.streamEmployees();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamShifts(String uid) {
    return _srv.streamShifts(uid);
  }
}
