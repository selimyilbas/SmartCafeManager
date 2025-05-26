import 'package:cloud_firestore/cloud_firestore.dart';

class StaffAdminService {
  final _users = FirebaseFirestore.instance.collection('users');
  final _shifts = FirebaseFirestore.instance.collection('shifts');

  Stream<QuerySnapshot<Map<String, dynamic>>> streamEmployees() =>
      _users.where('role', isEqualTo: 'employee').snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> streamShifts(String uid) =>
      _shifts.where('uid', isEqualTo: uid).snapshots();
}
