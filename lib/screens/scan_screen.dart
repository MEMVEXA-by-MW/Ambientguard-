import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../models/finding.dart';
import '../models/room_scan.dart';
import '../services/ble_scanner_service.dart';
import '../state/app_state.dart';
import 'scan_detail_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({required this.state, super.key});
  final AppState state;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final labelController = TextEditingController(text: 'Neuer Raum');
  final findings = <Finding>[];
  bool scanning = false;
  String? noticeUrl;

  @override
  void dispose() {
    labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Raumprüfung')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            TextField(controller: labelController, decoration: const InputDecoration(labelText: 'Bezeichnung', hintText: 'z. B. Hotelzimmer 214', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            _ActionCard(
              icon: Icons.visibility_outlined,
              title: '1. Sichtprüfung',
              text: 'Dokumentiere sichtbare Kameras, Smart Speaker oder Displays. Die Bilder werden nicht gespeichert.',
              button: 'Gerät hinzufügen',
              onTap: _addVisualFinding,
            ),
            _ActionCard(
              icon: Icons.bluetooth_searching,
              title: '2. Bluetooth-Umgebung',
              text: scanning ? 'Suche läuft …' : 'Erfasst ausgestrahlte Gerätenamen und schätzt den möglichen Typ.',
              button: scanning ? 'Suche läuft' : 'BLE scannen',
              onTap: scanning ? null : _scanBle,
            ),
            _ActionCard(
              icon: Icons.qr_code_scanner,
              title: '3. Datenschutz-Hinweis',
              text: noticeUrl == null ? 'Scanne einen QR-Code des Betreibers.' : 'Hinweis erfasst: $noticeUrl',
              button: 'QR-Code scannen',
              onTap: _scanQr,
            ),
            const SizedBox(height: 12),
            Text('Gefundene Hinweise (${findings.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (findings.isEmpty)
              const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('Noch keine Hinweise. Ein fehlender Fund ist kein Beweis für einen sensorfreien Raum.')))
            else
              ...findings.map((finding) => Card(child: ListTile(
                    leading: Icon(_icon(finding.type)),
                    title: Text(finding.name),
                    subtitle: Text('${(finding.confidence * 100).round()} % Konfidenz · ${finding.source}'),
                    trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => findings.remove(finding))),
                  ))),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: _finish, icon: const Icon(Icons.fact_check_outlined), label: const Text('Bewertung erstellen')),
          ],
        ),
      );

  Future<void> _scanBle() async {
    final statuses = await [Permission.bluetoothScan, Permission.bluetoothConnect, Permission.locationWhenInUse].request();
    final allowed = statuses.values.any((status) => status.isGranted || status.isLimited);
    if (!allowed) {
      _message('Bluetooth-Berechtigung wurde nicht erteilt.');
      return;
    }
    setState(() => scanning = true);
    try {
      final results = await BleScannerService().scan();
      if (!mounted) return;
      setState(() {
        final ids = findings.map((item) => item.id).toSet();
        findings.addAll(results.where((item) => !ids.contains(item.id)));
      });
      _message('${results.length} Bluetooth-Hinweise erfasst.');
    } catch (_) {
      _message('Bluetooth-Suche konnte nicht abgeschlossen werden.');
    } finally {
      if (mounted) setState(() => scanning = false);
    }
  }

  Future<void> _addVisualFinding() async {
    final result = await showModalBottomSheet<Finding>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ManualFindingSheet(),
    );
    if (result != null) setState(() => findings.add(result));
  }

  Future<void> _scanQr() async {
    final value = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const _QrScanner()));
    if (value != null) setState(() => noticeUrl = value);
  }

  Future<void> _finish() async {
    final scan = RoomScan(
      id: const Uuid().v4(),
      label: labelController.text.trim().isEmpty ? 'Unbenannter Raum' : labelController.text.trim(),
      createdAt: DateTime.now(),
      findings: List.unmodifiable(findings),
      noticeUrl: noticeUrl,
    );
    await widget.state.addScan(scan);
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => ScanDetailScreen(scan: scan)));
  }

  void _message(String value) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.title, required this.text, required this.button, required this.onTap});
  final IconData icon;
  final String title;
  final String text;
  final String button;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 10), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)))]),
            const SizedBox(height: 10),
            Text(text),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onTap, child: Text(button)),
          ]),
        ),
      );
}

class _ManualFindingSheet extends StatefulWidget {
  const _ManualFindingSheet();
  @override
  State<_ManualFindingSheet> createState() => _ManualFindingSheetState();
}

class _ManualFindingSheetState extends State<_ManualFindingSheet> {
  final name = TextEditingController();
  FindingType type = FindingType.camera;
  @override
  void dispose() { name.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sichtbaren Hinweis erfassen', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'Bezeichnung', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<FindingType>(initialValue: type, decoration: const InputDecoration(labelText: 'Gerätetyp', border: OutlineInputBorder()), items: FindingType.values.where((e) => e != FindingType.notice).map((e) => DropdownMenuItem(value: e, child: Text(_typeName(e)))).toList(), onChanged: (value) => setState(() => type = value ?? type)),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => Navigator.of(context).pop(Finding(id: const Uuid().v4(), name: name.text.trim().isEmpty ? _typeName(type) : name.text.trim(), type: type, risk: [FindingType.camera, FindingType.microphone, FindingType.speaker].contains(type) ? RiskLevel.high : RiskLevel.medium, confidence: .90, reason: 'Das Gerät wurde bei der Sichtprüfung manuell erfasst.', source: 'Sichtprüfung')), child: const Text('Hinzufügen')),
        ]),
      );
}

class _QrScanner extends StatefulWidget {
  const _QrScanner();
  @override
  State<_QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<_QrScanner> {
  bool handled = false;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Datenschutz-QR scannen')),
        body: MobileScanner(onDetect: (capture) {
          if (handled || capture.barcodes.isEmpty) return;
          final value = capture.barcodes.first.rawValue;
          if (value == null) return;
          handled = true;
          Navigator.of(context).pop(value);
        }),
      );
}

IconData _icon(FindingType type) => switch (type) {
      FindingType.camera => Icons.videocam_outlined,
      FindingType.microphone => Icons.mic_none,
      FindingType.speaker => Icons.speaker_outlined,
      FindingType.display => Icons.tv,
      FindingType.networkDevice => Icons.router_outlined,
      FindingType.notice => Icons.policy_outlined,
      FindingType.unknown => Icons.device_unknown,
    };

String _typeName(FindingType type) => switch (type) {
      FindingType.camera => 'Kamera',
      FindingType.microphone => 'Mikrofon',
      FindingType.speaker => 'Smart Speaker',
      FindingType.display => 'Display / TV',
      FindingType.networkDevice => 'Netzwerkgerät',
      FindingType.notice => 'Datenschutz-Hinweis',
      FindingType.unknown => 'Unbekanntes Gerät',
    };

