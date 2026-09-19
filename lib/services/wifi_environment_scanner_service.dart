import 'package:wifi_scan/wifi_scan.dart';

class WifiEnvironmentNetwork {
  const WifiEnvironmentNetwork({
    required this.ssid,
    required this.bssid,
    required this.signalLevel,
    required this.frequency,
    required this.capabilities,
    required this.isHidden,
    required this.isOpen,
  });

  final String ssid;
  final String bssid;
  final int signalLevel;
  final int frequency;
  final String capabilities;
  final bool isHidden;
  final bool isOpen;

  bool get isVeryClose => signalLevel >= -50;

  String get frequencyBand {
    if (frequency >= 5925) {
      return '6 GHz';
    }
    if (frequency >= 4900) {
      return '5 GHz';
    }
    return '2.4 GHz';
  }
}

class WifiEnvironmentScanException implements Exception {
  const WifiEnvironmentScanException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WifiEnvironmentScannerService {
  Future<List<WifiEnvironmentNetwork>> scan() async {
    final canStart = await WiFiScan.instance.canStartScan(
      askPermissions: true,
    );

    if (canStart == CanStartScan.yes) {
      await WiFiScan.instance.startScan();
      await Future<void>.delayed(const Duration(seconds: 2));
    }

    final canRead = await WiFiScan.instance.canGetScannedResults(
      askPermissions: true,
    );

    if (canRead != CanGetScannedResults.yes) {
      throw const WifiEnvironmentScanException(
        'Wi-Fi scan permission or location service is unavailable.',
      );
    }

    final accessPoints = await WiFiScan.instance.getScannedResults();
    final uniqueNetworks = <String, WifiEnvironmentNetwork>{};

    for (final accessPoint in accessPoints) {
      final capabilities = accessPoint.capabilities.toUpperCase();
      final isOpen = capabilities.isEmpty ||
          (!capabilities.contains('WEP') &&
              !capabilities.contains('WPA') &&
              !capabilities.contains('SAE') &&
              !capabilities.contains('OWE'));

      uniqueNetworks[accessPoint.bssid] = WifiEnvironmentNetwork(
        ssid: accessPoint.ssid.trim(),
        bssid: accessPoint.bssid,
        signalLevel: accessPoint.level,
        frequency: accessPoint.frequency,
        capabilities: accessPoint.capabilities,
        isHidden: accessPoint.ssid.trim().isEmpty,
        isOpen: isOpen,
      );
    }

    final networks = uniqueNetworks.values.toList()
      ..sort(
        (first, second) =>
            second.signalLevel.compareTo(first.signalLevel),
      );

    return networks;
  }
}
