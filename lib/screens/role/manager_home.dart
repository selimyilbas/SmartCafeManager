import 'package:flutter/material.dart';
import '../manager/dashboard_screen.dart';
import '../manager/menu_admin_screen.dart';
import '../manager/staff_screen.dart';
import '../manager/settings_screen.dart';
import '../manager/stock_alert_screen.dart';

class ManagerHome extends StatefulWidget {
  const ManagerHome({super.key});
  @override
  State<ManagerHome> createState() => _ManagerHomeState();
}

class _ManagerHomeState extends State<ManagerHome> {
  int idx = 0;
  static const _pages = [
    DashboardScreen(),
    MenuAdminScreen(),
    StaffScreen(),
    StockAlertScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('[Manager]')),
      body: _pages[idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (v) => setState(() => idx = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Dash'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Menu'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Staff'),
          NavigationDestination(icon: Icon(Icons.warning), label: 'Stock'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'More'),
        ],
      ),
    );
  }
}
