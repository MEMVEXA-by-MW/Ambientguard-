import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../l10n/scan_translations.dart';
import '../models/finding.dart';
import '../models/room_scan.dart';
import '../services/ble_scanner_service.dart';
import '../services/network_scanner_service.dart';
import '../state/app_state.dart';
import 'scan_detail_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({
    required this.state,
    super.key,
  });

  final AppState state;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final labelController = TextEditingController();

  final findings = <Finding>[];

  bool scanning = false;
  bool networkScanning = false;
  String? noticeUrl;
  ScanTranslations get _tr => ScanTranslations(
      Localizations.localeOf(context).languageCode,
    );

  @override
  void dispose() {
    labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  final tr = ScanTranslations(
    Localizations.localeOf(context).languageCode,
  );

  return Scaffold(
      appBar: AppBar(
        title: Text(tr.text('roomCheck')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          TextField(
            controller: labelController,
            decoration: InputDecoration(
  labelText: tr.text('name'),
  hintText: tr.text('roomHint'),
  border: const OutlineInputBorder(),
),
            ),
          
          const SizedBox(height: 16),
          _ActionCard(
  icon: Icons.visibility_outlined,
  title: '1. ${tr.text('visualInspection')}',
  text: tr.text('visualDescription'),
  button: tr.text('addDevice'),
  onTap: _addVisualFinding,
),
_ActionCard(
  icon: Icons.bluetooth_searching,
  title: '2. ${tr.text('bluetoothEnvironment')}',
  text: scanning
      ? tr.text('bluetoothScanning')
      : tr.text('bluetoothDescription'),
  button: scanning
      ? tr.text('bluetoothScanning')
      : tr.text('scanBluetooth'),
  onTap: scanning ? null : _scanBle,
),
_ActionCard(
  icon: Icons.wifi_find,
  title: '3. ${tr.text('networkDevices')}',
  text: networkScanning
      ? tr.text('networkScanning')
      : tr.text('networkDescription'),
  button: networkScanning
      ? tr.text('networkScanning')
      : tr.text('scanNetwork'),
  onTap: networkScanning ? null : _scanNetwork,
),
_ActionCard(
  icon: Icons.qr_code_scanner,
  title: '4. ${tr.text('privacyNotice')}',
  text: noticeUrl == null
      ? tr.text('privacyDescription')
      : tr.text('qrCaptured'),
  button: tr.text('scanQrCode'),
  onTap: _scanQr,
),
const SizedBox(height: 12),
Text(
  tr.text('foundFindings', count: findings.length),
  style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
),
const SizedBox(height: 8),
if (findings.isEmpty)
  Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Text(tr.text('noFindings')),
    ),
  )
else
  ...findings.map(
    (finding) => Card(
      child: ListTile(
        leading: Icon(_icon(finding.type)),
        title: Text(finding.name),
        subtitle: Text(
          '${(finding.confidence * 100).round()}% '
          '${tr.text('confidence')}\n'
          '${finding.source}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              findings.remove(finding);
            });
          },
        ),
      ),
    ),
  ),
