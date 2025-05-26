import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item.dart';

class MenuAdminService {
  final _col = FirebaseFirestore.instance.collection('menu');

  /// artık tek argümanlı factory’yi kullanıyoruz
  Stream<List<MenuItem>> streamMenu() =>
      _col.snapshots().map(
            (snap) => snap.docs.map((doc) => MenuItem.fromDoc(doc)).toList(),
          );

  Future<void> addItem(MenuItem item)    => _col.add(item.toJson());
  Future<void> updateItem(MenuItem item) => _col.doc(item.id).update(item.toJson());
  Future<void> deleteItem(String id)     => _col.doc(id).delete();

  Future<void> setDiscount({
    required String itemId,
    required double percent,
    required DateTime from,
    required DateTime to,
  }) =>
      _col.doc(itemId).update({
        'discount': {
          'percent': percent,
          'from':    Timestamp.fromDate(from),
          'to':      Timestamp.fromDate(to),
        },
      });

  /// **Yeni**: minimum stok adedini güncellemek için
  Future<void> setMinQty(String itemId, int minQty) =>
      _col.doc(itemId).update({'minQty': minQty});
}
