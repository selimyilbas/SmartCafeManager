// lib/services/inventory_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryService {
  final _db = FirebaseFirestore.instance;

  /// 1) Tüm envanteri QuerySnapshot olarak stream halinde dinler
  Stream<QuerySnapshot<Map<String, dynamic>>> streamInventorySnapshots() {
    return _db
        .collection('inventory')
        .orderBy('name')
        .snapshots();
  }

  /// 2) Stoğu delta kadar (±) değiştirir
  Future<void> adjust(String id, int delta) {
    return _db.collection('inventory').doc(id).update({
      'stockQty': FieldValue.increment(delta),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 3) Kritik eşiğin (minQty) güncelleneceği metot
  Future<void> updateMinQty(String id, int minQty) {
    return _db.collection('inventory').doc(id).update({
      'minQty':     minQty,
      'updatedAt':  FieldValue.serverTimestamp(),
    });
  }

  /// 4) Belirli stoğu birebir ayarlamak istersen
  Future<void> setStockQty(String id, int qty) {
    return _db.collection('inventory').doc(id).update({
      'stockQty':   qty,
      'updatedAt':  FieldValue.serverTimestamp(),
    });
  }

  /// 5) Stream’den client-side filtre yaparak kritik stokları döner
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> streamCritical() {
    return streamInventorySnapshots().map((snap) {
      return snap.docs.where((doc) {
        final data  = doc.data();
        final stock = (data['stockQty'] ?? 0) as num;
        final min   = (data['minQty']   ?? 0) as num;
        return stock <= min;
      }).toList();
    });
  }
}
