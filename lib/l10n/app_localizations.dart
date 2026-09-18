import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
    Locale('nl'),
    Locale('pl'),
    Locale('tr'),
  ];

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localization =
        Localizations.of<AppLocalizations>(
          context,
          AppLocalizations,
        );

    return localization ?? AppLocalizations(const Locale('en'));
  }

  String get languageCode {
    final code = locale.languageCode.toLowerCase();

    if (_translations.containsKey(code)) {
      return code;
    }

    return 'en';
  }

  String text(
    String key, [
    Map<String, Object> values = const {},
  ]) {
    final selected =
        _translations[languageCode] ?? _translations['en']!;

    var result =
        selected[key] ?? _translations['en']![key] ?? key;

    for (final entry in values.entries) {
      result = result.replaceAll(
        '{${entry.key}}',
        entry.value.toString(),
      );
    }

    return result;
  }

  static String languageName(String? code) {
    return switch (code) {
      null => 'Automatisch',
      'de' => 'Deutsch',
      'en' => 'English',
      'es' => 'Español',
      'fr' => 'Français',
      'it' => 'Italiano',
      'pt' => 'Português',
      'nl' => 'Nederlands',
      'pl' => 'Polski',
      'tr' => 'Türkçe',
      _ => 'English',
    };
  }

  static const _translations =
      <String, Map<String, String>>{
    'de': {
      'language': 'Sprache',
      'automatic': 'Automatisch – Handysprache',
      'overview': 'Übersicht',
      'history': 'Verlauf',
      'settings': 'Einstellungen',
      'checkRoom': 'Raum prüfen',
      'continue': 'Weiter',
      'cancel': 'Abbrechen',
      'delete': 'Löschen',
      'low': 'niedrig',
      'medium': 'mittel',
      'high': 'hoch',
    },
    'en': {
      'language': 'Language',
      'automatic': 'Automatic – device language',
      'overview': 'Overview',
      'history': 'History',
      'settings': 'Settings',
      'checkRoom': 'Check room',
      'continue': 'Continue',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'low': 'low',
      'medium': 'medium',
      'high': 'high',
    },
    'es': {
      'language': 'Idioma',
      'automatic': 'Automático – idioma del dispositivo',
      'overview': 'Resumen',
      'history': 'Historial',
      'settings': 'Ajustes',
      'checkRoom': 'Comprobar habitación',
      'continue': 'Continuar',
      'cancel': 'Cancelar',
      'delete': 'Eliminar',
      'low': 'bajo',
      'medium': 'medio',
      'high': 'alto',
    },
    'fr': {
      'language': 'Langue',
      'automatic': 'Automatique – langue de l’appareil',
      'overview': 'Aperçu',
      'history': 'Historique',
      'settings': 'Paramètres',
      'checkRoom': 'Vérifier la pièce',
      'continue': 'Continuer',
      'cancel': 'Annuler',
      'delete': 'Supprimer',
      'low': 'faible',
      'medium': 'moyen',
      'high': 'élevé',
    },
    'it': {
      'language': 'Lingua',
      'automatic': 'Automatica – lingua del dispositivo',
      'overview': 'Panoramica',
      'history': 'Cronologia',
      'settings': 'Impostazioni',
      'checkRoom': 'Controlla ambiente',
      'continue': 'Continua',
      'cancel': 'Annulla',
      'delete': 'Elimina',
      'low': 'basso',
      'medium': 'medio',
      'high': 'alto',
    },
    'pt': {
      'language': 'Idioma',
      'automatic': 'Automático – idioma do dispositivo',
      'overview': 'Visão geral',
      'history': 'Histórico',
      'settings': 'Definições',
      'checkRoom': 'Verificar espaço',
      'continue': 'Continuar',
      'cancel': 'Cancelar',
      'delete': 'Eliminar',
      'low': 'baixo',
      'medium': 'médio',
      'high': 'alto',
    },
    'nl': {
      'language': 'Taal',
      'automatic': 'Automatisch – apparaattaal',
      'overview': 'Overzicht',
      'history': 'Geschiedenis',
      'settings': 'Instellingen',
      'checkRoom': 'Ruimte controleren',
      'continue': 'Doorgaan',
      'cancel': 'Annuleren',
      'delete': 'Verwijderen',
      'low': 'laag',
      'medium': 'gemiddeld',
      'high': 'hoog',
    },
    'pl': {
      'language': 'Język',
      'automatic': 'Automatycznie – język urządzenia',
      'overview': 'Przegląd',
      'history': 'Historia',
      'settings': 'Ustawienia',
      'checkRoom': 'Sprawdź pomieszczenie',
      'continue': 'Dalej',
      'cancel': 'Anuluj',
      'delete': 'Usuń',
      'low': 'niskie',
      'medium': 'średnie',
      'high': 'wysokie',
    },
    'tr': {
      'language': 'Dil',
      'automatic': 'Otomatik – cihaz dili',
      'overview': 'Genel bakış',
      'history': 'Geçmiş',
      'settings': 'Ayarlar',
      'checkRoom': 'Odayı kontrol et',
      'continue': 'Devam et',
      'cancel': 'İptal',
      'delete': 'Sil',
      'low': 'düşük',
      'medium': 'orta',
      'high': 'yüksek',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) =>
          supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<AppLocalizations> old,
  ) {
    return false;
  }
}

extension AppLocalizationContext on BuildContext {
  AppLocalizations get l10n {
    return AppLocalizations.of(this);
  }

  String tr(
    String key, [
    Map<String, Object> values = const {},
  ]) {
    return l10n.text(key, values);
  }
}
