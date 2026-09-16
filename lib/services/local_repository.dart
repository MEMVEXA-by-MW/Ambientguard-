import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/room_scan.dart';

class LocalRepository {
  static const _scansKey = 'room_scans_v1';
  static const _onboardingKey = 'onboarding_complete_v1';

  Future<List<RoomScan>> loadScans() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scansKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((item) => RoomScan.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];
    }
  }

  Future<void> saveScans(List<RoomScan> scans) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _scansKey,
      jsonEncode(scans.map((scan) => scan.toJson()).toList()),
    );
  }

  Future<bool> onboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scansKey);
  }
}

