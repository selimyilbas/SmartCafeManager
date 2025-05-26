// lib/screens/manager/shift_history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../widgets/section_card.dart';
import '../../providers/shift_admin_provider.dart';

class ShiftHistoryScreen extends StatelessWidget {
  final String uid;
  final String name;

  const ShiftHistoryScreen({
    super.key,
    required this.uid,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ShiftAdminProvider>();
    final fmt = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(title: Text("$name's Shift History")),
      body: SectionCard(
        title: '📜 Shift History',
        onRefresh: () async => Future.delayed(const Duration(milliseconds: 100)),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: prov.streamShifts(uid),
          builder:(ctx, snap) {
            if (snap.hasError) {
              return Center(
                child: Text(
                  'Error loading shift history:\n${snap.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snap.data!.docs;
            if (docs.isEmpty) {
              return const Center(child: Text('No shift history found.'));
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final data = docs[i].data();
                final inTs  = data['startedAt'] as Timestamp;
                final outTs = data['endedAt']   as Timestamp?;
                final inTime  = inTs.toDate();
                final outTime = outTs?.toDate();
                return ListTile(
                  title: Text('In:  ${fmt.format(inTime)}'),
                  subtitle: outTime != null
                    ? Text('Out: ${fmt.format(outTime)}')
                    : const Text('In progress', style: TextStyle(color: Colors.green)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
