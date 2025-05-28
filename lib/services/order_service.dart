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

  /// Helper to get current user UID (or empty if none)
  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  /// Create a new order document under `/orders`
  Future<void> createOrder(BuildContext ctx, List<CartEntry> entries) async {
    final tableProv = ctx.read<TableProvider>();
    final tableId   = tableProv.tableId;
    final sessionId = tableProv.sessionId;

    if (tableId == null || sessionId == null) {
      throw 'Masa oturumu bulunamadı';
    }

    // Build items list
    final items = entries.map((e) {
      return {
        'itemId':   e.item.id,
        'name':     e.item.name,
        'qty':      e.qty,
        'price':    e.item.price,
        'options':  e.chosen,
        'note':     e.note,
      };
    }).toList();

    // Add a new order doc
    await _col.add({
      'tableId':    tableId,
      'sessionId':  sessionId,
      'ownerUid':   uid,
      'status':     'pending',
      'createdAt':  FieldValue.serverTimestamp(),
      'items':      items,
    });
  }

  /// Stream orders by kitchen status (pending, preparing, ready, paid…)
  Stream<QuerySnapshot<Map<String, dynamic>>> streamByStatus(String status) {
    return _col
      .where('status', isEqualTo: status)
      .orderBy('createdAt')
      .snapshots();
  }

  /// Stream active (non-paid) orders for a given table session
  Stream<QuerySnapshot<Map<String, dynamic>>> streamActiveOrders(
      String tableId,
      String sessionId,
  ) {
    return _col
      .where('tableId',   isEqualTo: tableId)
      .where('sessionId', isEqualTo: sessionId)
      .where('status',    whereIn: ['pending','preparing','ready'])
      .snapshots();
  }

  /// Update an order’s status and add timestamps
  Future<void> updateStatus({
    required String orderId,
    required String newStatus,
  }) async {
    final ref = _col.doc(orderId);
    final data = <String, Object?>{ 'status': newStatus };

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

  /// Mark an order as paid
  Future<void> markPaid(String orderId) {
    return _col.doc(orderId).update({
      'status':  'paid',
      'paidAt':  FieldValue.serverTimestamp(),
    });
  }

  /// Compute total cost for all active (non-paid) orders of a session
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

  /// Compute total from a single order map
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
