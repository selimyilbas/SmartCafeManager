// lib/screens/manager/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/analytics_provider.dart';
import '../../models/sales_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  // Stil sabitleri
  static const titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  static const valueStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.green,
  );

  @override
  Widget build(BuildContext context) {
    final analyticsProv = context.read<AnalyticsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('[Manager]  📊 Manager Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // —————————————— 1) Güncel Satış/Hasılat Özeti ——————————————
            const Text(
              'Güncel Satış/Hasılat Özeti',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            // KPI kartlarını Wrap ile yerleştiriyoruz; her biri sabit genişlikli olacak
            LayoutBuilder(
              builder: (ctx, constraints) {
                const double cardSpacing = 12;
                final double totalHorizontalSpacing = cardSpacing;
                final double cardWidth =
                    (constraints.maxWidth - totalHorizontalSpacing) / 2;

                return Wrap(
                  spacing: cardSpacing,
                  runSpacing: 12,
                  children: [
                    // 1) Bugünün Toplam Satışı (StreamBuilder)
                    SizedBox(
                      width: cardWidth,
                      child: StreamBuilder<double>(
                        stream: analyticsProv.todaySales$,
                        builder: (ctx2, snap) {
                          String text;
                          if (snap.hasError) {
                            text = '–';
                          } else if (!snap.hasData) {
                            text = 'Yükleniyor...';
                          } else {
                            text = '${snap.data!.toStringAsFixed(2)} ₺';
                          }
                          return _KpiCard(
                            title: 'Bugünün Toplam Satışı',
                            value: text,
                          );
                        },
                      ),
                    ),

                    // 2) Bu Haftanın Toplam Satışı (StreamBuilder)
                    SizedBox(
                      width: cardWidth,
                      child: StreamBuilder<double>(
                        stream: analyticsProv.thisWeekSales$,
                        builder: (ctx2, snap) {
                          String text;
                          if (snap.hasError) {
                            text = '–';
                          } else if (!snap.hasData) {
                            text = 'Yükleniyor...';
                          } else {
                            text = '${snap.data!.toStringAsFixed(2)} ₺';
                          }
                          return _KpiCard(
                            title: 'Bu Haftanın Toplam Satışı',
                            value: text,
                          );
                        },
                      ),
                    ),

                    // 3) Bu Ayın Toplam Satışı (StreamBuilder)
                    SizedBox(
                      width: cardWidth,
                      child: StreamBuilder<double>(
                        stream: analyticsProv.thisMonthSales$,
                        builder: (ctx2, snap) {
                          String text;
                          if (snap.hasError) {
                            text = '–';
                          } else if (!snap.hasData) {
                            text = 'Yükleniyor...';
                          } else {
                            text = '${snap.data!.toStringAsFixed(2)} ₺';
                          }
                          return _KpiCard(
                            title: 'Bu Ayın Toplam Satışı',
                            value: text,
                          );
                        },
                      ),
                    ),

                    // 4) Bugünkü Sipariş Adedi (StreamBuilder)
                    SizedBox(
                      width: cardWidth,
                      child: StreamBuilder<int>(
                        stream: analyticsProv.todayOrderCount$,
                        builder: (ctx2, snap) {
                          String text;
                          if (snap.hasError) {
                            text = '–';
                          } else if (!snap.hasData) {
                            text = 'Yükleniyor...';
                          } else {
                            text = snap.data!.toString();
                          }
                          return _KpiCard(
                            title: 'Bugünkü Sipariş Adedi',
                            value: text,
                          );
                        },
                      ),
                    ),

                    // 5) Ortalama Sipariş Tutarı (StreamBuilder)
                    SizedBox(
                      width: cardWidth,
                      child: StreamBuilder<double>(
                        stream: analyticsProv.avgOrderValueToday$,
                        builder: (ctx2, snap) {
                          String text;
                          if (snap.hasError) {
                            text = '–';
                          } else if (!snap.hasData) {
                            text = 'Yükleniyor...';
                          } else {
                            text = '${snap.data!.toStringAsFixed(2)} ₺';
                          }
                          return _KpiCard(
                            title: 'Ortalama Sipariş Tutarı',
                            value: text,
                          );
                        },
                      ),
                    ),

                    // 6) Günün En Yoğun Saatleri (StreamBuilder)
                    SizedBox(
                      width: cardWidth,
                      child: StreamBuilder<List<HourCount>>(
                        stream: analyticsProv.busiestHoursToday$,
                        builder: (ctx2, snap) {
                          if (snap.hasError) {
                            return _KpiCard(
                              title: 'Günün En Yoğun Saatleri',
                              value: '–',
                              fontSize: 12,
                              alignCenter: false,
                            );
                          }
                          if (!snap.hasData) {
                            return _KpiCard(
                              title: 'Günün En Yoğun Saatleri',
                              value: 'Yükleniyor...',
                              fontSize: 12,
                              alignCenter: false,
                            );
                          }
                          final List<HourCount> hours = snap.data!;
                          final top3 = hours.take(3).toList();
                          final valueText = top3.isEmpty
                              ? 'Veri yok'
                              : top3.map((hc) {
                                  final hStr =
                                      hc.hour.toString().padLeft(2, '0');
                                  final nextHour =
                                      (hc.hour + 1).toString().padLeft(2, '0');
                                  return '$hStr:00–$nextHour:00 (${hc.count})';
                                }).join('\n');
                          return _KpiCard(
                            title: 'Günün En Yoğun Saatleri',
                            value: valueText,
                            fontSize: 12,
                            alignCenter: false,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // —————————————— 2) Son 30 Gün Gelir Grafiği ——————————————
            const Text(
              'Son 30 Gün Gelir (₺)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            StreamBuilder<List<SalesData>>(
              stream: analyticsProv.last30DaysSales,
              builder: (ctx, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    'Hata: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final List<SalesData> sales = snapshot.data!;
                if (sales.isEmpty) {
                  return const Center(child: Text('Veri yok.'));
                }

                final double rawMaxY =
                    sales.map((e) => e.total).reduce((a, b) => a > b ? a : b);
                const double step = 500;
                final double maxY = ((rawMaxY / step).ceil()) * step;

                final now = DateTime.now();
                final startDate = DateTime(now.year, now.month, now.day)
                    .subtract(const Duration(days: 29));

                return SizedBox(
                  height: 250,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 8.0,
                      left: 8.0,
                      bottom: 8.0,
                    ),
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: 29,
                        minY: 0,
                        maxY: maxY,
                        gridData: FlGridData(
                          show: true,
                          horizontalInterval: maxY / 5,
                          verticalInterval: 5,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.withOpacity(0.3),
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                          getDrawingVerticalLine: (value) => FlLine(
                            color: Colors.grey.withOpacity(0.3),
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles:
                              AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles:
                              AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: maxY / 5,
                              reservedSize: 48,
                              getTitlesWidget: (value, meta) {
                                final text = value.toInt().toString();
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 4,
                                  child: Text(
                                    text,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black87),
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 5,
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) {
                                final int index = value.toInt();
                                if (index % 5 != 0) return const SizedBox.shrink();
                                final date =
                                    startDate.add(Duration(days: index));
                                final formatted = DateFormat('d/M').format(date);
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 6,
                                  child: Text(
                                    formatted,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black87),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        clipData: FlClipData.all(),
                        lineBarsData: [
                          LineChartBarData(
                            spots: sales.asMap().entries.map((entry) {
                              final int i = entry.key;
                              final double y = entry.value.total;
                              return FlSpot(i.toDouble(), y);
                            }).toList(),
                            isCurved: true,
                            barWidth: 3,
                            color: Colors.green.shade700,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.green.shade200.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
            // İleride ek grafik veya tablo geleceğinde buraya ekleyebilirsiniz
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────
///  Özel Widget: KPI Kart Tasarımı
/// ─────────────────────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final double fontSize;
  final bool alignCenter;

  const _KpiCard({
    Key? key,
    required this.title,
    required this.value,
    this.fontSize = 20,
    this.alignCenter = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              alignCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: alignCenter ? TextAlign.center : TextAlign.start,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
              textAlign: alignCenter ? TextAlign.center : TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}
