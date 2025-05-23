import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/order_service.dart';

class KitchenProvider extends ChangeNotifier {
  final _service = OrderService();

  Stream<QuerySnapshot<Map<String, dynamic>>> stream(String status) =>
      _service.streamByStatus(status);

  Future<void> setPreparing(String oid) =>
      _service.updateStatus(orderId: oid, newStatus: 'preparing');

  Future<void> setReady(String oid) =>
      _service.updateStatus(orderId: oid, newStatus: 'ready');
}
