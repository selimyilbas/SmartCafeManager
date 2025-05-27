// lib/screens/manager/stock_alert_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/section_card.dart';
import '../../providers/stock_admin_provider.dart';

class StockAlertScreen extends StatelessWidget {
  const StockAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<StockAdminProvider>();

    // ----------------------------------------
    // Yeni: tüm kalemlerin minQty'sini düzenleme dialog'u
    Future<void> _openEditMinDialog() async {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Edit Minimum Stock'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
              stream: prov.allItems$,
              builder: (ctx2, snap2) {
                if (!snap2.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap2.data!;
                if (docs.isEmpty) {
                  return const Center(child: Text('No inventory items.'));
                }
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx3, i) {
                    final doc = docs[i];
                    final data = doc.data();
                    final id = doc.id;
                    final name = data['name'] as String? ?? id;
                    final currentMin = (data['minQty'] as int?) ?? 0;
                    final ctrl = TextEditingController(text: currentMin.toString());
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text(name)),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              controller: ctrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () async {
                              final v = int.tryParse(ctrl.text.trim());
                              if (v != null) {
                                await prov.setMinQty(id, v);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('MinQty of "$name" set to $v'))
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
    // ----------------------------------------

    return SectionCard(
      title: '⚠️ Critical stock',
      onRefresh: () async {
        // Firestore stream zaten otomatik güncelliyor
        await Future.delayed(const Duration(milliseconds: 100));
      },
      child: Column(
        children: [
          // 1) Kritik kalemler listesi
          StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
            stream: prov.critical$,
            builder: (ctx, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snap.data!;
              if (docs.isEmpty) {
                return const Center(child: Text('All items are above minimum.'));
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final d = docs[i].data();
                  final name = d['name'] as String? ?? docs[i].id;
                  final stock = d['stockQty'] as int? ?? 0;
                  final minQty = d['minQty'] as int? ?? 0;
                  return ListTile(
                    title: Text(name),
                    subtitle: Text('Stock: $stock · Min: $minQty'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _openEditMinDialog,
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 12),

          // 2) Tüm item'lerin minQty'sini tek tek düzenlemek için buton
          OutlinedButton.icon(
            icon: const Icon(Icons.edit_calendar),
            label: const Text('Edit Minimum Stocks'),
            onPressed: _openEditMinDialog,
          ),
        ],
      ),
    );
  }
}
