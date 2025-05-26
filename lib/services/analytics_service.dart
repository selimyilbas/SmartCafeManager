import 'package:cloud_firestore/cloud_firestore.dart';

/// Satış & yoğunluk istatistikleri
class AnalyticsService {
  final _orders = FirebaseFirestore.instance.collection('orders');

  /*───────────────────────────── 30 günlük satış  ───────────────────────────*/
  Future<List<Map<String, dynamic>>> salesPerDay() async {
    final now  = DateTime.now();
    final from = now.subtract(const Duration(days: 30));

    final snap = await _orders
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('status', isEqualTo: 'paid')
        .get();

    final bucket = <String, double>{}; // yyyy-m-d : ₺

    for (final doc in snap.docs) {
      final o   = doc.data();
      final day = (o['createdAt'] as Timestamp).toDate();
      final key = '${day.year}-${day.month}-${day.day}';

      final double tot = (o['items'] as List)
          .fold<double>(0, (p, e) => p + (e['price'] as num) * (e['qty'] as num));

      bucket[key] = (bucket[key] ?? 0) + tot;
    }

    return bucket.entries
        .map((e) => {'day': e.key, 'total': e.value})
        .toList();
  }

  /*────────────────────────────── Saatlik yoğunluk ──────────────────────────*/
  Future<List<int>> hourlyHeat() async {
    final snap = await _orders.where('status', isEqualTo: 'paid').get();
    final hours = List<int>.filled(24, 0);

    for (final doc in snap.docs) {
      final h = (doc['createdAt'] as Timestamp).toDate().hour;
      hours[h]++;
    }
    return hours;
  }
}
