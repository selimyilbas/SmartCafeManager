import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final _srv = AnalyticsService();

  Future<List<Map<String, dynamic>>> salesPerDay() => _srv.salesPerDay();
  Future<List<int>> hourlyHeat() => _srv.hourlyHeat();
}
