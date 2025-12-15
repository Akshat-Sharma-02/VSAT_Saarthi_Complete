import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/dashboard_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const VsatSaarthiApp(),
    ),
  );
}

class VsatSaarthiApp extends StatelessWidget {
  const VsatSaarthiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return MaterialApp(
          title: 'VSAT Saarthi',
          debugShowCheckedModeBanner: false,

          theme: theme.isDark
              ? AppTheme.darkTheme
              : AppTheme.lightTheme,

          initialRoute: SplashScreen.routeName,

          routes: {
            SplashScreen.routeName: (_) => const SplashScreen(),
            DashboardScreen.routeName: (_) => const DashboardScreen(),
          },
        );
      },
    );
  }
}
