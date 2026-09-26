import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const String _firebaseApiKey =
    String.fromEnvironment('FIREBASE_APIKEY');

  static const String _baseUrl =
      'https://identitytoolkit.googleapis.com/v1/accounts';

  String? _linuxIdToken;
  String? _linuxRefreshToken;
  String? _linuxLocalId;
  String? _linuxEmail;

  bool get isLinux => Platform.isLinux;
  bool get isAndroid => Platform.isAndroid;

  bool get isLoggedIn {
    if (Platform.isAndroid) {
      return FirebaseAuth.instance.currentUser != null;
    }

    if (Platform.isLinux) {
      return _linuxIdToken != null;
    }

    return false;
  }

  String? get currentEmail {
    if (Platform.isAndroid) {
      return FirebaseAuth.instance.currentUser?.email;
    }

    return _linuxEmail;
  }

  String? get currentUserId {
    if (Platform.isAndroid) {
      return FirebaseAuth.instance.currentUser?.uid;
    }

    return _linuxLocalId;
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty) {
      throw AuthException('E-posta adresi boş bırakılamaz.');
    }

    if (password.length < 6) {
      throw AuthException(
        'Şifre en az 6 karakter olmalıdır.',
      );
    }

    if (Platform.isAndroid) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        return;
      } on FirebaseAuthException catch (e) {
        throw AuthException(_firebaseError(e.code));
      }
    }

    if (Platform.isLinux) {
      final response = await http.post(
        Uri.parse(
          '$_baseUrl:signUp?key=$_firebaseApiKey',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'returnSecureToken': true,
        }),
      );

      _handleLinuxResponse(response);
      return;
    }

    throw AuthException(
      'Bu platformda hesap sistemi desteklenmiyor.',
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty) {
      throw AuthException('E-posta adresi boş bırakılamaz.');
    }

    if (password.isEmpty) {
      throw AuthException('Şifre boş bırakılamaz.');
    }

    if (Platform.isAndroid) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        return;
      } on FirebaseAuthException catch (e) {
        throw AuthException(_firebaseError(e.code));
      }
    }

    if (Platform.isLinux) {
      final response = await http.post(
        Uri.parse(
          '$_baseUrl:signInWithPassword?key=$_firebaseApiKey',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'returnSecureToken': true,
        }),
      );

      _handleLinuxResponse(response);
      return;
    }

    throw AuthException(
      'Bu platformda hesap sistemi desteklenmiyor.',
    );
  }

  Future<void> logout() async {
    if (Platform.isAndroid) {
      await FirebaseAuth.instance.signOut();
      return;
    }

    if (Platform.isLinux) {
      _linuxIdToken = null;
      _linuxRefreshToken = null;
      _linuxLocalId = null;
      _linuxEmail = null;
    }
  }

  Future<void> sendPasswordResetEmail(
    String email,
  ) async {
    if (email.trim().isEmpty) {
      throw AuthException(
        'E-posta adresi boş bırakılamaz.',
      );
    }

    if (Platform.isAndroid) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: email.trim(),
        );

        return;
      } on FirebaseAuthException catch (e) {
        throw AuthException(_firebaseError(e.code));
      }
    }

    if (Platform.isLinux) {
      final response = await http.post(
        Uri.parse(
          '$_baseUrl:sendOobCode?key=$_firebaseApiKey',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'requestType': 'PASSWORD_RESET',
          'email': email.trim(),
        }),
      );

      _handleLinuxResponse(response);
      return;
    }

    throw AuthException(
      'Bu platformda şifre sıfırlama desteklenmiyor.',
    );
  }

  Future<void> sendEmailVerification() async {
    if (Platform.isAndroid) {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw AuthException(
          'Önce hesabınıza giriş yapmalısınız.',
        );
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }

      return;
    }

    if (Platform.isLinux) {
      if (_linuxIdToken == null) {
        throw AuthException(
          'Önce hesabınıza giriş yapmalısınız.',
        );
      }

      final response = await http.post(
        Uri.parse(
          '$_baseUrl:sendOobCode?key=$_firebaseApiKey',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'requestType': 'VERIFY_EMAIL',
          'idToken': _linuxIdToken,
        }),
      );

      _handleLinuxResponse(response);
      return;
    }

    throw AuthException(
      'Bu platformda e-posta doğrulama desteklenmiyor.',
    );
  }

  bool get isEmailVerified {
    if (Platform.isAndroid) {
      return FirebaseAuth.instance.currentUser?.emailVerified ??
          false;
    }

    return false;
  }

  void _handleLinuxResponse(
    http.Response response,
  ) {
    final Map<String, dynamic> data;

    try {
      data = jsonDecode(response.body)
          as Map<String, dynamic>;
    } catch (_) {
      throw AuthException(
        'Firebase sunucusundan geçersiz yanıt alındı.',
      );
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      _saveLinuxSession(data);
      return;
    }

    final error =
        data['error'] as Map<String, dynamic>?;

    final message =
        error?['message']?.toString();

    throw AuthException(
      _linuxError(message),
    );
  }

  void _saveLinuxSession(
    Map<String, dynamic> data,
  ) {
    _linuxIdToken =
        data['idToken']?.toString();

    _linuxRefreshToken =
        data['refreshToken']?.toString();

    _linuxLocalId =
        data['localId']?.toString();

    _linuxEmail =
        data['email']?.toString();
  }

  String _firebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor.';

      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';

      case 'weak-password':
        return 'Şifre çok zayıf.';

      case 'user-not-found':
        return 'Bu e-posta adresine ait hesap bulunamadı.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';

      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';

      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Daha sonra tekrar deneyin.';

      case 'network-request-failed':
        return 'İnternet bağlantısı kurulamadı.';

      default:
        return 'Firebase hatası: $code';
    }
  }

  String _linuxError(String? code) {
    switch (code) {
      case 'EMAIL_EXISTS':
        return 'Bu e-posta adresi zaten kullanılıyor.';

      case 'INVALID_EMAIL':
        return 'Geçersiz e-posta adresi.';

      case 'WEAK_PASSWORD':
        return 'Şifre çok zayıf.';

      case 'EMAIL_NOT_FOUND':
        return 'Bu e-posta adresine ait hesap bulunamadı.';

      case 'INVALID_PASSWORD':
        return 'E-posta veya şifre hatalı.';

      case 'USER_DISABLED':
        return 'Bu hesap devre dışı bırakılmış.';

      case 'OPERATION_NOT_ALLOWED':
        return 'E-posta/şifre ile giriş Firebase tarafında etkin değil.';

      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        return 'Çok fazla deneme yapıldı. Daha sonra tekrar deneyin.';

      case 'INVALID_API_KEY':
        return 'Firebase API anahtarı geçersiz.';

      default:
        return 'Firebase hatası: ${code ?? 'Bilinmeyen hata'}';
    }
  }
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
