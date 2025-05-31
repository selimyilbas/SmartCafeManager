// lib/services/menu_admin_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item.dart';

class MenuAdminService {
  final _col = FirebaseFirestore.instance.collection('menu');

  /// Menü koleksiyonunun QuerySnapshot'ını stream olarak döner (isim sırasına göre)
  Stream<QuerySnapshot<Map<String, dynamic>>> streamMenuSnapshots() {
    return _col.orderBy('name').snapshots();
  }

  /// Yeni bir ürün eklemek için: doküman ID olarak item.id kullanıyoruz
  Future<void> addItem(MenuItem item) {
    return _col.doc(item.id).set(item.toJson());
  }

  /// Mevcut ürünü güncellemek için
  Future<void> updateItem(MenuItem item) {
    return _col.doc(item.id).update(item.toJson());
  }

  /// Ürünü silmek için
  Future<void> deleteItem(String id) {
    return _col.doc(id).delete();
  }

  /// Sadece minQty değerini güncellemek için
  Future<void> setMinQty(String itemId, int minQty) {
    return _col.doc(itemId).update({'minQty': minQty});
  }

  /// (Opsiyonel) Ürüne indirim eklemek isterseniz
  Future<void> setDiscount({
    required String itemId,
    required double percent,
    required DateTime from,
    required DateTime to,
  }) {
    return _col.doc(itemId).update({
      'discount': {
        'percent': percent,
        'from':    Timestamp.fromDate(from),
        'to':      Timestamp.fromDate(to),
      },
    });
  }
}
