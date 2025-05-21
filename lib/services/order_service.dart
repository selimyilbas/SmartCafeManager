import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/table_provider.dart';
import '../providers/cart_provider.dart';

class OrderService {
  final _db = FirebaseFirestore.instance;

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
}
