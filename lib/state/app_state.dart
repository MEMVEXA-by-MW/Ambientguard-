
import 'package:flutter/widgets.dart';

import '../models/room_scan.dart';
import '../services/local_repository.dart';

class AppState extends ChangeNotifier {
  AppState(this.repository);

  final LocalRepository repository;

  static const supportedLanguageCodes = <String>{
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pt',
    'nl',
    'pl',
    'tr',
  };

  List<RoomScan> scans = [];
  bool onboardingComplete = false;
  String? languageCode;

  Locale? get locale {
    final code = languageCode;

    if (code == null) return null;

    return Locale(code);
  }

  Future<void> initialize() async {
    scans = await repository.loadScans();
    onboardingComplete =
        await repository.onboardingComplete();

    final savedLanguage =
        await repository.loadLanguageCode();

    languageCode =
        supportedLanguageCodes.contains(savedLanguage)
            ? savedLanguage
            : null;
  }

  Future<void> setLanguageCode(
    String? newLanguageCode,
  ) async {
    if (newLanguageCode != null &&
        !supportedLanguageCodes.contains(newLanguageCode)) {
      return;
    }

    languageCode = newLanguageCode;

    await repository.saveLanguageCode(
      newLanguageCode,
    );

    notifyListeners();
  }

  Future<void> finishOnboarding() async {
    onboardingComplete = true;

    await repository.setOnboardingComplete();

    notifyListeners();
  }

  Future<void> addScan(RoomScan scan) async {
    scans = [scan, ...scans];

    await repository.saveScans(scans);

    notifyListeners();
  }

  Future<void> deleteScan(String id) async {
    scans = scans
        .where((scan) => scan.id != id)
        .toList();

    await repository.saveScans(scans);

    notifyListeners();
  }

  Future<void> clearScans() async {
    scans = [];

    await repository.clear();

    notifyListeners();
  }
}
