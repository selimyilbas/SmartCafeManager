import 'package:cloud_firestore/cloud_firestore.dart';

class TableService {
  final _db = FirebaseFirestore.instance;

  /// Masa dökümanını getir (yoksa null)
  Future<Map<String, dynamic>?> fetchTable(String id) async {
    final snap = await _db.collection('tables').doc(id).get();
    return snap.exists ? snap.data() : null;
  }

  /// Masaya otur: activeGuests += 1
  Future<void> joinTable(String id) async {
    final ref = _db.collection('tables').doc(id);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final guests = (snap.data()?['activeGuests'] ?? 0) + 1;
      tx.set(ref, {
        'activeGuests': guests,
        'status': 'occupied',
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  /// Masadan kalk: activeGuests -= 1  (0 ise available)
  Future<void> leaveTable(String id) async {
    final ref = _db.collection('tables').doc(id);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      int guests = (snap.data()?['activeGuests'] ?? 1) - 1;
      if (guests < 0) guests = 0;
      tx.set(ref, {
        'activeGuests': guests,
        'status': guests == 0 ? 'available' : 'occupied',
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  /// 🔁 Dolu masaları dinle (monitor ekranı için)
  Stream<QuerySnapshot<Map<String, dynamic>>> streamBusyTables() {
    return _db
        .collection('tables')
        .where('activeGuests', isGreaterThan: 0)
        .snapshots();
  }

  /// ⛔️ Masayı zorla boşalt
  Future<void> forceClear(String tableId) async {
    await _db.collection('tables').doc(tableId).update({
      'activeGuests': 0,
      'status': 'available',
    });
  }
}
