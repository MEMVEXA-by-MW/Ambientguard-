import 'package:flutter/material.dart';

import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.state, super.key});
  final AppState state;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Einstellungen')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Card(child: Column(children: [
            const ListTile(leading: Icon(Icons.offline_bolt_outlined), title: Text('Lokale Verarbeitung'), subtitle: Text('Scan-Ergebnisse bleiben auf diesem Gerät.')),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.delete_outline), title: const Text('Lokales Protokoll löschen'), subtitle: Text('${state.scans.length} gespeicherte Prüfungen'), onTap: () => _confirmClear(context)),
          ])),
          const SizedBox(height: 12),
          const Card(child: Column(children: [
            ListTile(leading: Icon(Icons.privacy_tip_outlined), title: Text('Datenschutz'), subtitle: Text('Kein Konto, keine Werbung, kein Verkauf von Standort- oder Verhaltensdaten.')),
            Divider(height: 1),
            ListTile(leading: Icon(Icons.info_outline), title: Text('AmbientGuard'), subtitle: Text('MVP 0.1.0 · Hinweise statt Sicherheitsversprechen')),
          ])),
        ]),
      );

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Protokoll löschen?'), content: const Text('Alle lokal gespeicherten Raumprüfungen werden dauerhaft entfernt.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Löschen'))]));
    if (confirmed == true) await state.clearScans();
  }
}
