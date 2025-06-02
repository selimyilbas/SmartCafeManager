// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_cafe_manager/providers/kitchen_provider.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

// Provider’larınızı import edin
import 'providers/auth_provider.dart';
import 'providers/table_provider.dart';
import 'providers/shift_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/stock_provider.dart';
import 'providers/table_monitor_provider.dart';
import 'providers/order_provider.dart';
import 'providers/analytics_provider.dart';

import 'providers/discount_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/shift_admin_provider.dart';
import 'providers/stock_admin_provider.dart';
import 'providers/menu_admin_provider.dart';
import 'providers/staff_admin_provider.dart'; // AnalyticsProvider’ı mutlaka ekleyin

// RootGate ve diğer ekranlar
import 'root_gate.dart';            // lib/screens/role/root_gate.dart
import 'screens/login_screen.dart';     // lib/screens/customer/login_screen.dart
import 'screens/role/customer_home.dart';        // lib/screens/role/customer_home.dart
import 'screens/role/employee_home.dart';        // lib/screens/role/employee_home.dart
import 'screens/role/manager_home.dart';         // lib/screens/role/manager_home.dart
import 'screens/menu_screen.dart';      // lib/screens/customer/menu_screen.dart
import 'screens/cart_screen.dart';      // lib/screens/customer/cart_screen.dart
import 'screens/customer/past_orders_screen.dart'; // lib/screens/customer/past_orders_screen.dart
import 'screens/customer/pay_screen.dart';       // lib/screens/customer/pay_screen.dart
import 'screens/scan_table_screen.dart'; // lib/screens/customer/scan_table_screen.dart




void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Eğer Firebase kullanıyorsanız, aşağıdaki satırların yorumunu kaldırın
  // ve kendi firebase_options.dart dosyanızı import edip doğru initializeApp() çağrısını yapın:
  //
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TableProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()), 
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => TableMonitorProvider()),
        ChangeNotifierProvider(create: (_) => ShiftProvider()),
        ChangeNotifierProvider(create: (_) => DiscountProvider()),
        ChangeNotifierProvider(create: (_) => ShiftAdminProvider()),
        ChangeNotifierProvider(create: (_) => StockAdminProvider()),
        ChangeNotifierProvider(create: (_) => MenuAdminProvider()),
        ChangeNotifierProvider(create: (_) => StaffAdminProvider()),
        ChangeNotifierProvider(create: (_) => KitchenProvider()),
        

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Cafe Manager',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/':             (ctx) => const RootGate(),
        '/login':        (ctx) => const LoginScreen(),
        '/customerHome': (ctx) => const CustomerHome(),
        '/employeeHome': (ctx) => const EmployeeHome(),
        '/managerHome':  (ctx) => const ManagerHome(),
        '/menu':         (ctx) => const MenuScreen(),
        '/cart':         (ctx) => const CartScreen(),
        '/pastOrders':   (ctx) => const PastOrdersScreen(),
        '/pay':          (ctx) => const PayScreen(),
        '/scanTable':    (ctx) => const ScanTableScreen(),
        // … gerekiyorsa diğer route’larınızı da buraya ekleyin …
      },
    );
  }
}
