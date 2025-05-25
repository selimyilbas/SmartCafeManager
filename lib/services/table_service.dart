import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class TableService {
  final _db   = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  /*───────────────────────────────────────────────────────────*/
  /*  YARDIMCI                                                */
  /*───────────────────────────────────────────────────────────*/
  String _newSessionId(String tid) => '${tid}_${_uuid.v1()}';

  /*───────────────────────────────────────────────────────────*/
  /*  TABLO GETİR (QR doğrulama vb.)                          */
  /*───────────────────────────────────────────────────────────*/
  Future<Map<String, dynamic>?> fetchTable(String id) async {
    final snap = await _db.collection('tables').doc(id).get();
    return snap.exists ? snap.data() : null;
  }

  /*───────────────────────────────────────────────────────────*/
  /*  MASAYA OTUR                                             */
  /*───────────────────────────────────────────────────────────*/
  Future<String> joinTable(String tableId) async {
    final ref = _db.collection('tables').doc(tableId);

    String? sessionId;
    await _db.runTransaction((tx) async {
      final snap     = await tx.get(ref);
      int  guests    = (snap.data()?['activeGuests'] ?? 0) + 1;
      sessionId      = snap.data()?['activeSession'] as String?;
      sessionId ??= _newSessionId(tableId);

      tx.set(
        ref,
        {
          'activeGuests' : guests,
          'activeSession': sessionId,
          'status'       : 'occupied',
          'lastUpdated'  : FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });

    // transaction sonrası null olamaz
    return sessionId!;
  }

  /*───────────────────────────────────────────────────────────*/
  /*  MASADAN KALK                                            */
  /*───────────────────────────────────────────────────────────*/
  Future<void> leaveTable(String tableId) async {
    final ref = _db.collection('tables').doc(tableId);

    await _db.runTransaction((tx) async {
      final snap   = await tx.get(ref);
      int guests   = (snap.data()?['activeGuests'] ?? 1) - 1;
      if (guests < 0) guests = 0;

      final data = <String, Object?>{
        'activeGuests': guests,
        'lastUpdated' : FieldValue.serverTimestamp(),
      };

      if (guests == 0) {
        data['status']        = 'available';
        data['activeSession'] = FieldValue.delete();  // oturum kapandı
      }

      tx.update(ref, data);
    });
  }

  /*───────────────────────────────────────────────────────────*/
  /*  TABLO STREAM’LERİ                                       */
  /*───────────────────────────────────────────────────────────*/
  /// Doluluktaki değişimleri dinlemek için (Employee monitor)
  Stream<QuerySnapshot<Map<String, dynamic>>> streamBusyTables() =>
      _db
          .collection('tables')
          .where('activeGuests', isGreaterThan: 0)
          .snapshots();

  /// Zorunlu boşalt – masada kimse yoksa bile çağrılabilir
  Future<void> forceClear(String tableId) => _db
      .collection('tables')
      .doc(tableId)
      .update({
        'activeGuests' : 0,
        'status'       : 'available',
        'activeSession': FieldValue.delete(),
      });
}
