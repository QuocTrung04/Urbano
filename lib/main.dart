import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:urbano/ViewModels/auth/user_provider.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/routes/app_routes.dart';
import 'package:urbano/features/invoice/ViewModels/hoa_don_viewmodel.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:urbano/core/network/signalr_service.dart';
import 'package:urbano/core/services/local_notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.initialize();

  LocalNotificationService.onNotificationTap.stream.listen((payload) {
    if (payload != null && navigatorKey.currentState != null) {
      if (payload == 'notification') {
        navigatorKey.currentState!.pushNamed(AppRoutes.notification);
      } else if (payload == 'system_alert') {
        navigatorKey.currentState!.pushNamed(AppRoutes.bangTin);
      } else if (payload == 'request_status') {
        navigatorKey.currentState!.pushNamed(AppRoutes.yeucau);
      } else if (payload == 'booking_status') {
        navigatorKey.currentState!.pushNamed(AppRoutes.tienich);
      }
    }
  });

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Android
      statusBarBrightness: Brightness.dark, // iOS
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HoaDonViewModel()),
        ChangeNotifierProvider(create: (_) => UserProvider()..loadFromPrefs()),
        ChangeNotifierProvider(create: (_) => SignalRService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Urbano',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bgDark,
        canvasColor: AppColors.bgDark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.tealPrimary,
          brightness: Brightness.dark,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
      locale: const Locale('vi', 'VN'),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoutes,
    );
  }
}
