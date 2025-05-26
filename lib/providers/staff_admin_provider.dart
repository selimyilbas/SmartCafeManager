import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/staff_admin_service.dart';

class StaffAdminProvider extends ChangeNotifier {
  final _srv = StaffAdminService();
  Stream<QuerySnapshot<Map<String, dynamic>>> streamEmployees() =>
      _srv.streamEmployees();
  Stream<QuerySnapshot<Map<String, dynamic>>> streamShifts(String uid) =>
      _srv.streamShifts(uid);
}
