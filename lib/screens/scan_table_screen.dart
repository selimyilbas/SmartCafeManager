import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/table_provider.dart';
import '../../services/table_service.dart';

class ScanTableScreen extends StatefulWidget {
  const ScanTableScreen({super.key});
  @override
  State<ScanTableScreen> createState() => _ScanTableScreenState();
}

class _ScanTableScreenState extends State<ScanTableScreen> {
  final _tableService = TableService();
  String? scannedId;
  bool loading = false;

  Future<void> _validateAndSet(String id) async {
    setState(() => loading = true);
    final data = await _tableService.fetchTable(id);

    if (data == null) {
      _msg('Bu masa kayıtlı değil!');
    } else if (context.read<TableProvider>().tableId == id) {
      _msg('Zaten bu masadasınız.');
    } else {
      await context.read<TableProvider>().join(id);
      setState(() => scannedId = id);
      _msg('Masa bağlandı!');
    }

    setState(() => loading = false);
  }

  Future<void> _scanQR() async {
    final res = await FlutterBarcodeScanner.scanBarcode(
      '#00FF00', 'İptal', true, ScanMode.QR,
    );
    if (res != '-1') await _validateAndSet(res);
  }

  Future<void> _manualDialog() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Masa Kodu Gir'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Örn. T12'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (ctrl.text.isNotEmpty) {
                _validateAndSet(ctrl.text.trim());
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _msg(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TableProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Masa Seç')),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  prov.tableId == null
                      ? const Text('Henüz masa seçmediniz')
                      : Text(
                          'Seçilen Masa: ${prov.tableId}',
                          style: const TextStyle(fontSize: 20),
                        ),
                  const SizedBox(height: 25),
                  ElevatedButton.icon(
                    onPressed: _scanQR,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('QR Kodu Tara'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _manualDialog,
                    icon: const Icon(Icons.keyboard_alt),
                    label: const Text('Elle Kod Gir'),
                  ),
                ],
              ),
      ),
    );
  }
}
