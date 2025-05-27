// lib/screens/manager/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Café Settings (coming soon)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
            child: ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Café Settings'),
              subtitle: const Text('coming soon'),
              onTap: () {
                // TODO: ileride ayarlar sayfası
              },
            ),
          ),
          const SizedBox(height: 16),
          // Logout
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout'),
              onTap: () async {
                // 1) Firebase çıkışı
                await auth.signOut();
                // 2) Tüm navigasyon stack’ini temizle, login ekranına dön
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (_) => false);
              },
            ),
          ),
        ],
      ),
    );
  }
}
