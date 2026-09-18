import 'package:flutter/material.dart';

import '../models/finding.dart';
import '../models/room_scan.dart';
import '../state/app_state.dart';
import 'onboarding_screen.dart';
import 'scan_screen.dart';
import 'scan_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.state, super.key});

  final AppState state;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showOnboarding());
  }

  @override
  void dispose() {
    widget.state.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> _showOnboarding() async {
    if (widget.state.onboardingComplete || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => OnboardingScreen(state: widget.state),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _Dashboard(state: widget.state, onScan: _startScan),
      _History(state: widget.state),
      SettingsScreen(state: widget.state),
    ];
    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.shield_outlined), selectedIcon: Icon(Icons.shield), label: 'Übersicht'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Verlauf'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Einstellungen'),
        ],
      ),
      floatingActionButton: index == 0
          ? FloatingActionButton.extended(
              onPressed: _startScan,
              icon: const Icon(Icons.radar),
              label: const Text('Raum prüfen'),
            )
          : null,
    );
  }

  Future<void> _startScan() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ScanScreen(state: widget.state)),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.state, required this.onScan});

  final AppState state;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final last = state.scans.isEmpty ? null : state.scans.first;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 104),
      children: [
        Text('AmbientGuard', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Privatsphäre im Raum besser einschätzen', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 24),
        _StatusCard(scan: last, onScan: onScan),
        const SizedBox(height: 24),
        Text('So funktioniert es', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        const _Step(icon: Icons.camera_alt_outlined, title: 'Sichtprüfung', text: 'Kameraansicht nutzen und auffällige Geräte dokumentieren.'),
        const _Step(
  icon: Icons.wifi_tethering,
  title: 'Funksignale',
  text: 'Bluetooth-Geräte in der Umgebung und erreichbare Geräte im verbundenen WLAN erfassen.',
),
        const _Step(icon: Icons.qr_code_scanner, title: 'Datenschutz-Hinweis', text: 'QR-Code des Raums einlesen und mit Beobachtungen abgleichen.'),
        const SizedBox(height: 16),
        Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline),
              SizedBox(width: 12),
              Expanded(child: Text('AmbientGuard erkennt Hinweise, aber kann nicht garantieren, dass ein Raum frei von Kameras oder Mikrofonen ist.')),
            ]),
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.scan, required this.onScan});
  final RoomScan? scan;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final color = scan == null ? Theme.of(context).colorScheme.primary : _riskColor(scan!.overallRisk);
    return Card(
      color: color.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(scan == null ? Icons.shield_outlined : Icons.shield, size: 42, color: color),
          const SizedBox(height: 18),
          Text(scan == null ? 'Noch kein Raum geprüft' : 'Letzte Bewertung: ${scan!.score}/100', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(scan == null ? 'Starte eine lokale Prüfung. Aufnahmen werden nicht hochgeladen.' : '${scan!.label} · ${scan!.findings.length} Hinweise'),
          const SizedBox(height: 18),
          FilledButton.icon(onPressed: onScan, icon: const Icon(Icons.radar), label: const Text('Neue Raumprüfung')),
        ]),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;
  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          leading: CircleAvatar(child: Icon(icon)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(text),
        ),
      );
}

class _History extends StatelessWidget {
  const _History({required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Lokales Protokoll')),
        body: state.scans.isEmpty
            ? const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Noch keine gespeicherten Raumprüfungen.')))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.scans.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final scan = state.scans[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: _riskColor(scan.overallRisk).withValues(alpha: .15), child: Text('${scan.score}')),
                      title: Text(scan.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${_date(scan.createdAt)} · ${scan.findings.length} Hinweise'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ScanDetailScreen(scan: scan))),
                    ),
                  );
                },
              ),
      );
}

Color _riskColor(RiskLevel risk) => switch (risk) {
      RiskLevel.low => const Color(0xFF16855B),
      RiskLevel.medium => const Color(0xFFE28A08),
      RiskLevel.high => const Color(0xFFD43D3D),
    };

String _date(DateTime value) => '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';
