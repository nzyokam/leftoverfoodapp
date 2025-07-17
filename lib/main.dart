import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_config.dart';
import 'config/theme.dart';
import 'config/router.dart';
//import 'providers/app_providers.dart';
import 'services/notification_service.dart';
import 'services/location_service.dart';
import 'utils/app_localizations.dart';
import '../services/auth_service.dart';
import '../providers/food_provider.dart';
import '../providers/location_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  final prefs = await SharedPreferences.getInstance();
  await NotificationService.initialize();
  await LocationService.initialize();

  

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: LeftoverFoodShareApp(prefs: prefs),
    ),
  );
}

class LeftoverFoodShareApp extends StatelessWidget {
  final SharedPreferences prefs;

  const LeftoverFoodShareApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp.router(
      title: 'Leftover Food Share',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: AppRouter.router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('sw', ''),
        Locale('es', ''),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
