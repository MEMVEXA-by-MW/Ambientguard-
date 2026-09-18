import 'dart:async';
import 'dart:io';

import '../models/finding.dart';

class NetworkScannerService {
  static const _ports = <int>[
    80,
    443,
    554,
    1883,
    7000,
    8000,
    8008,
    8009,
    8080,
    8443,
    9100,
    32400,
  ];

  Future<List<Finding>> scan({
    Duration timeout = const Duration(milliseconds: 280),
  }) async {
    final ownAddress = await _wifiAddress();

    if (ownAddress == null) {
      throw const NetworkScanException(
        'Keine private WLAN-Adresse gefunden. Bitte mit einem WLAN verbinden.',
      );
    }

    final octets = ownAddress.address.split('.');
    final prefix = '${octets[0]}.${octets[1]}.${octets[2]}';
    final ownHost = int.parse(octets[3]);
    final results = <Finding>[];

    for (var start = 1; start < 255; start += 24) {
      final end = (start + 24).clamp(1, 255);
      final batch = <Future<Finding?>>[];

      for (var host = start; host < end; host++) {
        if (host == ownHost) continue;
        batch.add(_probe('$prefix.$host', timeout));
      }

      results.addAll(
        (await Future.wait(batch)).whereType<Finding>(),
      );
    }

    results.sort(
      (a, b) => _lastOctet(a.id).compareTo(_lastOctet(b.id)),
    );

    return results;
  }

  Future<InternetAddress?> _wifiAddress() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );

    final ordered = [...interfaces]
      ..sort((a, b) {
        final aWifi = _looksLikeWifi(a.name) ? 0 : 1;
        final bWifi = _looksLikeWifi(b.name) ? 0 : 1;
        return aWifi.compareTo(bWifi);
      });

    for (final interface in ordered) {
      for (final address in interface.addresses) {
        if (_isPrivate(address.address)) {
          return address;
        }
      }
    }

    return null;
  }

  Future<Finding?> _probe(
    String ip,
    Duration timeout,
  ) async {
    final openPorts = <int>[];

    await Future.wait(
      _ports.map((port) async {
        Socket? socket;

        try {
          socket = await Socket.connect(
            ip,
            port,
            timeout: timeout,
          );
          openPorts.add(port);
        } on SocketException {
          // Geschlossene oder nicht erreichbare Ports werden ignoriert.
        } on TimeoutException {
          // Geräte ohne rechtzeitige Antwort werden ignoriert.
        } finally {
          socket?.destroy();
        }
      }),
    );

    if (openPorts.isEmpty) return null;

    openPorts.sort();
    final profile = classifyPorts(openPorts);

    return Finding(
      id: 'lan-$ip',
      name: '${profile.label} · $ip',
      type: profile.type,
      risk: profile.risk,
      confidence: profile.confidence,
      reason:
          '${profile.reason} Erreichbare Ports: ${openPorts.join(', ')}. '
          'Die Zuordnung ist nur eine technische Schätzung.',
      source: 'Lokales WLAN/LAN',
    );
  }

  static NetworkDeviceProfile classifyPorts(List<int> ports) {
    if (ports.contains(554) || ports.contains(8000)) {
      return const NetworkDeviceProfile(
        label: 'Mögliches Video-/IoT-Gerät',
        type: FindingType.camera,
        risk: RiskLevel.medium,
        confidence: 0.64,
        reason:
            'Ein häufig von Video- oder IoT-Geräten verwendeter Dienst antwortet.',
      );
    }

    if (ports.contains(8008) ||
        ports.contains(8009) ||
        ports.contains(32400) ||
        ports.contains(7000)) {
      return const NetworkDeviceProfile(
        label: 'Medien- oder Smart-Gerät',
        type: FindingType.display,
        risk: RiskLevel.medium,
        confidence: 0.62,
        reason:
            'Ein typischer Medien- oder Smart-Home-Dienst antwortet.',
      );
    }

    if (ports.contains(1883)) {
      return const NetworkDeviceProfile(
        label: 'Mögliches IoT-Gerät',
        type: FindingType.networkDevice,
        risk: RiskLevel.medium,
        confidence: 0.60,
        reason:
            'Ein häufig für IoT-Kommunikation verwendeter Dienst antwortet.',
      );
    }

    if (ports.contains(9100)) {
      return const NetworkDeviceProfile(
        label: 'Möglicher Netzwerkdrucker',
        type: FindingType.networkDevice,
        risk: RiskLevel.low,
        confidence: 0.72,
        reason:
            'Ein häufig von Netzwerkdruckern verwendeter Dienst antwortet.',
      );
    }

    return const NetworkDeviceProfile(
      label: 'Netzwerkgerät',
      type: FindingType.networkDevice,
      risk: RiskLevel.low,
      confidence: 0.48,
      reason:
          'Eine lokale Weboberfläche oder ein verschlüsselter Dienst antwortet.',
    );
  }

  bool _isPrivate(String ip) {
    final parts = ip.split('.').map(int.tryParse).toList();

    if (parts.length != 4 || parts.any((part) => part == null)) {
      return false;
    }

    final first = parts[0]!;
    final second = parts[1]!;

    return first == 10 ||
        (first == 172 && second >= 16 && second <= 31) ||
        (first == 192 && second == 168);
  }

  bool _looksLikeWifi(String name) {
    final normalized = name.toLowerCase();

    return normalized.startsWith('wlan') ||
        normalized.startsWith('wifi') ||
        normalized.startsWith('en0');
  }

  int _lastOctet(String id) {
    return int.tryParse(id.split('.').last) ?? 0;
  }
}

class NetworkDeviceProfile {
  const NetworkDeviceProfile({
    required this.label,
    required this.type,
    required this.risk,
    required this.confidence,
    required this.reason,
  });

  final String label;
  final FindingType type;
  final RiskLevel risk;
  final double confidence;
  final String reason;
}

class NetworkScanException implements Exception {
  const NetworkScanException(this.message);

  final String message;
}
