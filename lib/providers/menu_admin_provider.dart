import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';
import '../services/menu_admin_service.dart';

class MenuAdminProvider extends ChangeNotifier {
  final _svc = MenuAdminService();

  Stream<List<MenuItem>> streamMenu() => _svc.streamMenu();
  Future<void> addItem(MenuItem item)    => _svc.addItem(item);
  Future<void> updateItem(MenuItem item) => _svc.updateItem(item);
  Future<void> deleteItem(String id)     => _svc.deleteItem(id);

  /// **Yeni** metot adı: setMin
  Future<void> setMin(String itemId, int minQty) =>
      _svc.setMinQty(itemId, minQty);
}
