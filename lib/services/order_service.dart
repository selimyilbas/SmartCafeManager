// lib/services/order_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/table_provider.dart';
import '../providers/cart_provider.dart';

class OrderService {
  final _db  = FirebaseFirestore.instance;
  final _col = FirebaseFirestore.instance.collection('orders');

  /// Helper: o anki oturum açmış kullanıcının UID’sini döner.
  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  /// 1) Yeni bir sipariş oluşturmak için: CartProvider’dan gelen entries’ı Firestore’a yazar.
  Future<void> createOrder(BuildContext ctx, List<CartEntry> entries) async {
    final tableProv = ctx.read<TableProvider>();
    final tableId   = tableProv.tableId;
    final sessionId = tableProv.sessionId;

    if (tableId == null || sessionId == null) {
      throw 'Masa oturumu bulunamadı';
    }

    // Her CartEntry’i firestore’daki "items" alanına uygun map’e çeviriyoruz
    final items = entries.map((e) {
      return {
        'itemId':  e.item.id,
        'name':    e.item.name,
        'qty':     e.qty,
        'price':   e.item.price,
        'options': e.chosen,
        'note':    e.note,
      };
    }).toList();

    await _col.add({
      'tableId':   tableId,
      'sessionId': sessionId,
      'ownerUid':  uid,
      'status':    'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'items':     items,
    });
  }

  /// 2) Müşterinin (ownerUid == uid) geçmiş siparişlerini stream olarak döner.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamUserOrders() {
    return _col
        .where('ownerUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// 3) Mutfak tarafı (kitchen) için; duruma göre siparişleri stream’ler.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamByStatus(String status) {
    return _col
        .where('status', isEqualTo: status)
        .orderBy('createdAt')
        .snapshots();
  }

  /// 4) Bir masadaki (aktif, ödenmemiş) siparişleri getirir.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamActiveOrders(
    String tableId,
    String sessionId,
  ) {
    return _col
        .where('tableId',   isEqualTo: tableId)
        .where('sessionId', isEqualTo: sessionId)
        .where('status',    whereIn: ['pending', 'preparing', 'ready'])
        .snapshots();
  }

  /// 5) Sipariş durumunu güncelleme (preparing, ready, paid vb.).
  Future<void> updateStatus({
    required String orderId,
    required String newStatus,
  }) async {
    final ref = _col.doc(orderId);
    final data = <String, Object?>{'status': newStatus};

    if (newStatus == 'preparing') {
      // "preparing" durumuna geçince startedAt ekleyelim (opsiyonel)
      data['startedAt'] = FieldValue.serverTimestamp();
    }
    if (newStatus == 'ready') {
      // "ready" durumuna geçince readyAt ekleyelim
      data['readyAt'] = FieldValue.serverTimestamp();
    }
    if (newStatus == 'paid') {
      // "paid" durumuna geçince paidAt ekleyelim
      data['paidAt'] = FieldValue.serverTimestamp();
    }

    await ref.update(data);
  }

  /// 6) Siparişi “paid” olarak işaretleme
  Future<void> markPaid(String orderId) {
    return _col.doc(orderId).update({
      'status': 'paid',
      'paidAt': FieldValue.serverTimestamp(),
    });
  }

  /// 7) Aktif (paid olmayan) siparişlerin masaya toplam fiyatını hesaplama
  Future<double> totalCost(String tableId, String sessionId) async {
    final snap = await streamActiveOrders(tableId, sessionId).first;
    return snap.docs.fold<double>(0, (sum, d) {
      final items = d['items'] as List;
      final orderTotal = items.fold<double>(
        0,
        (p, it) =>
            p +
            ((it['qty']   as num?)?.toDouble() ?? 0) *
            ((it['price'] as num?)?.toDouble() ?? 0),
      );
      return sum + orderTotal;
    });
  }

  /// 8) “Tek” bir sipariş objesinin içinden toplam fiyatı hesaplamak isterseniz
  double totalCostFromData(Map<String, dynamic> od) {
    final items = od['items'] as List;
    return items.fold<double>(
      0,
      (p, it) =>
          p +
          ((it['qty']   as num?)?.toDouble() ?? 0) *
          ((it['price'] as num?)?.toDouble() ?? 0),
    );
  }
}
