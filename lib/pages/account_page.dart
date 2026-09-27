import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_page.dart';
import 'register_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({
    super.key,
  });

  @override
  State<AccountPage> createState() =>
      _AccountPageState();
}

class _AccountPageState
    extends State<AccountPage> {
  AuthService get _auth =>
      AuthService.instance;

  bool _sendingVerification = false;
  bool _checkingVerification = false;

  Future<void> _logout() async {
    try {
      await _auth.logout();

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Çıkış yapıldı.',
          ),
        ),
      );
    } on AuthException catch (e) {
      _showMessage(e.message);
    }
  }

  Future<void> _verifyEmail() async {
    if (_sendingVerification) {
      return;
    }

    setState(() {
      _sendingVerification = true;
    });

    try {
      await _auth.sendEmailVerification();

      if (!mounted) return;

      _showMessage(
        'Doğrulama e-postası gönderildi. '
        'Gelen kutunu ve spam klasörünü kontrol et.',
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      _showMessage(e.message);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Doğrulama e-postası gönderilemedi: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _sendingVerification = false;
        });
      }
    }
  }

  Future<void> _checkVerification() async {
    if (_checkingVerification) {
      return;
    }

    setState(() {
      _checkingVerification = true;
    });

    try {
      final verified =
          await _auth.refreshEmailVerificationStatus();

      if (!mounted) return;

      setState(() {});

      _showMessage(
        verified
            ? 'E-posta adresin doğrulandı.'
            : 'E-posta henüz doğrulanmamış.',
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      _showMessage(e.message);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Doğrulama durumu kontrol edilemedi: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _checkingVerification = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _openLogin() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openRegister() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            const RegisterPage(),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = _auth.isLoggedIn;
    final email = _auth.currentEmail;
    final verified = _auth.isEmailVerified;
    final photoUrl = _auth.currentPhotoUrl;

    final scheme =
        Theme.of(context).colorScheme;

    if (!loggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Hesap'),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 440,
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: 90,
                    color: scheme.primary,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Stellar Center Hesabı',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hesabına giriş yap veya yeni '
                    'bir hesap oluştur.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _openLogin,
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        child:
                            Text('Giriş Yap'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child:
                        OutlinedButton(
                      onPressed:
                          _openRegister,
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(
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
              padding:
                  const EdgeInsets.all(22),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundImage:
                        photoUrl != null &&
                                photoUrl.isNotEmpty
                            ? NetworkImage(
                                photoUrl,
                              )
                            : null,
                    child: photoUrl == null ||
                            photoUrl.isEmpty
                        ? Icon(
                            Icons.person_rounded,
                            size: 42,
                            color:
                                scheme.primary,
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Stellar Center Hesabı',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    email ?? 'E-posta yok',
                    textAlign:
                        TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(4),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      verified
                          ? Icons
                              .verified_rounded
                          : Icons
                              .warning_amber_rounded,
                      color: verified
                          ? Colors.green
                          : Colors.orange,
                    ),
                    title: Text(
                      verified
                          ? 'E-posta doğrulandı'
                          : 'E-posta doğrulanmadı',
                    ),
                    subtitle: verified
                        ? null
                        : const Text(
                            'Hesabını doğrulamak için '
                            'e-postanı kontrol et.',
                          ),
                    trailing: verified
                        ? null
                        : TextButton(
                            onPressed:
                                _sendingVerification
                                    ? null
                                    : _verifyEmail,
                            child:
                                _sendingVerification
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth:
                                              2,
                                        ),
                                      )
                                    : const Text(
                                        'Gönder',
                                      ),
                          ),
                  ),
                  if (!verified)
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        10,
                      ),
                      child: SizedBox(
                        width:
                            double.infinity,
                        child:
                            OutlinedButton.icon(
                          onPressed:
                              _checkingVerification
                                  ? null
                                  : _checkVerification,
                          icon:
                              _checkingVerification
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons
                                          .refresh_rounded,
                                    ),
                          label: Text(
                            _checkingVerification
                                ? 'Kontrol ediliyor...'
                                : 'Doğrulamayı kontrol et',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: _logout,
            icon: const Icon(
              Icons.logout_rounded,
            ),
            label: const Text(
              'Çıkış Yap',
            ),
          ),
        ],
      ),
    );
  }
}
