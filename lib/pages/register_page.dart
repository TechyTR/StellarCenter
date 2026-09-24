import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
  });

  @override
  State<RegisterPage> createState() =>
      _RegisterPageState();
}

class _RegisterPageState
    extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController =
      TextEditingController();
  final _confirmPasswordController =
      TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    final email =
        _emailController.text.trim();

    final password =
        _passwordController.text;

    final confirmPassword =
        _confirmPasswordController.text;

    if (email.isEmpty) {
      _showError(
        'E-posta adresini girin.',
      );
      return;
    }

    if (password.length < 6) {
      _showError(
        'Şifre en az 6 karakter olmalıdır.',
      );
      return;
    }

    if (password != confirmPassword) {
      _showError(
        'Şifreler eşleşmiyor.',
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await AuthService.instance.register(
        email: email,
        password: password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Hesabın başarıyla oluşturuldu.',
          ),
        ),
      );

      Navigator.of(context).pop();
    } on AuthException catch (e) {
      if (!mounted) return;

      _showError(e.message);
    } catch (_) {
      if (!mounted) return;

      _showError(
        'Kayıt sırasında beklenmeyen bir hata oluştu.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
          'Hesap oluştur',
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
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 70,
                    color: scheme.primary,
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Stellar hesabını oluştur',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Android ve Linux üzerinde aynı hesabı kullan.',
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
                        TextInputAction.next,
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

                  const SizedBox(height: 14),

                  TextField(
                    controller:
                        _confirmPasswordController,
                    obscureText:
                        _obscureConfirmPassword,
                    textInputAction:
                        TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_loading) {
                        _register();
                      }
                    },
                    decoration:
                        InputDecoration(
                      labelText:
                          'Şifreyi tekrar gir',
                      prefixIcon:
                          const Icon(
                        Icons.lock_reset_rounded,
                      ),
                      suffixIcon:
                          IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmPassword
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

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed:
                          _loading
                              ? null
                              : _register,
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
                              'Hesap oluştur',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Hesap oluşturduğunda aynı e-posta ve şifreyle Stellar Center\'a Android ve Linux üzerinden giriş yapabilirsin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          scheme.onSurfaceVariant,
                    ),
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
