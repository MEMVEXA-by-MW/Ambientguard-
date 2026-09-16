import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../models/finding.dart';

class BleScannerService {
  Future<List<Finding>> scan({Duration timeout = const Duration(seconds: 8)}) async {
    final ble = FlutterReactiveBle();
    final byId = <String, Finding>{};
    final subscription = ble.scanForDevices(
      withServices: const [],
      scanMode: ScanMode.balanced,
    ).listen((device) {
      final advertised = device.name.trim();
      final name = advertised.isEmpty ? 'Unbenanntes Bluetooth-Gerät' : advertised;
      final normalized = name.toLowerCase();
      final sensitive = _looksSensitive(normalized);
      byId[device.id] = Finding(
        id: 'ble-${device.id}',
        name: name,
        type: _typeFor(normalized),
        risk: sensitive ? RiskLevel.medium : RiskLevel.low,
        confidence: sensitive ? 0.72 : 0.46,
        reason: sensitive
            ? 'Der Gerätename deutet auf einen sensorfähigen Gerätetyp hin.'
            : 'Ein Bluetooth-Signal ist sichtbar; der genaue Gerätetyp bleibt unklar.',
        source: 'Bluetooth Low Energy',
      );
    });

    try {
      await Future<void>.delayed(timeout);
    } finally {
      await subscription.cancel();
    }
    return byId.values.toList();
  }

  bool _looksSensitive(String value) =>
      ['camera', 'cam', 'alexa', 'echo', 'nest', 'speaker', 'display', 'tv']
          .any(value.contains);

  FindingType _typeFor(String value) {
    if (['camera', 'cam'].any(value.contains)) return FindingType.camera;
    if (['alexa', 'echo', 'speaker'].any(value.contains)) return FindingType.speaker;
    if (['display', 'tv', 'nest'].any(value.contains)) return FindingType.display;
    return FindingType.networkDevice;
  }
}
