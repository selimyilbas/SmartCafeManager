import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/table_provider.dart';
import 'providers/cart_provider.dart';

import 'root_gate.dart';
import 'screens/login_screen.dart';
import 'screens/role/customer_home.dart';   // customer nav
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
        ChangeNotifierProvider(create: (_) => CartProvider()),   // 🆕 sepet
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Cafe Manager',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
        ),

        /** ───── ROUTING ───── */
        initialRoute: '/',                // uygulama burada başlar
        routes: {
          '/':          (_) => const RootGate(),       // login-mi? değil-mi? karar verir
          '/login':     (_) => const LoginScreen(),
          '/customerHome': (_) => const CustomerHome(),// (RootGate sonrası pushNamed ile de kullanılabilir)
          '/menu':      (_) => const MenuScreen(),
          '/cart':      (_) => const CartScreen(),
        },
      ),
    );
  }
}
