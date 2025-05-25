import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/table_provider.dart';
import '../providers/cart_provider.dart';

class OrderService {
  final _db = FirebaseFirestore.instance;
  final _col = FirebaseFirestore.instance.collection('orders');

  /*──────────────────────────────*/
  /*🔑 Kullanıcı UID yardımcısı    */
  /*──────────────────────────────*/
  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  /*────────────────────────────────────────*/
  /*📦 Sipariş Oluştur (Customer tarafı)     */
  /*────────────────────────────────────────*/
  Future<void> createOrder(BuildContext ctx, List<CartEntry> entries) async {
    final tableProv = ctx.read<TableProvider>();
    final tableId = tableProv.tableId;
    final sessionId = tableProv.sessionId;

    if (tableId == null || sessionId == null) {
      throw 'Masa oturumu bulunamadı';
    }

    final items = entries
        .map((e) => {
              'itemId': e.item.id,
              'name': e.item.name,
              'qty': e.qty,
              'price': e.item.price, // double olabilir
              'options': e.chosen,
              'note': e.note,
            })
        .toList();

    await _col.add({
      'tableId': tableId,
      'sessionId': sessionId,
      'ownerUid': uid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'items': items,
    });
  }

  /*──────────────────────────────────────────────*/
  /*📥 Mutfağa göre sipariş akışı (status’e göre)  */
  /*──────────────────────────────────────────────*/
  Stream<QuerySnapshot<Map<String, dynamic>>> streamByStatus(String status) =>
      _col.where('status', isEqualTo: status).orderBy('createdAt').snapshots();

  /*──────────────────────────────────────────────*/
  /*🧾 Masa + Oturum → aktif siparişleri getir    */
  /*──────────────────────────────────────────────*/
  Stream<QuerySnapshot<Map<String, dynamic>>> streamActiveOrders(
          String tableId, String sessionId) =>
      _col
          .where('tableId', isEqualTo: tableId)
          .where('sessionId', isEqualTo: sessionId)
          .where('status', whereIn: ['pending', 'preparing', 'ready']) // paid hariç
          .snapshots();

  /*────────────────────────────────────────*/
  /*✏️ Status Güncelle (mutfak / ödeme)     */
  /*────────────────────────────────────────*/
  Future<void> updateStatus({
    required String orderId,
    required String newStatus,
  }) async {
    final ref = _col.doc(orderId);
    final data = <String, Object?>{'status': newStatus};

    if (newStatus == 'preparing') {
      data['startedAt'] = FieldValue.serverTimestamp();
    }
    if (newStatus == 'ready') {
      data['readyAt'] = FieldValue.serverTimestamp();
    }
    if (newStatus == 'paid') {
      data['paidAt'] = FieldValue.serverTimestamp();
    }

    await ref.update(data);
  }

  /*────────────────────────────────────────*/
  /*✅ Siparişi Ödenmiş Olarak İşaretle      */
  /*────────────────────────────────────────*/
  Future<void> markPaid(String orderId) => _col.doc(orderId).update({
        'status': 'paid',
        'paidAt': FieldValue.serverTimestamp(),
      });

  /*──────────────────────────────────────────────*/
  /*💰 Belirli masa + oturum için toplam hesap     */
  /*──────────────────────────────────────────────*/
  Future<double> totalCost(String tableId, String sessionId) async {
    final snap = await streamActiveOrders(tableId, sessionId).first;
    return snap.docs.fold<double>(0, (sum, d) {
      final items = d['items'] as List;
      final orderTotal = items.fold<double>(
        0,
        (p, it) =>
            p + ((it['qty'] as num?)?.toDouble() ?? 0) *
                ((it['price'] as num?)?.toDouble() ?? 0),
      );
      return sum + orderTotal;
    });
  }

  /*──────────────────────────────────────────────*/
  /*💰 Tek bir dökümandan sipariş tutarı hesapla   */
  /*──────────────────────────────────────────────*/
  double totalCostFromData(Map<String, dynamic> od) {
    final items = od['items'] as List;
    return items.fold<double>(0, (p, it) =>
      p + ((it['qty'] as num?)?.toDouble() ?? 0) *
          ((it['price'] as num?)?.toDouble() ?? 0));
  }
}
