import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart' as app_auth;
import '../employee/kitchen_screen.dart';
import '../employee/stock_screen.dart';
import '../employee/shift_screen.dart';

class EmployeeHome extends StatefulWidget {
  const EmployeeHome({super.key});

  @override
  State<EmployeeHome> createState() => _EmployeeHomeState();
}

class _EmployeeHomeState extends State<EmployeeHome> {
  /* ------------------------------------------------------------  Bottom-nav */
  int _index = 0;

  static const _pages = [
    KitchenScreen(),
    StockScreen(),
    ShiftScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* ------------------------------------------------------------  App-bar */
      appBar: AppBar(
        title: const Text('[Employee] Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<app_auth.AuthProvider>().signOut(),
          ),
        ],
      ),

      /* ------------------------------------------------------------  Body */
      body: _pages[_index],

      /* ------------------------------------------------------------  Nav-bar */
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant),
            label: 'Kitchen',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2),
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
