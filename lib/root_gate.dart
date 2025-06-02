// lib/screens/role/root_gate.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 1) AuthProvider dosyanızın konumu:
//    lib/providers/auth_provider.dart
import 'providers/auth_provider.dart';

// 2) Login ekranınızın konumu:
//    lib/screens/customer/login_screen.dart
import 'screens/login_screen.dart';

// 3) Rol bazlı ana sayfa widget’ları:
//    lib/screens/role/customer_home.dart
import 'screens/role/customer_home.dart';
//    lib/screens/role/employee_home.dart
import 'screens/role/employee_home.dart';
//    lib/screens/role/manager_home.dart
import 'screens/role/manager_home.dart';

class RootGate extends StatelessWidget {
  const RootGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Eğer henüz oturum yoksa login ekranına yönlendir:
    if (auth.user == null) {
      return const LoginScreen();
    }

    // Giriş yapılmış ise kullanıcı rolüne göre ilgili sayfaya yönlendir:
    switch (auth.role) {
      case 'customer':
        return const CustomerHome();
      case 'employee':
        return const EmployeeHome();
      case 'manager':
        return const ManagerHome();
      default:
        return const Scaffold(
          body: Center(child: Text('Rol bulunamadı 😕')),
        );
    }
  }
}
