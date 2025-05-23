import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as app_auth;

import '../employee/kitchen_screen.dart';
import '../employee/stock_screen.dart';
import '../employee/table_monitor_screen.dart';
import '../employee/shift_screen.dart';

class EmployeeHome extends StatefulWidget {
  const EmployeeHome({super.key});

  @override
  State<EmployeeHome> createState() => _EmployeeHomeState();
}

class _EmployeeHomeState extends State<EmployeeHome> {
  /* ----------------------------- bottom-nav state */
  int _index = 0;

  static const _pages = <Widget>[
    KitchenScreen(),
    StockScreen(),
    TableMonitorScreen(),
    ShiftScreen(),
  ];

  /* ------------------------------------ widget */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[Employee] Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<app_auth.AuthProvider>().signOut(),
          ),
        ],
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (v) => setState(() => _index = v),
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
            icon: Icon(Icons.chair_alt),
            label: 'Tables',
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
