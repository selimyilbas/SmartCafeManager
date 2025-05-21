import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();

  bool isLogin = true;
  bool loading = false;
  String role = 'customer'; // varsayılan

  Future<void> _submit() async {
  if (_email.text.isEmpty || _password.text.isEmpty) return;

  setState(() => loading = true);
  try {
    print('[UI] Butona basıldı. isLogin: $isLogin');

    if (isLogin) {
      final user = await _auth.signIn(_email.text, _password.text);
      if (user != null) {
        print('[UI] Giriş başarılı: ${user.uid}');
        _msg('Giriş başarılı');
      } else {
        print('[UI] Giriş başarısız.');
        _msg('Giriş başarısız.');
      }
    } else {
      final user = await _auth.signUp(
        email: _email.text,
        password: _password.text,
        role: role,
      );
      if (user != null) {
        print('[UI] Kayıt başarılı: ${user.uid}');
        _msg('Kayıt başarılı ($role)');
      } else {
        print('[UI] Kayıt başarısız.');
        _msg('Kayıt başarısız.');
      }
    }
  } catch (e) {
    print('[UI] Hata yakalandı: $e');
    _msg('Hata: $e');
  } finally {
    setState(() => loading = false);
  }
}


  void _msg(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Giriş Yap' : 'Kayıt Ol')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'E-posta')),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Şifre'),
              obscureText: true,
            ),
            if (!isLogin) // sadece kayıt modunda rol seç
              DropdownButtonFormField<String>(
                value: role,
                items: const [
                  DropdownMenuItem(value: 'customer', child: Text('Customer')),
                  DropdownMenuItem(value: 'employee', child: Text('Employee')),
                  DropdownMenuItem(value: 'manager', child: Text('Manager')),
                ],
                onChanged: (v) => setState(() => role = v!),
                decoration: const InputDecoration(labelText: 'Rol seç'),
              ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submit,
                    child: Text(isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
                  ),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(isLogin ? 'Hesabın yok mu? Kayıt ol' : 'Zaten hesabın var mı? Giriş yap'),
            ),
          ],
        ),
      ),
    );
  }
}
