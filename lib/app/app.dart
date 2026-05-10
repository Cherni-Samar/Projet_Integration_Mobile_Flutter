import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_team/app/app_routes.dart';
import 'package:e_team/app/app_theme.dart';
import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/providers/locale_provider.dart';
import 'package:e_team/presentation/providers/theme_provider.dart';

class ETeamApp extends StatelessWidget {
  const ETeamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          title: 'E-Team - Department as a Service',
          debugShowCheckedModeBanner: false,
          locale: localeProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          routes: AppRoutes.routes,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}
