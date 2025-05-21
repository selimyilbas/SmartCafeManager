import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/table_provider.dart';
import '../scan_table_screen.dart';

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});

  void _signOut(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    await auth.signOut();

    // Kullanıcıyı login ekranına yönlendir ve tüm önceki ekranları temizle
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
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
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Masa Tara'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ScanTableScreen()),
          );
        },
      ),
    );
  }
}
