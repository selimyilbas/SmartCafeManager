import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/table_monitor_provider.dart';

class TableMonitorScreen extends StatelessWidget {
  const TableMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TableMonitorProvider>();

    return StreamBuilder(
      stream: prov.stream(),           // aktif masalar
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('Tüm masalar boş'));
        }

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 12),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (_, i) {
            final d   = docs[i].data();
            final id  = docs[i].id;
            final guests = d['activeGuests'] ?? 0;
            final updated = (d['updatedAt'] as Timestamp?)?.toDate();
            final fmt = updated == null ? '—' : DateFormat.Hm().format(updated);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ► Üst satır  --------------------------------------------------
                    Row(
                      children: [
                        Expanded(
                          child: Text('Masa: $id   ($guests kişi)',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        FilledButton(
                          onPressed: () => prov.clear(id),
                          child: const Text('Boşalt'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Text('Son hareket: $fmt',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),

                    const SizedBox(height: 8),

                    // ► Sipariş listesi  ------------------------------------------
                    _OrderPreview(tableId: id),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _OrderPreview extends StatelessWidget {
  const _OrderPreview({required this.tableId});
  final String tableId;

  @override
  Widget build(BuildContext context) {
    final prov = context.read<TableMonitorProvider>();

    return StreamBuilder(
      stream: prov.streamOrders(tableId),
      builder: (ctx, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final ords = snap.data!.docs;

        if (ords.isEmpty) {
          return const Text('✦ Henüz sipariş yok',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: ords.map((o) {
            final od   = o.data();
            final time = (od['createdAt'] as Timestamp).toDate();
            final status = od['status']; // pending / preparing / ready
            final items = (od['items'] as List).map((e) {
              final q  = e['qty'];
              final nm = e['name'];
              final nt = (e['note'] ?? '').toString().trim();
              return '$q× $nm${nt.isNotEmpty ? ' (not: $nt)' : ''}';
            }).join(', ');
            final t   = DateFormat.Hm().format(time);
            return Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '• [$status] $items – $t',
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
