import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/table_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/shift_provider.dart';
import 'providers/kitchen_provider.dart';
import 'providers/stock_provider.dart';
import 'providers/table_monitor_provider.dart';



// 💼 Manager modülü provider’ları
import 'providers/discount_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/shift_admin_provider.dart';
import 'providers/stock_admin_provider.dart'; 
import 'providers/menu_admin_provider.dart';
import 'providers/staff_admin_provider.dart';




import 'root_gate.dart';
import 'screens/login_screen.dart';
import 'screens/role/customer_home.dart';
import 'screens/role/employee_home.dart';
import 'screens/role/manager_home.dart'; // 💼 Manager ana ekran
import 'screens/menu_screen.dart';
import 'screens/cart_screen.dart';

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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TableProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ShiftProvider()),
        ChangeNotifierProvider(create: (_) => KitchenProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => TableMonitorProvider()),
        ChangeNotifierProvider(create: (_) => ShiftAdminProvider()),
        ChangeNotifierProvider(create: (_) => DiscountProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => StockAdminProvider()),
        ChangeNotifierProvider(create: (_) => MenuAdminProvider()),
        ChangeNotifierProvider(create: (_) => StaffAdminProvider()),
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
          '/manager': (_) => const ManagerHome(), // 💼 Manager yönlendirmesi
          '/menu': (_) => const MenuScreen(),
          '/cart': (_) => const CartScreen(),
        },
      ),
    );
  }
}
