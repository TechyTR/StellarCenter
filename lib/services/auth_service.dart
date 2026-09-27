import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const String _firebaseApiKey =
      String.fromEnvironment('FIREBASE_APIKEY');

  static const String _baseUrl =
      'https://identitytoolkit.googleapis.com/v1/accounts';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'profile',
    ],
  );

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

  String? get currentPhotoUrl {
    if (Platform.isAndroid) {
      return FirebaseAuth.instance.currentUser?.photoURL;
    }

    return null;
  }

  String? get currentDisplayName {
    if (Platform.isAndroid) {
      return FirebaseAuth.instance.currentUser?.displayName;
    }

    return null;
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty) {
      throw AuthException(
        'E-posta adresi boş bırakılamaz.',
      );
    }

    if (password.length < 6) {
      throw AuthException(
        'Şifre en az 6 karakter olmalıdır.',
      );
    }

    if (Platform.isAndroid) {
      try {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );

        final user = credential.user;

        if (user == null) {
          throw AuthException(
            'Hesap oluşturuldu ancak kullanıcı oturumu alınamadı.',
          );
        }

        try {
          await user.sendEmailVerification();
        } on FirebaseAuthException catch (e) {
          throw AuthException(
            'Hesap oluşturuldu ancak doğrulama e-postası '
            'gönderilemedi: ${_firebaseError(e.code)}',
          );
        }

        return;
      } on FirebaseAuthException catch (e) {
        throw AuthException(
          _firebaseError(e.code),
        );
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
          'email': normalizedEmail,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      _handleLinuxResponse(response);

      await sendEmailVerification();

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
    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty) {
      throw AuthException(
        'E-posta adresi boş bırakılamaz.',
      );
    }

    if (password.isEmpty) {
      throw AuthException(
        'Şifre boş bırakılamaz.',
      );
    }

    if (Platform.isAndroid) {
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );

        return;
      } on FirebaseAuthException catch (e) {
        throw AuthException(
          _firebaseError(e.code),
        );
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
          'email': normalizedEmail,
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

  Future<void> signInWithGoogle() async {
    if (!Platform.isAndroid) {
      throw AuthException(
        'Google ile giriş şu anda yalnızca Android üzerinde destekleniyor.',
      );
    }

    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException(
          'Google ile giriş iptal edildi.',
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null || idToken.isEmpty) {
        throw AuthException(
          'Google kimlik doğrulama belirteci alınamadı.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final user = userCredential.user;

      if (user == null) {
        throw AuthException(
          'Google hesabı ile giriş yapıldı ancak kullanıcı '
          'bilgileri alınamadı.',
        );
      }

      final googlePhotoUrl = googleUser.photoUrl;
      final googleDisplayName = googleUser.displayName;

      if ((googlePhotoUrl != null &&
              googlePhotoUrl.isNotEmpty) ||
          (googleDisplayName != null &&
              googleDisplayName.isNotEmpty)) {
        await user.updateProfile(
          displayName: googleDisplayName,
          photoURL: googlePhotoUrl,
        );

        await user.reload();
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _firebaseError(e.code),
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      final message = e.toString();

      if (message.contains('sign_in_canceled') ||
          message.contains('canceled') ||
          message.contains('cancelled')) {
        throw AuthException(
          'Google ile giriş iptal edildi.',
        );
      }

      throw AuthException(
        'Google ile giriş yapılamadı: $e',
      );
    }
  }

  Future<void> logout() async {
    if (Platform.isAndroid) {
      await FirebaseAuth.instance.signOut();

      try {
        await _googleSignIn.signOut();
      } catch (_) {}

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
    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty) {
      throw AuthException(
        'E-posta adresi boş bırakılamaz.',
      );
    }

    if (Platform.isAndroid) {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(
          email: normalizedEmail,
        );

        return;
      } on FirebaseAuthException catch (e) {
        throw AuthException(
          _firebaseError(e.code),
        );
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
          'email': normalizedEmail,
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
      final auth = FirebaseAuth.instance;
      var user = auth.currentUser;

      if (user == null) {
        throw AuthException(
          'Önce hesabınıza giriş yapmalısınız.',
        );
      }

      await user.reload();
      user = auth.currentUser;

      if (user == null) {
        throw AuthException(
          'Kullanıcı oturumu yenilenemedi.',
        );
      }

      if (user.emailVerified) {
        return;
      }

      try {
        await user.sendEmailVerification();
      } on FirebaseAuthException catch (e) {
        throw AuthException(
          _firebaseVerificationError(e.code),
        );
      } catch (e) {
        throw AuthException(
          'Doğrulama e-postası gönderilemedi: $e',
        );
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

      _handleLinuxResponse(
        response,
        saveSession: false,
      );

      return;
    }

    throw AuthException(
      'Bu platformda e-posta doğrulama desteklenmiyor.',
    );
  }

  Future<bool> refreshEmailVerificationStatus() async {
    if (Platform.isAndroid) {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;

      if (user == null) {
        return false;
      }

      await user.reload();

      return auth.currentUser?.emailVerified ?? false;
    }

    return false;
  }

  bool get isEmailVerified {
    if (Platform.isAndroid) {
      return FirebaseAuth.instance.currentUser
              ?.emailVerified ??
          false;
    }

    return false;
  }

  void _handleLinuxResponse(
    http.Response response, {
    bool saveSession = true,
  }) {
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
      if (saveSession) {
        _saveLinuxSession(data);
      }

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

  String _firebaseVerificationError(
    String code,
  ) {
    switch (code) {
      case 'too-many-requests':
        return 'Doğrulama e-postası çok sık istendi. '
            'Biraz bekleyip tekrar deneyin.';

      case 'network-request-failed':
        return 'İnternet bağlantısı kurulamadı.';

      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';

      case 'invalid-user-token':
      case 'user-token-expired':
        return 'Oturum süresi dolmuş. Tekrar giriş yapın.';

      case 'operation-not-allowed':
        return 'E-posta doğrulama işlemi Firebase tarafında '
            'etkin değil.';

      default:
        return 'Firebase doğrulama hatası: $code';
    }
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
        return 'Çok fazla deneme yapıldı. '
            'Daha sonra tekrar deneyin.';

      case 'network-request-failed':
        return 'İnternet bağlantısı kurulamadı.';

      case 'operation-not-allowed':
        return 'E-posta/şifre ile giriş Firebase tarafında '
            'etkin değil.';

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

      case 'INVALID_ID_TOKEN':
      case 'TOKEN_EXPIRED':
        return 'Firebase oturumunun süresi dolmuş. Tekrar giriş yapın.';

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
