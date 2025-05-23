import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/table_service.dart';
import '../services/order_service.dart';

class TableMonitorProvider extends ChangeNotifier {
  final _tableSrv = TableService();
  final _orderSrv = OrderService();

  /// Tüm aktif masalar (aktifGuests > 0) akışı
  Stream<QuerySnapshot<Map<String, dynamic>>> stream() =>
      _tableSrv.streamBusyTables();

  /// Masayı zorla boşalt – employee kullanımı
  Future<void> clear(String id) => _tableSrv.forceClear(id);

  /// Masaya ait aktif sipariş akışı (status != paid)
  Stream<QuerySnapshot<Map<String, dynamic>>> streamOrders(String tableId) =>
      _orderSrv.streamByTable(tableId);
}
