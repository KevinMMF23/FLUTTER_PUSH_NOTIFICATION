import 'package:flutter/material.dart';
import 'config/router/app_router.dart/app_router.dart';
import 'config/theme/app_theme.dart';
import 'presentarion/providers/head_provider.dart';
import 'presentarion/providers/notifications/notifications_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationsBloc.initializeFCM();
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
