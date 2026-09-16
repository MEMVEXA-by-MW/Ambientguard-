import 'package:flutter/foundation.dart';

import '../models/room_scan.dart';
import '../services/local_repository.dart';

class AppState extends ChangeNotifier {
  AppState(this.repository);

  final LocalRepository repository;
  List<RoomScan> scans = [];
  bool onboardingComplete = false;

  Future<void> initialize() async {
    scans = await repository.loadScans();
    onboardingComplete = await repository.onboardingComplete();
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
    scans = scans.where((scan) => scan.id != id).toList();
    await repository.saveScans(scans);
    notifyListeners();
  }

  Future<void> clearScans() async {
    scans = [];
    await repository.clear();
    notifyListeners();
  }
}
