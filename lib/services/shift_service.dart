import 'package:cloud_firestore/cloud_firestore.dart';

class ShiftService {
  final _db = FirebaseFirestore.instance;

  /// Çalışanın kendi tüm shift kayıtlarını gerçek zamanlı dinler
  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyShifts(String uid) {
    return _db
      .collection('shifts')
      .where('employeeId', isEqualTo: uid)
      .snapshots();
  }

  /// Yeni bir shift başlatır (clock in)
  Future<void> startShift(String uid) {
    return _db.collection('shifts').add({
      'employeeId': uid,
      'startedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mevcut shift’i bitirir (clock out)
  Future<void> endShift(String uid, String shiftId) {
    return _db
      .collection('shifts')
      .doc(shiftId)
      .update({'endedAt': FieldValue.serverTimestamp()});
  }
}
