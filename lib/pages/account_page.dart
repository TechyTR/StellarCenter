import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  User? get _user => AuthService.currentUser;

  Future<void> _logout() async {
    await AuthService.logout();

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _verifyEmail() async {
    await AuthService.sendEmailVerification();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Doğrulama e-postası gönderildi.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final scheme = Theme.of(context).colorScheme;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Hesap'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 440,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: 90,
                    color: scheme.primary,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Stellar Center Hesabı',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hesap oluşturarak Stellar Center '
                    'hizmetlerine bağlanabilirsin.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const LoginPage(),
                          ),
                        );

                        if (mounted) {
                          setState(() {});
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        child: Text('Giriş Yap'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const RegisterPage(),
                          ),
                        );

                        if (mounted) {
                          setState(() {});
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        child: Text(
                          'Yeni Hesap Oluştur',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesabım'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    child: Icon(
                      Icons.person_rounded,
                      size: 42,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Stellar Center Hesabı',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    user.email ?? 'E-posta yok',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(
                user.emailVerified
                    ? Icons.verified_rounded
                    : Icons.warning_amber_rounded,
                color: user.emailVerified
                    ? Colors.green
                    : Colors.orange,
              ),
              title: Text(
                user.emailVerified
                    ? 'E-posta doğrulandı'
                    : 'E-posta doğrulanmadı',
              ),
              subtitle: user.emailVerified
                  ? null
                  : const Text(
                      'Hesabını doğrulamak için '
                      'e-postanı kontrol et.',
                    ),
              trailing: user.emailVerified
                  ? null
                  : TextButton(
                      onPressed: _verifyEmail,
                      child: const Text('Gönder'),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: _logout,
            icon: const Icon(
              Icons.logout_rounded,
            ),
            label: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}
