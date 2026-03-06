import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/core.dart';
import 'features/landing/landing_page.dart';
import 'features/auth/login_page.dart';
import 'features/scheduling/teacher_scheduling_page.dart';
import 'features/scheduling/admin_scheduling_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppProviders());
}

/// Wrapper con todos los providers de la aplicación
class AppProviders extends StatelessWidget {
  const AppProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    );
  }
}

/// Aplicación principal
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    
    return MaterialApp(
      title: 'ITE VR - Sistema de Agendamiento',
      debugShowCheckedModeBanner: false,
      
      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // Localization
      locale: localeProvider.locale,
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Routes
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/teacher-scheduling': (context) => const TeacherSchedulingPage(),
        '/admin-scheduling': (context) => const AdminSchedulingPage(),
      },
    );
  }
}
