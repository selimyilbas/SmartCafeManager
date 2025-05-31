// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────
// Temel provider’lar
import 'providers/auth_provider.dart';
import 'providers/table_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/shift_provider.dart';
import 'providers/kitchen_provider.dart';
import 'providers/stock_provider.dart';
import 'providers/table_monitor_provider.dart';

// ─────────────────────────────────────────────────────────────
// Yönetici (admin) modülü provider’ları
import 'providers/discount_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/shift_admin_provider.dart';
import 'providers/stock_admin_provider.dart';
import 'providers/menu_admin_provider.dart';
import 'providers/staff_admin_provider.dart';

// ─────────────────────────────────────────────────────────────
// Sipariş (order) modülü
import 'providers/order_provider.dart';

// ─────────────────────────────────────────────────────────────
// Ekranlar
import 'root_gate.dart';
import 'screens/login_screen.dart';
import 'screens/role/customer_home.dart';
import 'screens/role/employee_home.dart';
import 'screens/role/manager_home.dart';
import 'screens/menu_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/customer/past_orders_screen.dart'; // ← Bu satırı MUTLAKA ekleyin
import 'screens/customer/pay_screen.dart';
import 'screens/scan_table_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// Temel (auth, table, cart, shift, kitchen, stock vb.) provider’lar
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TableProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ShiftProvider()),
        ChangeNotifierProvider(create: (_) => KitchenProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => TableMonitorProvider()),

        /// Yönetici (Admin) modülü provider’ları
        ChangeNotifierProvider(create: (_) => ShiftAdminProvider()),
        ChangeNotifierProvider(create: (_) => DiscountProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => StockAdminProvider()),
        ChangeNotifierProvider(create: (_) => MenuAdminProvider()),
        ChangeNotifierProvider(create: (_) => StaffAdminProvider()),

        /// **Sipariş (Order) provider**
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Cafe Manager',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const RootGate(),
          '/login': (_) => const LoginScreen(),
          '/customerHome': (_) => const CustomerHome(),
          '/employeeHome': (_) => const EmployeeHome(),
          '/manager': (_) => const ManagerHome(),
          '/menu': (_) => const MenuScreen(),
          '/cart': (_) => const CartScreen(),

          /// **Mutlaka `/pastOrders` rotasını ekleyin!**
          '/pastOrders': (_) => const PastOrdersScreen(),

          /// “Ödeme” ekranı, navigator ile doğrudan açtığımız için buraya gerek yoksa silebilirsiniz:
          // '/pay': (_) => const PayScreen(),
        },
      ),
    );
  }
}
