import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/table_monitor_provider.dart';
import '../../services/order_service.dart';

/*───────────────────────────────────────────────────────────*/
/*  TABLES  –  CANLI MASA MONİTÖRÜ                           */
/*───────────────────────────────────────────────────────────*/

class TableMonitorScreen extends StatelessWidget {
  const TableMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TableMonitorProvider>();

    return StreamBuilder(
      stream: prov.streamBusyTables(),
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
            final tData     = docs[i].data();
            final tableId   = docs[i].id;
            final sessionId = tData['activeSession'] as String;
            final guests    = tData['activeGuests'] ?? 0;
            final updatedTs = tData['lastUpdated'] as Timestamp?;
            final lastText  = updatedTs == null
                ? '—'
                : DateFormat.Hm().format(updatedTs.toDate());

            return _TableCard(
              tableId: tableId,
              sessionId: sessionId,
              guests: guests,
              lastText: lastText,
            );
          },
        );
      },
    );
  }
}

/*───────────────────────────────────────────────────────────*/
/*  KART – Tek masanın özeti + sipariş listesi               */
/*───────────────────────────────────────────────────────────*/

class _TableCard extends StatelessWidget {
  const _TableCard({
    required this.tableId,
    required this.sessionId,
    required this.guests,
    required this.lastText,
  });

  final String tableId;
  final String sessionId;
  final int guests;
  final String lastText;

  String _fmtHm(Timestamp ts) => DateFormat.Hm().format(ts.toDate());

  @override
  Widget build(BuildContext context) {
    final tablesProv = context.read<TableMonitorProvider>();
    final orderSrv = OrderService();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*---------------------------------------------------  ÜST SATIR */
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Masa: $tableId   ($guests kişi)',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),

                // ₺ Ödeme rozeti
                StreamBuilder<Map<String, double>>(
                  stream: tablesProv.totals(tableId, sessionId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    final totals = snapshot.data!;
                    final unpaid = totals['unpaid']!.toStringAsFixed(2);

                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: totals['unpaid'] != 0
                            ? Colors.orange.shade200
                            : Colors.green.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '₺$unpaid',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),

                FilledButton(
                  onPressed: () => tablesProv.forceClear(tableId),
                  child: const Text('Boşalt'),
                ),
              ],
            ),

            const SizedBox(height: 4),
            Text('Son hareket: $lastText',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),

            /*---------------------------------------------------  SİPARİŞLER */
            FutureBuilder(
              future: orderSrv
                  .streamActiveOrders(tableId, sessionId)
                  .first,
              builder: (ctx, snap) {
                if (!snap.hasData) return const SizedBox.shrink();
                final docs = snap.data!.docs;

                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      '✦ Henüz sipariş yok',
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                    ),
                  );
                }

                final lines = docs.map((o) {
                  final od = o.data();
                  final items = od['items'] as List;
                  final itemsTx = items
                      .map((i) =>
                          '${i['qty']}× ${i['name']}${(i['note'] ?? '').toString().trim().isNotEmpty ? ' (not:${i['note']})' : ''}')
                      .join(', ');
                  return '- [${od['status']}] $itemsTx  – ${_fmtHm(od['createdAt'])}';
                }).join('\n');

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(lines, style: const TextStyle(fontSize: 13)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
