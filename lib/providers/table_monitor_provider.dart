import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/table_service.dart';
import '../services/order_service.dart';

class TableMonitorProvider extends ChangeNotifier {
  final _tblSrv = TableService();
  final _ordSrv = OrderService();

  /* Aktif (dolu) masalar stream’i */
  Stream<QuerySnapshot<Map<String, dynamic>>> streamBusyTables() =>
      _tblSrv.streamBusyTables();

  /* Bir masanın –yalnızca o oturuma ait– siparişleri */
  Stream<QuerySnapshot<Map<String, dynamic>>> streamOrders(
          String tableId, String sessionId) =>
      _ordSrv.streamActiveOrders(tableId, sessionId);

  /* Masayı zorla boşalt */
  Future<void> forceClear(String tableId) => _tblSrv.forceClear(tableId);

  /*───────────────────────────────────────────────────────*/
  /* 💰 Toplam Tutar Stream’i (paid + unpaid)              */
  /*───────────────────────────────────────────────────────*/
  Stream<Map<String, double>> totals(String tbl, String sess) =>
      _ordSrv
          .streamActiveOrders(tbl, sess)
          .map((qs) {
            double paid = 0, unpaid = 0;
            for (final d in qs.docs) {
              final cost = _ordSrv.totalCostFromData(d.data());
              if (d['status'] == 'paid') {
                paid += cost;
              } else {
                unpaid += cost;
              }
            }
            return {'paid': paid, 'unpaid': unpaid};
          });
}
