import 'package:flutter/material.dart';

import '../models/finding.dart';
import '../models/room_scan.dart';

class ScanDetailScreen extends StatelessWidget {
  const ScanDetailScreen({required this.scan, super.key});
  final RoomScan scan;

  @override
  Widget build(BuildContext context) {
    final color = switch (scan.overallRisk) { RiskLevel.low => Colors.green, RiskLevel.medium => Colors.orange, RiskLevel.high => Colors.red };
    return Scaffold(
      appBar: AppBar(title: Text(scan.label)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          color: color.withValues(alpha: .12),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              SizedBox(width: 104, height: 104, child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: scan.score / 100, strokeWidth: 10, color: color, backgroundColor: color.withValues(alpha: .15)), Text('${scan.score}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900))])),
              const SizedBox(height: 16),
              Text(_headline(scan.overallRisk), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Dies ist eine Risikoeinschätzung, kein Sicherheitszertifikat.', textAlign: TextAlign.center),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Text('Hinweise', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (scan.findings.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Keine Hinweise gefunden. Verdeckte, ausgeschaltete oder nicht sendende Geräte können unentdeckt bleiben.')))
        else
          ...scan.findings.map((finding) => Card(child: ExpansionTile(
                leading: CircleAvatar(child: Text('${(finding.confidence * 100).round()}%')),
                title: Text(finding.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${finding.source} · ${_risk(finding.risk)}'),
                children: [Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 18), child: Align(alignment: Alignment.centerLeft, child: Text(finding.reason)))],
              ))),
        if (scan.noticeUrl != null) Card(child: ListTile(leading: const Icon(Icons.policy_outlined), title: const Text('Datenschutz-Hinweis erfasst'), subtitle: Text(scan.noticeUrl!))),
        const SizedBox(height: 12),
        Card(color: Theme.of(context).colorScheme.secondaryContainer, child: const Padding(padding: EdgeInsets.all(18), child: Text('Empfehlung: Frage den Betreiber bei unklaren oder nicht angekündigten Geräten. Verdecke oder manipuliere keine fremden Geräte.'))),
      ]),
    );
  }
}

String _headline(RiskLevel risk) => switch (risk) { RiskLevel.low => 'Wenig erkennbare Hinweise', RiskLevel.medium => 'Prüfung empfohlen', RiskLevel.high => 'Erhöhte Aufmerksamkeit' };
String _risk(RiskLevel risk) => switch (risk) { RiskLevel.low => 'niedrig', RiskLevel.medium => 'mittel', RiskLevel.high => 'hoch' };

