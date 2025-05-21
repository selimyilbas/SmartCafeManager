import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManagerHome extends StatelessWidget {
  const ManagerHome({super.key});

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[Manager] Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: const Center(
        child: Text('Hoşgeldiniz Yönetici 👔'),
      ),
    );
  }
}