const SizedBox(height: 16),
FilledButton.icon(
  onPressed: _finish,
  icon: const Icon(Icons.fact_check_outlined),
  label: Text(tr.text('createAssessment')),
),
        ],
      ),
    );
  }

  Future<void> _scanBle() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    final allowed = statuses.values.any(
      (status) => status.isGranted || status.isLimited,
    );

    if (!allowed) {
      _message(_tr.text('permissionDenied'));
      return;
    }

    setState(() {
      scanning = true;
    });

    try {
      final results = await BleScannerService().scan();

      if (!mounted) return;

      setState(() {
        final ids = findings.map((item) => item.id).toSet();

        findings.addAll(
          results.where((item) => !ids.contains(item.id)),
        );
      });

      _message(_tr.text('bluetoothFound', count: results.length));
    } catch (_) {
      _message(_tr.text('bluetoothFailed'));
    } finally {
      if (mounted) {
        setState(() {
          scanning = false;
        });
      }
    }
  }

  Future<void> _scanNetwork() async {
    setState(() {
      networkScanning = true;
    });

    try {
      final results = await NetworkScannerService().scan();

      if (!mounted) return;

      setState(() {
        final ids = findings.map((item) => item.id).toSet();

        findings.addAll(
          results.where((item) => !ids.contains(item.id)),
        );
      });

      if (results.isEmpty) {
        _message(_tr.text('networkNone'));
      } else {
        _message(_tr.text('networkFound', count: results.length));
      }
    } on NetworkScanException {
  _message(_tr.text('networkUnavailable'));
    } catch (_) {
      _message(_tr.text('networkFailed'));
    } finally {
      if (mounted) {
        setState(() {
          networkScanning = false;
        });
      }
    }
  }

  Future<void> _addVisualFinding() async {
    final result = await showModalBottomSheet<Finding>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ManualFindingSheet(),
    );

    if (result != null) {
      setState(() {
        findings.add(result);
      });
    }
  }

  Future<void> _scanQr() async {
    final value = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const _QrScanner(),
      ),
    );

    if (value != null) {
      setState(() {
        noticeUrl = value;
      });
    }
  }

  Future<void> _finish() async {
    final scan = RoomScan(
      id: const Uuid().v4(),
      label: labelController.text.trim().isEmpty
          ? _tr.text('unnamedRoom')
          : labelController.text.trim(),
      createdAt: DateTime.now(),
      findings: List.unmodifiable(findings),
      noticeUrl: noticeUrl,
    );

    await widget.state.addScan(scan);

    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ScanDetailScreen(scan: scan),
      ),
    );
  }

  void _message(String value) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.button,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String text;
  final String button;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(text),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onTap,
              child: Text(button),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualFindingSheet extends StatefulWidget {
  const _ManualFindingSheet();

  @override
  State<_ManualFindingSheet> createState() {
    return _ManualFindingSheetState();
  }
}

class _ManualFindingSheetState
    extends State<_ManualFindingSheet> {
  final name = TextEditingController();
  FindingType type = FindingType.camera;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sichtbaren Hinweis erfassen',
            style:
                Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: name,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Bezeichnung',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<FindingType>(
            initialValue: type,
            decoration: const InputDecoration(
              labelText: 'Gerätetyp',
              border: OutlineInputBorder(),
            ),
            items: FindingType.values
                .where(
                  (item) => item != FindingType.notice,
                )
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(_typeName(item)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                type = value ?? type;
              });
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              final risk = [
                FindingType.camera,
                FindingType.microphone,
                FindingType.speaker,
              ].contains(type)
                  ? RiskLevel.high
                  : RiskLevel.medium;

              Navigator.of(context).pop(
                Finding(
                  id: const Uuid().v4(),
                  name: name.text.trim().isEmpty
                      ? _typeName(type)
                      : name.text.trim(),
                  type: type,
                  risk: risk,
                  confidence: 0.90,
                  reason:
                      'Das Gerät wurde bei der Sichtprüfung '
                      'manuell erfasst.',
                  source: 'Sichtprüfung',
                ),
              );
            },
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }
}

class _QrScanner extends StatefulWidget {
  const _QrScanner();

  @override
  State<_QrScanner> createState() {
    return _QrScannerState();
  }
}

class _QrScannerState extends State<_QrScanner> {
  bool handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datenschutz-QR scannen'),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (handled || capture.barcodes.isEmpty) return;

          final value = capture.barcodes.first.rawValue;

          if (value == null) return;

          handled = true;
          Navigator.of(context).pop(value);
        },
      ),
    );
  }
}

IconData _icon(FindingType type) {
  return switch (type) {
    FindingType.camera => Icons.videocam_outlined,
    FindingType.microphone => Icons.mic_none,
    FindingType.speaker => Icons.speaker_outlined,
    FindingType.display => Icons.tv,
    FindingType.networkDevice => Icons.router_outlined,
    FindingType.notice => Icons.policy_outlined,
    FindingType.unknown => Icons.device_unknown,
  };
}

String _typeName(FindingType type) {
  return switch (type) {
    FindingType.camera => 'Kamera',
    FindingType.microphone => 'Mikrofon',
    FindingType.speaker => 'Smart Speaker',
    FindingType.display => 'Display / TV',
    FindingType.networkDevice => 'Netzwerkgerät',
    FindingType.notice => 'Datenschutz-Hinweis',
    FindingType.unknown => 'Unbekanntes Gerät',
  };
}
