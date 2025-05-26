import 'package:cloud_firestore/cloud_firestore.dart';

class StockAdminService {
  final _col = FirebaseFirestore.instance.collection('menu');

  Stream<QuerySnapshot<Map<String, dynamic>>> criticalStream() =>
      _col.snapshots();

  Future<void> setMinQty(String id, int? minQty) =>
      _col.doc(id).update({'minQty': minQty});
}
