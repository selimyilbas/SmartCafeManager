import 'package:cloud_firestore/cloud_firestore.dart';

class StockService {
  final _col = FirebaseFirestore.instance.collection('inventory');

  Stream<QuerySnapshot<Map<String, dynamic>>> stream() =>
      _col.orderBy('name').snapshots();

  Future<void> adjust(String id, int delta) async {
    final ref = _col.doc(id);
    await FirebaseFirestore.instance.runTransaction((t) async {
      final snap = await t.get(ref);
      if (!snap.exists) return;
      final current = (snap.data()?['stockQty'] ?? 0) as int;
      final next = (current + delta).clamp(0, 9999);
      t.update(ref, {
        'stockQty': next,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
