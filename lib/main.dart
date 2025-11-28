import 'dart:io'; // Для Platform.isIOS
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features.routing/presentation/blocs/favorites/favorite_bloc.dart';
import 'features.routing/presentation/screens/login & reg/authbloc/auth_bloc.dart';
import 'core/theme/theme_cubit.dart';
import 'app.dart';

/// Глобальный ключ навигатора (используется в FirebaseCallHandler)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// ✅ Глобальный фоновый обработчик FCM (для background и terminated состояний)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 1️⃣ Запрос разрешений
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // 2️⃣ Ждем APNs токен только на iOS
  String? apnsToken;
  if (Platform.isIOS) {
    while (apnsToken == null) {
      apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken == null) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
    debugPrint('🍏 APNs Token ready: $apnsToken');
  }

  // 3️⃣ Получаем FCM токен
  final fcmToken = await FirebaseMessaging.instance.getToken();
  debugPrint('📱 FCM Token: $fcmToken');
  print("App options: ${Firebase.app().options.projectId}");


  // 4️⃣ Background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 5️⃣ Инициализация обработчика звонков

  // 6️⃣ Запуск приложения
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => FavoriteBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey, // ✅ используется для навигации при входящем звонке
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('ru', 'RU'),
        ],
        home: const App(),
      ),
    );
  }
}