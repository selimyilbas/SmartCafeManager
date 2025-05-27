// lib/screens/role/manager_home.dart

import 'package:flutter/material.dart';
import '../manager/dashboard_screen.dart';
import '../manager/menu_admin_screen.dart';
import '../manager/staff_screen.dart';
import '../manager/stock_alert_screen.dart';
import '../manager/settings_screen.dart';

class ManagerHome extends StatefulWidget {
  const ManagerHome({super.key});

  @override
  State<ManagerHome> createState() => _ManagerHomeState();
}

class _ManagerHomeState extends State<ManagerHome> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    DashboardScreen(),
    MenuAdminScreen(),
    StaffScreen(),
    StockAlertScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[Manager]'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Dash',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Staff',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning),
            label: 'Stock',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
