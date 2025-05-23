import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/table_provider.dart';
import '../providers/cart_provider.dart';

class OrderService {
  final _db = FirebaseFirestore.instance;

  /// Sipariş oluştur (Customer tarafından)
  Future<void> createOrder(
      BuildContext context, List<CartEntry> entries) async {
    // 1) Aktif masa
    final tableId = context.read<TableProvider>().tableId;
    if (tableId == null) {
      throw 'Masa seçilmedi (tableId null)';
    }

    // 2) Siparişi veren kullanıcı
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // 3) Sepet öğelerini dönüştür
    final items = entries
        .map((e) => {
              'itemId': e.item.id,
              'name': e.item.name,
              'qty': e.qty,
              'price': e.item.price,
              'options': e.chosen,
              'note': e.note,
            })
        .toList();

    // 4) Firestore’a yaz
    await _db.collection('orders').add({
      'tableId': tableId,
      'ownerUserId': uid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'items': items,
    });
  }

  /// Mutfak: status'e göre stream (pending / preparing / ready)
  Stream<QuerySnapshot<Map<String, dynamic>>> streamByStatus(String status) {
    return _db
        .collection('orders')
        .where('status', isEqualTo: status)
        .orderBy('createdAt')
        .snapshots();
  }

  /// Mutfak: status güncelle + timestamp ekle
  Future<void> updateStatus({
    required String orderId,
    required String newStatus,
  }) async {
    final ref = _db.collection('orders').doc(orderId);
    final data = <String, Object?>{
      'status': newStatus,
    };
    if (newStatus == 'preparing') {
      data['startedAt'] = FieldValue.serverTimestamp();
    }
    if (newStatus == 'ready') {
      data['readyAt'] = FieldValue.serverTimestamp();
    }
    await ref.update(data);
  }
}
