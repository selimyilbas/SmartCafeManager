import 'package:flutter/material.dart';
import '../services/table_service.dart';

class TableProvider extends ChangeNotifier {
  String? tableId;
  String? sessionId;

  final _service = TableService();

  String? get currentTableId => tableId;
  String? get currentSessionId => sessionId;

  Future<bool> join(String id) async {
    sessionId = await _service.joinTable(id);
    tableId = id;
    notifyListeners();
    return true;
  }

  Future<void> leave() async {
    if (tableId != null) {
      await _service.leaveTable(tableId!);
    }
    tableId = null;
    sessionId = null;
    notifyListeners();
  }
}
