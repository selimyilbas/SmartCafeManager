/// lib/screens/login_screen.dart
///
/// Tek ekrandan **giriş + kayıt** — müşteri / çalışan / yönetici
///
/// ▸ Girişte rol Firebase *users* koleksiyonundan okunur  
/// ▸ Kayıtta *employee* & *manager* davet kodu ister  
/// ▸ Başarılı işlemin ardından doğru ekrana yönlendirir
///
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /* ────────────────────────── controller’lar */
  final _email      = TextEditingController();
  final _password   = TextEditingController();
  final _inviteCode = TextEditingController();

  /* ────────────────────────── ekran durumu  */
  bool  _isLogin   = true;
  bool  _loading   = false;
  String _roleSel  = 'customer';          // sadece kayıt modunda seçiliyor
  bool  get _needsInvite => _roleSel != 'customer';

  /* ═════════════════════════════════════════════════════════════ SUBMIT */
  Future<void> _submit() async {
  if (_email.text.isEmpty || _password.text.isEmpty) return;

  setState(() => _loading = true);
  try {
    final auth = context.read<AuthProvider>();
    late String next; // Gidilecek sayfa

    if (_isLogin) {
      final user = await auth.signIn(
        _email.text.trim(),
        _password.text.trim(),
      );
      if (user == null) throw 'Giriş başarısız';

      final role = await auth.fetchRole(user.uid);   // ◂ Firestore’dan oku
      next = _pathFor(role);
    } else {
      // ─ kayıt ─
      final user = await auth.signUp(
        email: _email.text.trim(),
        password: _password.text.trim(),
        role: _roleSel,
        inviteCode: _needsInvite ? _inviteCode.text.trim() : null,
      );
      if (user == null) throw 'Kayıt başarısız';
      next = _pathFor(_roleSel);
    }

    Navigator.pushReplacementNamed(context, next);
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.toString())));
  } finally {
    setState(() => _loading = false);
  }
}


  /* ══════════════════════════════════════ rol → route haritalaması */
  String _pathFor(String role) => switch (role) {
        'customer'  => '/customerHome',
        'employee'  => '/employeeHome',
        'manager'   => '/manager',
        _           => '/',
      };

  /* ══════════════════════════════════════════════════════════ UI */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Giriş Yap' : 'Kayıt Ol')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-posta'),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Şifre'),
              ),

              /* ───────────── kayıt modunda ekstra alanlar */
              if (!_isLogin) ...[
                DropdownButtonFormField<String>(
                  value: _roleSel,
                  decoration: const InputDecoration(labelText: 'Rol seç'),
                  items: const [
                    DropdownMenuItem(value: 'customer', child: Text('Customer')),
                    DropdownMenuItem(value: 'employee', child: Text('Employee')),
                    DropdownMenuItem(value: 'manager' , child: Text('Manager')),
                  ],
                  onChanged: (v) => setState(() => _roleSel = v!),
                ),
                if (_needsInvite) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _inviteCode,
                    decoration: const InputDecoration(labelText: 'Davet Kodu'),
                  ),
                ],
              ],

              const SizedBox(height: 28),

              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text(_isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
                    ),

              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin
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
