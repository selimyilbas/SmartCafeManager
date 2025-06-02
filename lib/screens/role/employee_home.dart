// lib/screens/role/employee_home.dart
//ashdoıuashdıuashd

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as app_auth;

import '../employee/kitchen_screen.dart';
import '../employee/stock_screen.dart';
import '../employee/table_monitor_screen.dart';
import '../employee/shift_screen.dart';

class EmployeeHome extends StatefulWidget {
  const EmployeeHome({Key? key}) : super(key: key);

  @override
  State<EmployeeHome> createState() => _EmployeeHomeState();
}

class _EmployeeHomeState extends State<EmployeeHome> {
  int _index = 0;

  static const _pages = <Widget>[
    KitchenScreen(),
    StockScreen(),
    TableMonitorScreen(),
    ShiftScreen(),
  ];

  void _onDestinationSelected(int newIndex) {
    setState(() {
      _index = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Stakeholder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<app_auth.AuthProvider>().signOut(),
          ),
        ],
      ),

      body: _pages[_index],

      // ——————————————————————————————————————————————
      // “Yeşil temalı” BottomNavigationBar (NavigationBar),
      // en az iki destinasyona sahip olduğu için buraya ekliyoruz:
      // ——————————————————————————————————————————————
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        selectedIndex: _index,
        indicatorColor: Colors.green.shade200,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.restaurant_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.restaurant, color: Colors.green.shade700),
            label: 'Kitchen',
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.inventory_2, color: Colors.green.shade700),
            label: 'Stock',
          ),
          NavigationDestination(
            icon: const Icon(Icons.chair_alt_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.chair_alt, color: Colors.green.shade700),
            label: 'Tables',
          ),
          NavigationDestination(
            icon: const Icon(Icons.access_time_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.access_time, color: Colors.green.shade700),
            label: 'Shift',
          ),
        ],
      ),
    );
  }
}
