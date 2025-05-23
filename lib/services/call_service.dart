import 'package:cloud_firestore/cloud_firestore.dart';

class CallService {
  final _db = FirebaseFirestore.instance;

  Future<void> sendCall(String tableId) async {
    await _db.collection('calls').add({
      'tableId': tableId,
      'createdAt': FieldValue.serverTimestamp(),
      'handled': false,
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamActiveCalls() =>
      _db.collection('calls')
         .where('handled', isEqualTo: false)
         .snapshots();

  Future<void> markHandled(String docId) =>
      _db.collection('calls').doc(docId).update({'handled': true});
}
