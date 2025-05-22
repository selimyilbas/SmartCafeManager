import 'package:flutter/material.dart';
import '../services/shift_service.dart';

class ShiftProvider extends ChangeNotifier {
  final _service = ShiftService();
  String? activeShiftId;

  Future<void> clockIn() async {
    if (activeShiftId != null) return;
    final ref = await _service.startShift();
    activeShiftId = ref.id;
    notifyListeners();
  }

  Future<void> clockOut() async {
    if (activeShiftId == null) return;
    await _service.endShift(activeShiftId!);
    activeShiftId = null;
    notifyListeners();
  }
}
