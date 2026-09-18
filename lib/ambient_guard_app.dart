import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'state/app_state.dart';

class AmbientGuardApp extends StatelessWidget {
  const AmbientGuardApp({
    required this.state,
    super.key,
  });

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AmbientGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeListResolutionCallback: (
        deviceLocales,
        supportedLocales,
      ) {
        if (deviceLocales != null) {
          for (final deviceLocale in deviceLocales) {
            for (final supportedLocale in supportedLocales) {
              if (deviceLocale.languageCode ==
                  supportedLocale.languageCode) {
                return supportedLocale;
              }
            }
          }
        }

        return const Locale('en');
      },
      home: HomeScreen(state: state),
    );
  }
}
