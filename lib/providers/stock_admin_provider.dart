import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/stock_admin_service.dart';

class StockAdminProvider extends ChangeNotifier {
  final _srv = StockAdminService();

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> critical() =>
      _srv.criticalStream().map(
            (snap) => snap.docs
                .where((d) =>
                    (d.data()['stockQty'] ?? 0) <= (d.data()['minQty'] ?? 0))
                .toList(),
          );

  Future<void> setMin(String itemId, int? minQty) =>
      _srv.setMinQty(itemId, minQty);
}
