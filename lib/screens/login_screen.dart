import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/invite_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _inviteCode = TextEditingController();
  final _auth = AuthService();
  final _invite = InviteService(); // 🆕 servis örneği

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
          _msg('Giriş başarılı');
        } else {
          _msg('Giriş başarısız.');
        }
      } else {
        // 1) Employee ise davet kodunu doğrula
        if (role == 'employee') {
          final ok = await _invite.validate(_inviteCode.text.trim());
          if (!ok) {
            _msg('Kod geçersiz veya kullanılmış');
            return;
          }
        }

        // 2) Kullanıcıyı oluştur
        final user = await _auth.signUp(
          email: _email.text,
          password: _password.text,
          role: role,
        );

        // 3) Kayıt başarılıysa kodu kullan
        if (role == 'employee' && user != null) {
          await _invite.consume(_inviteCode.text.trim(), user.uid);
        }

        if (user != null) {
          _msg('Kayıt başarılı ($role)');
        } else {
          _msg('Kayıt başarısız.');
        }
      }
    } catch (e) {
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _email, decoration: const InputDecoration(labelText: 'E-posta')),
              TextField(
                controller: _password,
                decoration: const InputDecoration(labelText: 'Şifre'),
                obscureText: true,
              ),
              if (!isLogin)
                Column(
                  children: [
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
                    if (role == 'employee')
                      TextField(
                        controller: _inviteCode,
                        decoration: const InputDecoration(labelText: 'Davet Kodu'),
                      ),
                  ],
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
                child: Text(isLogin
                    ? 'Hesabın yok mu? Kayıt ol'
                    : 'Zaten hesabın var mı? Giriş yap'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
