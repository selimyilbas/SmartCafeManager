// lib/screens/manager/staff_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/section_card.dart';
// BURADA ShiftAdminProvider DİĞİL StaffAdminProvider İÇERİSİNİ import edelim
import '../../providers/staff_admin_provider.dart';
import 'shift_history_screen.dart';

/// Manager ana ekranındaki “👥 Employees” bölümü.
class StaffScreen extends StatelessWidget {
  const StaffScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 👇 Burayı da StaffAdminProvider olarak değiştiriyoruz
    final prov = context.watch<StaffAdminProvider>();

    return SectionCard(
      title: '👥 Employees',
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 100));
      },
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // 👇 streamEmployees() zaten StaffAdminProvider’da var
        stream: prov.streamEmployees(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No employees found.'));
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final data = docs[i].data();
              final email = (data['displayName'] as String?) ?? data['email'] as String;
              final uid   = docs[i].id;
              return ListTile(
                title: Text(email),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShiftHistoryScreen(uid: uid, name: email),
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
