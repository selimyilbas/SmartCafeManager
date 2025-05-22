import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../providers/auth_provider.dart' as app_auth;
import '../employee/kitchen_screen.dart';
import '../employee/stock_screen.dart';
import '../employee/shift_screen.dart';


//import '../../providers/auth_provider.dart' ;
//import '../employee/shift_screen.dart';
//import '../../services/shift_service.dart';
//import '../../services/invite_service.dart';


class EmployeeHome extends StatefulWidget {
  const EmployeeHome({super.key});

  @override
  State<EmployeeHome> createState() => _EmployeeHomeState();
}

class _EmployeeHomeState extends State<EmployeeHome> {
  int idx = 0;

  final pages = const [
    KitchenScreen(),
    StockScreen(),
    ShiftScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[Employee] Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<app_auth.AuthProvider>().signOut(),
          ),
        ],
      ),
      body: pages[idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (value) => setState(() => idx = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant),
            label: 'Kitchen',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory),
            label: 'Stock',
          ),
          NavigationDestination(
            icon: Icon(Icons.access_time),
            label: 'Shift',
          ),
        ],
      ),
    );
  }
}
