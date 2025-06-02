// lib/providers/analytics_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/sales_data.dart';

class AnalyticsProvider extends ChangeNotifier {
  final _orderCol = FirebaseFirestore.instance.collection('orders');

  //
  // ──────────────── EXISTING FUTURE METHODS ────────────────
  //

  /// 1) Bugünün Toplam Satışı (TL) — Future versiyonu
  Future<double> getTodaySales() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snap = await _orderCol
        .where('status', isEqualTo: 'paid')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(
          'createdAt',
          isLessThan: Timestamp.fromDate(endOfDay),
        )
        .get();

    double total = 0;
    for (var doc in snap.docs) {
      final data = doc.data();
      final items = data['items'] as List<dynamic>? ?? [];
      for (var it in items) {
        final qty = (it['qty'] as num?)?.toDouble() ?? 0.0;
        final price = (it['price'] as num?)?.toDouble() ?? 0.0;
        total += qty * price;
      }
    }
    return total;
  }

  /// 2) Bu Haftanın Toplam Satışı (TL) — Future versiyonu
  Future<double> getThisWeekSales() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = start.add(const Duration(days: 7));

    final snap = await _orderCol
        .where('status', isEqualTo: 'paid')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where(
          'createdAt',
          isLessThan: Timestamp.fromDate(end),
        )
        .get();

    double total = 0;
    for (var doc in snap.docs) {
      final data = doc.data();
      final items = data['items'] as List<dynamic>? ?? [];
      for (var it in items) {
        final qty = (it['qty'] as num?)?.toDouble() ?? 0.0;
        final price = (it['price'] as num?)?.toDouble() ?? 0.0;
        total += qty * price;
      }
    }
    return total;
  }

  /// 3) Bu Ayın Toplam Satışı (TL) — Future versiyonu
  Future<double> getThisMonthSales() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);

    final snap = await _orderCol
        .where('status', isEqualTo: 'paid')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where(
          'createdAt',
          isLessThan: Timestamp.fromDate(end),
        )
        .get();

    double total = 0;
    for (var doc in snap.docs) {
      final data = doc.data();
      final items = data['items'] as List<dynamic>? ?? [];
      for (var it in items) {
        final qty = (it['qty'] as num?)?.toDouble() ?? 0.0;
        final price = (it['price'] as num?)?.toDouble() ?? 0.0;
        total += qty * price;
      }
    }
    return total;
  }

  /// 4) Bugünkü Sipariş Adedi — Future versiyonu
  Future<int> getTodayOrderCount() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snap = await _orderCol
        .where('status', isEqualTo: 'paid')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(
          'createdAt',
          isLessThan: Timestamp.fromDate(endOfDay),
        )
        .get();

    return snap.docs.length;
  }

  /// 5) Ortalama Sipariş Tutarı (Bugünün Siparişleri) — Future versiyonu
  Future<double> getAvgOrderValueToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snap = await _orderCol
        .where('status', isEqualTo: 'paid')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(
          'createdAt',
          isLessThan: Timestamp.fromDate(endOfDay),
        )
        .get();

    if (snap.docs.isEmpty) return 0.0;

    double total = 0;
    for (var doc in snap.docs) {
      final data = doc.data();
      final items = data['items'] as List<dynamic>? ?? [];
      for (var it in items) {
        final qty = (it['qty'] as num?)?.toDouble() ?? 0.0;
        final price = (it['price'] as num?)?.toDouble() ?? 0.0;
        total += qty * price;
      }
    }
    return total / snap.docs.length;
  }

  /// 6) Günün En Yoğun Saatleri (Son 24 Saat) — Future versiyonu
  Future<List<HourCount>> getBusiestHoursToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snap = await _orderCol
        .where('status', isEqualTo: 'paid')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(
          'createdAt',
          isLessThan: Timestamp.fromDate(endOfDay),
        )
        .get();

    Map<int, int> hourMap = {for (var i = 0; i < 24; i++) i: 0};

    for (var doc in snap.docs) {
      final data = doc.data();
      final ts = data['createdAt'] as Timestamp?;
      if (ts == null) continue;
      final dt = ts.toDate();
      final hour = dt.hour;
      hourMap[hour] = (hourMap[hour] ?? 0) + 1;
    }

    final list = hourMap.entries
        .map((e) => HourCount(e.key, e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return list;
  }

  //
  // ──────────────── NEW STREAM‐BASED GETTERS FOR “LIVE UPDATES” ────────────────
  //

  /// 7) Bugünün Toplam Satışı (Stream versiyonu)
  Stream<double> get todaySales$ {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _orderCol
        .where('status', isEqualTo: 'paid')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(
          'createdAt',
          isLessThan: Timestamp.fromDate(endOfDay),
        )
        .snapshots()
        .map((snapshot) {
      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final items = data['items'] as List<dynamic>? ?? [];
        for (var it in items) {
          final qty = (it['qty'] as num?)?.toDouble() ?? 0.0;
          final price = (it['price'] as num?)?.toDouble() ?? 0.0;
          total += qty * price;
        }
      }
      return total;
    });
  }

  /// 8) Bu Haftanın Toplam Satışı (Stream versiyonu)
  Stream<double> get thisWeekSales$ {
    return Stream.periodic(const Duration(seconds: 0))
        .asyncExpand((_) => Stream.value(null))
        .asyncMap((_) async {
      // we still need “now” inside the closure to recalc every snapshot
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final end = start.add(const Duration(days: 7));
      return [start, end];
    }).asyncExpand((range) {
      final start = range[0] as DateTime;
      final end = range[1] as DateTime;
      return _orderCol
          .where('status', isEqualTo: 'paid')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          )
          .where(
            'createdAt',
            isLessThan: Timestamp.fromDate(end),
          )
          .snapshots();
    }).map((snapshot) {
      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final items = data['items'] as List<dynamic>? ?? [];
        for (var it in items) {
          final qty = (it['qty'] as num?)?.toDouble() ?? 0.0;
          final price = (it['price'] as num?)?.toDouble() ?? 0.0;
          total += qty * price;
        }
      }
      return total;
    });
  }

  /// 9) Bu Ayın Toplam Satışı (Stream versiyonu)
  Stream<double> get thisMonthSales$ {
    return Stream.periodic(const Duration(seconds: 0))
        .asyncExpand((_) => Stream.value(null))
        .asyncMap((_) async {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 1);
      return [start, end];
    }).asyncExpand((range) {
      final start = range[0] as DateTime;
      final end = range[1] as DateTime;
      return _orderCol
          .where('status', isEqualTo: 'paid')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          )
          .where(
            'createdAt',
            isLessThan: Timestamp.fromDate(end),
          )
          .snapshots();
    }).map((snapshot) {
      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final items = data['items'] as List<dynamic>? ?? [];
        for (var it in items) {
          final qty = (it['qty'] as num?)?.toDouble() ?? 0.0;
          final price = (it['price'] as num?)?.toDouble() ?? 0.0;
          total += qty * price;
        }
      }
      return total;
    });
  }

  /// 10) Bugünkü Sipariş Adedi (Stream versiyonu)
  Stream<int> get todayOrderCount$ {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _orderCol
        .where('status', isEqualTo: 'paid')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(
          'createdAt',
          isLessThan: Timestamp.fromDate(endOfDay),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// 11) Ortalama Sipariş Tutarı (Bugünün Siparişleri) — Stream versiyonu
  Stream<double> get avgOrderValueToday$ {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _orderCol
        .where('status', isEqualTo: 'paid')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(
          'createdAt',
          isLessThan: Timestamp.fromDate(endOfDay),
        )
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return 0.0;
      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final items = data['items'] as List<dynamic>? ?? [];
        for (var it in items) {
          final qty = (it['qty'] as num?)?.toDouble() ?? 0.0;
          final price = (it['price'] as num?)?.toDouble() ?? 0.0;
          total += qty * price;
        }
      }
      return total / snapshot.docs.length;
    });
  }

  /// 12) Günün En Yoğun Saatleri (Son 24 Saat) — Stream versiyonu
  Stream<List<HourCount>> get busiestHoursToday$ {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _orderCol
        .where('status', isEqualTo: 'paid')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(
          'createdAt',
          isLessThan: Timestamp.fromDate(endOfDay),
        )
        .snapshots()
        .map((snapshot) {
      Map<int, int> hourMap = {for (var i = 0; i < 24; i++) i: 0};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final ts = data['createdAt'] as Timestamp?;
        if (ts == null) continue;
        final dt = ts.toDate();
        final hour = dt.hour;
        hourMap[hour] = (hourMap[hour] ?? 0) + 1;
      }
      final list = hourMap.entries
          .map((e) => HourCount(e.key, e.value))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count));
      return list;
    });
  }

  /// 13) Son 7 Gün Satış Toplamları (Stream versiyonu) — (unchanged)
  Stream<List<SalesData>> get weeklySales {
    return _orderCol
        .where('status', isEqualTo: 'paid')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      Map<String, double> salesMap = {
        for (int i = 0; i < 7; i++)
          '${DateTime(now.year, now.month, now.day).subtract(Duration(days: i)).year}-'
          '${DateTime(now.year, now.month, now.day).subtract(Duration(days: i)).month}-'
          '${DateTime(now.year, now.month, now.day).subtract(Duration(days: i)).day}': 0.0
      };

      for (var docSnapshot in snapshot.docs) {
        final data = docSnapshot.data();
        final ts = data['createdAt'] as Timestamp?;
        if (ts == null) continue;
        final docDate = ts.toDate();
        final dayOnly = DateTime(docDate.year, docDate.month, docDate.day);
        final key = '${dayOnly.year}-${dayOnly.month}-${dayOnly.day}';
        if (salesMap.containsKey(key)) {
          final items = data['items'] as List<dynamic>? ?? [];
          double orderTotal = 0.0;
          for (var it in items) {
            final qty = (it['qty'] as num?)?.toDouble() ?? 0.0;
            final price = (it['price'] as num?)?.toDouble() ?? 0.0;
            orderTotal += qty * price;
          }
          salesMap[key] = (salesMap[key]! + orderTotal);
        }
      }

      final result = salesMap.entries.map((entry) {
        final parts = entry.key.split('-');
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        return SalesData(date, entry.value);
      }).toList();

      return result.reversed.toList();
    });
  }

  /// 14) Son 30 Gün Satış Toplamları (Stream versiyonu) — (unchanged)
  Stream<List<SalesData>> get last30DaysSales {
    return _orderCol
        .where('status', isEqualTo: 'paid')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      Map<String, double> salesMap = {
        for (int i = 0; i < 30; i++)
          '${DateTime(now.year, now.month, now.day).subtract(Duration(days: i)).year}-'
          '${DateTime(now.year, now.month, now.day).subtract(Duration(days: i)).month}-'
          '${DateTime(now.year, now.month, now.day).subtract(Duration(days: i)).day}': 0.0
      };

      for (var docSnapshot in snapshot.docs) {
        final data = docSnapshot.data();
        final ts = data['createdAt'] as Timestamp?;
        if (ts == null) continue;
        final docDate = ts.toDate();
        final dayOnly = DateTime(docDate.year, docDate.month, docDate.day);
        final key = '${dayOnly.year}-${dayOnly.month}-${dayOnly.day}';
        if (salesMap.containsKey(key)) {
          final items = data['items'] as List<dynamic>? ?? [];
          double orderTotal = 0.0;
          for (var it in items) {
            final qty = (it['qty'] as num?)?.toDouble() ?? 0.0;
            final price = (it['price'] as num?)?.toDouble() ?? 0.0;
            orderTotal += qty * price;
          }
          salesMap[key] = (salesMap[key]! + orderTotal);
        }
      }

      final result = salesMap.entries.map((entry) {
        final parts = entry.key.split('-');
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        return SalesData(date, entry.value);
      }).toList();

      return result.reversed.toList();
    });
  }
}

/// Saat & Adet bilgisini tutan basit model
class HourCount {
  final int hour;    // 0..23
  final int count;   // o saatte kaç sipariş var
  HourCount(this.hour, this.count);
}
