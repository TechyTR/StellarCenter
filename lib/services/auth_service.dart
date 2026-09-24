import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  static Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static Future<void> sendPasswordResetEmail(
    String email,
  ) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  static Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;

    if (user == null || user.emailVerified) {
      return;
    }

    await user.sendEmailVerification();
  }

  static Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  static String errorMessage(
    FirebaseAuthException error,
  ) {
    switch (error.code) {
      case 'invalid-email':
        return 'Geçerli bir e-posta adresi girin.';

      case 'user-not-found':
        return 'Bu e-posta adresiyle kayıtlı hesap bulunamadı.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';

      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor.';

      case 'weak-password':
        return 'Şifre çok zayıf. Daha güçlü bir şifre kullanın.';

      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Bir süre sonra tekrar deneyin.';

      case 'network-request-failed':
        return 'İnternet bağlantısını kontrol edin.';

      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';

      default:
        return error.message ??
            'Bir kimlik doğrulama hatası oluştu.';
    }
  }
}
