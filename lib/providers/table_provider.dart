import 'package:flutter/material.dart';
import '../services/table_service.dart';

class TableProvider extends ChangeNotifier {
  String? tableId;
  final _service = TableService();

  Future<bool> join(String id) async {
    await _service.joinTable(id);
    tableId = id;
    notifyListeners();
    return true;
  }

  Future<void> leave() async {
    if (tableId != null) {
      await _service.leaveTable(tableId!);
      tableId = null;
      notifyListeners();
    }
  }
}
