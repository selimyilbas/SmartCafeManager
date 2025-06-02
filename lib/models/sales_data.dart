// lib/models/sales_data.dart

/// Tek bir güne ait toplam satış bilgisini tutan model.
///   date: o günün DateTime’ı (saat kısmı 00:00:00),
///   total: o günkü satış toplamı (TL cinsinden)
class SalesData {
  final DateTime date;
  final double total;

  SalesData(this.date, this.total);
}
