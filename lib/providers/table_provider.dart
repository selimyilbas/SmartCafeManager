import 'package:flutter/material.dart';

class TableProvider extends ChangeNotifier {
  String? tableId;

  void setTable(String id) {
    tableId = id;
    notifyListeners();
  }

  void clear() {
    tableId = null;
    notifyListeners();
  }
}
