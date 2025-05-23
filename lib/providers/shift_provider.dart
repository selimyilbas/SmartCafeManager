import 'package:flutter/material.dart';
import '../services/shift_service.dart';
import 'call_provider.dart'; // 🆕 çağrı desteği için

class ShiftProvider extends ChangeNotifier {
  final _service = ShiftService();
  String? activeShiftId;

  final _calls = CallProvider(); // 🆕

  // Global context gerekiyor — app başlatılırken alınmalı (örn. navigatorKey.currentContext!)
  late BuildContext _appCtx;

  void setAppContext(BuildContext ctx) {
    _appCtx = ctx;
  }

  Future<void> clockIn() async {
    if (activeShiftId != null) return;
    final ref = await _service.startShift();
    activeShiftId = ref.id;
    notifyListeners();

    // 🆕 Çağrı dinlemeyi başlat
    _calls.startListening(_appCtx);
  }

  Future<void> clockOut() async {
    if (activeShiftId == null) return;
    await _service.endShift(activeShiftId!);
    activeShiftId = null;
    notifyListeners();

    // 🆕 Çağrı dinlemeyi durdur
    _calls.stopListening();
  }
}
