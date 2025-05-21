import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Hot reload sonrası login ekranına dönülecek (RootGate çalışıyor)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[Customer] Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          )
        ],
      ),
      body: const Center(child: Text('Hoşgeldin Müşteri 👋')),
    );
  }
}
