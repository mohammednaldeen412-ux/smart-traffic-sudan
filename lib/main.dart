import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/services/announcement_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/locale_provider.dart';
import 'core/services/notification_service.dart';
import 'core/services/payment_service.dart';
import 'core/services/theme_provider.dart';
import 'core/services/traffic_service.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'widgets/in_app_notification_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('ar', null);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0E131F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const SmartTrafficSudanApp());
}

class SmartTrafficSudanApp extends StatelessWidget {
  const SmartTrafficSudanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => TrafficService()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => PaymentService()),
        ChangeNotifierProxyProvider<TrafficService, AnnouncementService>(
          create: (context) =>
              AnnouncementService(context.read<TrafficService>()),
          update: (context, traffic, previous) =>
              previous ?? AnnouncementService(traffic),
        ),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          SystemChrome.setSystemUIOverlayStyle(
            themeProvider.isDark
                ? const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.light,
                    systemNavigationBarColor: Color(0xFF0E131F),
                    systemNavigationBarIconBrightness: Brightness.light,
                  )
                : const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark,
                    systemNavigationBarColor: Color(0xFFFFFFFF),
                    systemNavigationBarIconBrightness: Brightness.dark,
                  ),
          );

          return MaterialApp(
            title: 'مرور السودان الذكي - Smart Traffic Sudan',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('ar', 'SD'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return Directionality(
                textDirection: localeProvider.isArabic
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: InAppNotificationListener(
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
