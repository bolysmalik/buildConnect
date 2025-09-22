import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_valhalla/features/routing/data/services/Constants.dart';
import 'package:flutter_valhalla/features/routing/data/services/TelegramWebView.dart';
import 'package:flutter_valhalla/features/routing/data/services/SignInWithWhatsApp.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Helper: получение и логирование полного Firebase idToken (REMOVE IN PROD)
  Future<void> _logFirebaseTokenFull(User? user, {String prefix = '[Firebase]'}) async {
    if (user == null) {
      debugPrint("❌ $prefix Нет текущего пользователя, токен получить невозможно");
      return;
    }
    try {
      final token = await user.getIdToken();
      final tokenResult = await user.getIdTokenResult();
      // Полный токен — выводим через print чтобы не обрезал debugPrint. REMOVE IN PROD!
      print("🔥 $prefix FULL idToken: $token"); // REMOVE IN PROD
      debugPrint("🔑 $prefix expiresAt: ${tokenResult.expirationTime}");
      debugPrint("🔐 $prefix claims: ${tokenResult.claims}");
    } catch (e, st) {
      debugPrint("❌ $prefix Ошибка при получении idToken: $e");
      debugPrint("🔍 StackTrace:\n$st");
    }
  }

  /// GOOGLE вход (через сервер + Firebase)
  Future<UserCredential?> signInWithGoogleServer() async {
  debugPrint("👉 [Google] Начало авторизации...");

  try {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      debugPrint("❌ [Google] Пользователь отменил вход");
      return null;
    }
    debugPrint("✅ [Google] Пользователь выбран: ${googleUser.email}");

    final googleAuth = await googleUser.authentication;

    // 🔥 Логируем весь токен
    print("🔥 FULL Google idToken:\n${googleAuth.idToken}");
    print("🔥 FULL Google accessToken:\n${googleAuth.accessToken}");

    // 🔍 Декодируем payload idToken (JWT → JSON)
    if (googleAuth.idToken != null) {
      final parts = googleAuth.idToken!.split(".");
      if (parts.length == 3) {
        final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
        print("🔍 DECODED PAYLOAD: $payload");
      }
    }

    // 🔹 Отправка JSON на сервер в Swagger-формате
    final response = await http.post(
      Uri.parse(AppRedirectUris.google),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "id_token": googleAuth.idToken,
        "client_id": "1073936352246-tiaa7m4as8os9nhm7mp1bsn4dun58urt.apps.googleusercontent.com", // твой client_id
        "nonce": "" // можно пустым, если не используется
      }),
    );

    debugPrint("📩 [Server] Ответ: code=${response.statusCode}, body=${response.body}");

    if (response.statusCode != 200) {
      debugPrint("❌ [Server] Сервер отклонил Google токен");
      return null;
    }

    // 🔹 Firebase авторизация
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);
    debugPrint("✅ [Firebase] Успешный вход: ${userCred.user?.email} (uid=${userCred.user?.uid})");

    // 🔥 Получаем idToken Firebase
    final firebaseIdToken = await userCred.user?.getIdToken();
    print("🔥 FULL Firebase idToken:\n$firebaseIdToken");

    return userCred;
  } catch (e, st) {
    debugPrint("❌ [Google/Auth] Ошибка: $e");
    debugPrint("🔍 StackTrace:\n$st");
    return null;
  }
}


  /// APPLE вход (через сервер + Firebase)
  Future<UserCredential?> signInWithAppleServer() async {
    debugPrint("👉 [Apple] Начало авторизации...");

    try {
      final appleCred = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      debugPrint("✅ [Apple] Токены получены: "
          "idToken=${appleCred.identityToken?.substring(0, 20)}..., "
          "authCode=${appleCred.authorizationCode.substring(0, 20)}...");

      // Отправка на сервер
      debugPrint("👉 [Server] Отправка Apple токена: ${AppRedirectUris.apple}");
      final response = await http.post(
        Uri.parse(AppRedirectUris.apple),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': appleCred.identityToken}),
      );

      debugPrint("📩 [Server] Ответ: code=${response.statusCode}, body=${response.body}");

      if (response.statusCode != 200) {
        debugPrint("❌ [Server] Сервер отклонил Apple токен");
        return null;
      }

      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCred.identityToken,
        accessToken: appleCred.authorizationCode,
      );

      final userCred = await _auth.signInWithCredential(credential);
      debugPrint("✅ [Firebase] Успешный вход через Apple: ${userCred.user?.email} (uid=${userCred.user?.uid})");

      // Логируем полный Firebase idToken (REMOVE IN PROD)
      await _logFirebaseTokenFull(userCred.user, prefix: '[Firebase/Apple]');

      return userCred;
    } catch (e, st) {
      debugPrint("❌ [Apple/Auth] Ошибка: $e");
      debugPrint("🔍 StackTrace:\n$st");
      return null;
    }
  }

  /// TELEGRAM вход (сервер возвращает customToken)
  Future<UserCredential?> signInWithTelegram(BuildContext context) async {
    debugPrint("👉 [Telegram] Начало авторизации...");

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelegramWebView(
          botUsername: "YOUR_BOT_TOKEN",
          redirectUri: AppRedirectUris.google,
        ),
      ),
    );

    if (result == null) {
      debugPrint("❌ [Telegram] Пользователь отменил вход");
      return null;
    }

    try {
      final customToken = result["custom_token"] as String?;
      if (customToken == null) {
        debugPrint("❌ [Telegram] custom_token не найден в ответе");
        return null;
      }

      debugPrint("✅ [Telegram] Получен customToken: ${customToken.substring(0, 20)}...");
      final userCred = await _auth.signInWithCustomToken(customToken);
      debugPrint("✅ [Firebase] Успешный вход через Telegram: ${userCred.user?.uid}");

      // Логируем полный Firebase idToken (REMOVE IN PROD)
      await _logFirebaseTokenFull(userCred.user, prefix: '[Firebase/Telegram]');

      return userCred;
    } catch (e, st) {
      debugPrint("❌ [Telegram/Auth] Ошибка: $e");
      debugPrint("🔍 StackTrace:\n$st");
      return null;
    }
  }

  /// WHATSAPP вход (сервер → customToken)
  Future<UserCredential?> signInWithWhatsApp(BuildContext context) async {
    debugPrint("👉 [WhatsApp] Начало авторизации...");

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignInWithWhatsApp(
          twilioNumber: "+14155238886",
          redirectUri: "https://schoolmaster.kz",
        ),
      ),
    );

    if (result == null) {
      debugPrint("❌ [WhatsApp] Пользователь отменил вход");
      return null;
    }

    try {
      final customToken = result["custom_token"] as String?;
      if (customToken == null) {
        debugPrint("❌ [WhatsApp] custom_token не найден в ответе");
        return null;
      }

      debugPrint("✅ [WhatsApp] Получен customToken: ${customToken.substring(0, 20)}...");
      final userCred = await _auth.signInWithCustomToken(customToken);
      debugPrint("✅ [Firebase] Успешный вход через WhatsApp: ${userCred.user?.uid}");

      // Логируем полный Firebase idToken (REMOVE IN PROD)
      await _logFirebaseTokenFull(userCred.user, prefix: '[Firebase/WhatsApp]');

      return userCred;
    } catch (e, st) {
      debugPrint("❌ [WhatsApp/Auth] Ошибка: $e");
      debugPrint("🔍 StackTrace:\n$st");
      return null;
    }
  }

  /// VK вход (сервер → customToken)
  Future<UserCredential?> signInWithVK() async {
    debugPrint("👉 [VK] Начало авторизации...");

    try {
      final response = await http.get(Uri.parse("https://telecom.schoolmaster.kz/api/auth/vk"));

      debugPrint("📩 [Server] VK ответ: code=${response.statusCode}, body=${response.body}");

      if (response.statusCode != 200) {
        debugPrint("❌ [VK] Сервер отклонил токен");
        return null;
      }

      final data = jsonDecode(response.body);
      final customToken = data["custom_token"] as String?;
      if (customToken == null) {
        debugPrint("❌ [VK] custom_token отсутствует в теле ответа");
        return null;
      }

      debugPrint("✅ [VK] Получен customToken: ${customToken.substring(0, 20)}...");

      final userCred = await _auth.signInWithCustomToken(customToken);
      debugPrint("✅ [Firebase] Успешный вход через VK: ${userCred.user?.uid}");

      // Логируем полный Firebase idToken (REMOVE IN PROD)
      await _logFirebaseTokenFull(userCred.user, prefix: '[Firebase/VK]');

      return userCred;
    } catch (e, st) {
      debugPrint("❌ [VK/Auth] Ошибка: $e");
      debugPrint("🔍 StackTrace:\n$st");
      return null;
    }
  }

  // Кнопка: получить текущий idToken для уже вошедшего пользователя
  Future<void> _printCurrentUserToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      print("No current user");
      return;
    }
    final token = await user.getIdToken();
    print("CURRENT USER FULL idToken: $token"); // REMOVE IN PROD
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign In")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final user = await signInWithGoogleServer();
                debugPrint("👤 Google user: ${user?.user?.email}");
              },
              child: const Text("Sign in with Google"),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = await signInWithAppleServer();
                debugPrint("👤 Apple user: ${user?.user?.email}");
              },
              child: const Text("Sign in with Apple"),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = await signInWithTelegram(context);
                debugPrint("👤 Telegram user: ${user?.user?.uid}");
              },
              child: const Text("Sign in with Telegram"),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = await signInWithWhatsApp(context);
                debugPrint("👤 WhatsApp user: ${user?.user?.uid}");
              },
              child: const Text("Sign in with WhatsApp"),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = await signInWithVK();
                debugPrint("👤 VK user: ${user?.user?.uid}");
              },
              child: const Text("Sign in with VK"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _printCurrentUserToken,
              child: const Text("Print current Firebase idToken (FULL)"),
            ),
          ],
        ),
      ),
    );
  }
}
