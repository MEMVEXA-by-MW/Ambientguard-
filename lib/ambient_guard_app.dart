import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'state/app_state.dart';

class AmbientGuardApp extends StatelessWidget {
  const AmbientGuardApp({required this.state, super.key});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AmbientGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: HomeScreen(state: state),
    );
  }
}

