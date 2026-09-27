import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {
  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final email =
        _emailController.text.trim();

    final password =
        _passwordController.text;

    if (email.isEmpty) {
      _showMessage(
        'E-posta adresini girin.',
      );
      return;
    }

    if (password.isEmpty) {
      _showMessage(
        'Şifrenizi girin.',
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await AuthService.instance.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.of(context).pop();
    } on AuthException catch (e) {
      if (!mounted) return;

      _showMessage(e.message);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Giriş sırasında beklenmeyen bir hata oluştu: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _openRegister() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            const RegisterPage(),
      ),
    );
  }

  Future<void> _openForgotPassword() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            const ForgotPasswordPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Giriş yap',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 430,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.account_circle_rounded,
                    size: 76,
                    color: scheme.primary,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Stellar hesabına giriş yap',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hesabınla Stellar Center deneyimini cihazların arasında kullan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller:
                        _emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    autocorrect: false,
                    textInputAction:
                        TextInputAction.next,
                    decoration:
                        const InputDecoration(
                      labelText: 'E-posta',
                      hintText:
                          'ornek@mail.com',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                      ),
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller:
                        _passwordController,
                    obscureText:
                        _obscurePassword,
                    textInputAction:
                        TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_loading) {
                        _login();
                      }
                    },
                    decoration:
                        InputDecoration(
                      labelText: 'Şifre',
                      prefixIcon:
                          const Icon(
                        Icons.lock_outline_rounded,
                      ),
                      suffixIcon:
                          IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                        ),
                      ),
                      border:
                          const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment:
                        Alignment.centerRight,
                    child: TextButton(
                      onPressed:
                          _loading
                              ? null
                              : _openForgotPassword,
                      child: const Text(
                        'Şifremi unuttum',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed:
                          _loading
                              ? null
                              : _login,
                      child: _loading
                          ? const SizedBox(
                              width: 23,
                              height: 23,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Giriş yap',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hesabın yok mu?',
                        style: TextStyle(
                          color: scheme
                              .onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed:
                            _loading
                                ? null
                                : _openRegister,
                        child: const Text(
                          'Kayıt ol',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
