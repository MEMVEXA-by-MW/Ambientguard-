import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.state,
    super.key,
  });

  final AppState state;

  static const _automaticValue = 'system';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                10,
                16,
                16,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading:
                        const Icon(Icons.language),
                    title: Text(
                      context.tr('language'),
                    ),
                    subtitle: Text(
                      state.languageCode == null
                          ? context.tr('automatic')
                          : AppLocalizations.languageName(
                              state.languageCode,
                            ),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue:
                        state.languageCode ??
                        _automaticValue,
                    decoration: InputDecoration(
                      labelText: context.tr('language'),
                      border:
                          const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: _automaticValue,
                        child: Text(
                          context.tr('automatic'),
                        ),
                      ),
                      ...AppState.supportedLanguageCodes.map(
                        (code) =>
                            DropdownMenuItem<String>(
                          value: code,
                          child: Text(
                            AppLocalizations
                                .languageName(code),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) async {
                      if (value == null) return;

                      await state.setLanguageCode(
                        value == _automaticValue
                            ? null
                            : value,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(
                    Icons.offline_bolt_outlined,
                  ),
                  title: Text(
                    'Lokale Verarbeitung',
                  ),
                  subtitle: Text(
                    'Scan-Ergebnisse bleiben auf diesem Gerät.',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      const Icon(Icons.delete_outline),
                  title: const Text(
                    'Lokales Protokoll löschen',
                  ),
                  subtitle: Text(
                    '${state.scans.length} gespeicherte Prüfungen',
                  ),
                  onTap: () => _confirmClear(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.privacy_tip_outlined,
                  ),
                  title: Text('Datenschutz'),
                  subtitle: Text(
                    'Kein Konto, keine Werbung, kein Verkauf '
                    'von Standort- oder Verhaltensdaten.',
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('AmbientGuard'),
                  subtitle: Text(
                    'Version 0.2.0 · Hinweise statt '
                    'Sicherheitsversprechen',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(
    BuildContext context,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Protokoll löschen?'),
        content: const Text(
          'Alle lokal gespeicherten Raumprüfungen '
          'werden dauerhaft entfernt.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await state.clearScans();
    }
  }
}
