import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShiftService {
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  Future<DocumentReference> startShift() {
    return _db.collection('shifts').add({
      'employeeId': _uid,
      'startedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> endShift(String shiftId) {
    return _db.collection('shifts').doc(shiftId).update({
      'endedAt': FieldValue.serverTimestamp(),
    });
  }
}
