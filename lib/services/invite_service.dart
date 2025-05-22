import 'package:cloud_firestore/cloud_firestore.dart';

class InviteService {
  final _db = FirebaseFirestore.instance;

  /// 1) Sadece kod geçerli mi diye kontrol eder
  Future<bool> validate(String code) async {
    final doc = await _db.collection('invites').doc(code).get();
    if (!doc.exists) return false;

    final d = doc.data()!;
    if (d['role'] != 'employee') return false;
    if (d['usedBy'] != null) return false;
    if ((d['expiresAt'] as Timestamp).toDate().isBefore(DateTime.now())) {
      return false;
    }
    return true;
  }

  /// 2) Kayıt başarılıysa kodu tüket (usedBy alanını doldurur)
  Future<void> consume(String code, String uid) async {
    return _db.runTransaction((tx) async {
      final ref = _db.collection('invites').doc(code);
      final snap = await tx.get(ref);

      if (!snap.exists || snap.get('usedBy') != null) {
        throw Exception('Kod zaten kullanılmış');
      }

      tx.update(ref, {'usedBy': uid});
    });
  }
}
