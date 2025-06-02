// lib/screens/role/manager_home.dart

import 'package:flutter/material.dart';
import '../manager/dashboard_screen.dart';
import '../manager/menu_admin_screen.dart';
import '../manager/staff_screen.dart';
import '../manager/stock_alert_screen.dart';
import '../manager/settings_screen.dart';

class ManagerHome extends StatefulWidget {
  const ManagerHome({Key? key}) : super(key: key);

  @override
  State<ManagerHome> createState() => _ManagerHomeState();
}

class _ManagerHomeState extends State<ManagerHome> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
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
      // AppBar ve body kısmı değişmedi:
      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        // **Buraya ekliyoruz:**
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.black54,
        // Eğer ikonların sürekli gölge vs. olmadan sabit görünmesini isterseniz:
        // showSelectedLabels: true, 
        // showUnselectedLabels: true,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Dash',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Staff',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
