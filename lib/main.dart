import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_push_notification_2024_1/config/router/app_router.dart/app_router.dart';
import 'package:flutter_push_notification_2024_1/config/theme/app_theme.dart';
import 'package:flutter_push_notification_2024_1/presentarion/providers/head_provider.dart';
import 'package:flutter_push_notification_2024_1/presentarion/providers/notifications/notifications_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationsBloc.initializeFCM();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(HeadProvider.initProvider(mainAppWidget: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
    );
  }
}
