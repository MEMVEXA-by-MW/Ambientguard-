import 'package:ambientguard/models/finding.dart';
import 'package:ambientguard/models/room_scan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('high risk finding determines overall risk', () {
    final scan = RoomScan(
      id: '1',
      label: 'Test',
      createdAt: DateTime(2026),
      findings: const [
        Finding(id: 'f', name: 'Camera', type: FindingType.camera, risk: RiskLevel.high, confidence: .9, reason: 'visible', source: 'visual'),
      ],
    );
    expect(scan.overallRisk, RiskLevel.high);
    expect(scan.score, 68);
  });

  test('room scan survives json roundtrip', () {
    final original = RoomScan(id: '1', label: 'Hotel', createdAt: DateTime.utc(2026, 9, 16), findings: const [], noticeUrl: 'https://example.test/privacy');
    final restored = RoomScan.fromJson(original.toJson());
    expect(restored.label, 'Hotel');
    expect(restored.noticeUrl, original.noticeUrl);
  });
}

