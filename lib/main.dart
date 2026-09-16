import 'package:flutter/material.dart';

import 'ambient_guard_app.dart';
import 'services/local_repository.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = LocalRepository();
  final state = AppState(repository);
  await state.initialize();
  runApp(AmbientGuardApp(state: state));
}

