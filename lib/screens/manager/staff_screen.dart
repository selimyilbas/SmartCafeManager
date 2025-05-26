import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_cafe_manager/widgets/section_card.dart';
import '../../providers/staff_admin_provider.dart';
import 'shift_history_screen.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<StaffAdminProvider>();

    return SectionCard(
      title: '👥 Employees',
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 100));
      },
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: prov.streamEmployees(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final u = docs[i].data();
              final name = u['displayName'] as String? ?? u['email'] as String;
              return ListTile(
                title: Text(name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShiftHistoryScreen(
                      uid: docs[i].id,
                      name: name,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
