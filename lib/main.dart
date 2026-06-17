import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urbano/Views/home/home_screen.dart';
import 'package:urbano/core/constants/app_colors.dart';
import 'package:urbano/core/routes/app_routes.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Android
      statusBarBrightness: Brightness.dark, // iOS
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Urbano',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bgDark,
        canvasColor: AppColors.bgDark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.tealPrimary,
          brightness: Brightness.dark,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoutes,
    );
  }
}
