import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/role/customer_home.dart';
import 'screens/role/employee_home.dart';
import 'screens/role/manager_home.dart';

class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.user == null) return const LoginScreen();

    switch (auth.role) {
      case 'customer':
        return const CustomerHome();
      case 'employee':
        return const EmployeeHome();
      case 'manager':
        return const ManagerHome();
      default:
        return const Scaffold(body: Center(child: Text('Rol bulunamadı')));
    }
  }
}
