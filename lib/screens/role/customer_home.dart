import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/table_provider.dart';
import '../../services/call_service.dart';

import '../scan_table_screen.dart';
import '../customer/pay_screen.dart';

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});

  void _signOut(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    await auth.signOut();

    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final hasTable = context.watch<TableProvider>().tableId != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('[Customer] Home'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'leave', child: Text('Masadan Kalk')),
              PopupMenuItem(value: 'logout', child: Text('Çıkış Yap')),
            ],
            onSelected: (value) async {
              switch (value) {
                case 'leave':
                  await context.read<TableProvider>().leave();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Masa boşaltıldı')),
                  );
                  break;
                case 'logout':
                  _signOut(context);
                  break;
              }
            },
          ),
        ],
      ),

      body: const Center(
        child: Text('Hoşgeldin Müşteri 👋'),
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'scan',
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Masa Tara'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScanTableScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'call',
            icon: const Icon(Icons.support_agent),
            label: const Text('Garson'),
            onPressed: () {
              final tableId = context.read<TableProvider>().currentTableId;
              if (tableId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Önce masaya oturun')),
                );
                return;
              }
              CallService().sendCall(tableId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Çağrı gönderildi')),
              );
            },
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'pay',
            icon: const Icon(Icons.payment),
            label: const Text('Ödeme'),
            onPressed: hasTable
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PayScreen()),
                    );
                  }
                : null, // pasif yapar
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/menu'),
            child: const Text('Menüye Git'),
          ),
        ],
      ),
    );
  }
}
