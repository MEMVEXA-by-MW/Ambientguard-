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

    return localization ??
        AppLocalizations(const Locale('en'));
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
        _translations[languageCode] ??
        _translations['en']!;

    var result =
        selected[key] ??
        _translations['en']![key] ??
        key;

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
      'tagline':
          'Privatsphäre im Raum besser einschätzen',
      'howItWorks': 'So funktioniert es',
      'visualInspection': 'Sichtprüfung',
      'visualInspectionText':
          'Kameraansicht nutzen und auffällige Geräte dokumentieren.',
      'radioSignals': 'Funksignale',
      'radioSignalsText':
          'Bluetooth-Geräte in der Umgebung und erreichbare Geräte im verbundenen WLAN erfassen.',
      'privacyNotice': 'Datenschutz-Hinweis',
      'privacyNoticeText':
          'QR-Code des Raums einlesen und mit Beobachtungen abgleichen.',
      'roomDisclaimer':
          'AmbientGuard erkennt Hinweise, kann aber nicht garantieren, dass ein Raum frei von Kameras oder Mikrofonen ist.',
      'noRoomChecked': 'Noch kein Raum geprüft',
      'lastRating': 'Letzte Bewertung: {score}/100',
      'startLocalCheck':
          'Starte eine lokale Prüfung. Aufnahmen werden nicht hochgeladen.',
      'scanSummary':
          '{label} · {count} Hinweise',
      'newRoomCheck': 'Neue Raumprüfung',
      'localLog': 'Lokales Protokoll',
      'noSavedChecks':
          'Noch keine gespeicherten Raumprüfungen.',
      'savedFindings': '{count} Hinweise',
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
      'tagline':
          'Assess privacy risks in your surroundings',
      'howItWorks': 'How it works',
      'visualInspection': 'Visual inspection',
      'visualInspectionText':
          'Use the camera view and document unusual devices.',
      'radioSignals': 'Wireless signals',
      'radioSignalsText':
          'Detect nearby Bluetooth devices and reachable devices on the connected Wi-Fi network.',
      'privacyNotice': 'Privacy notice',
      'privacyNoticeText':
          'Scan the room’s QR code and compare it with your observations.',
      'roomDisclaimer':
          'AmbientGuard identifies indicators but cannot guarantee that a room is free from cameras or microphones.',
      'noRoomChecked': 'No room checked yet',
      'lastRating': 'Latest rating: {score}/100',
      'startLocalCheck':
          'Start a local check. Recordings are not uploaded.',
      'scanSummary':
          '{label} · {count} findings',
      'newRoomCheck': 'New room check',
      'localLog': 'Local history',
      'noSavedChecks':
          'No saved room checks yet.',
      'savedFindings': '{count} findings',
    },
    'es': {
      'language': 'Idioma',
      'automatic':
          'Automático – idioma del dispositivo',
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
      'tagline':
          'Evalúa mejor la privacidad del entorno',
      'howItWorks': 'Cómo funciona',
      'visualInspection': 'Inspección visual',
      'visualInspectionText':
          'Utiliza la cámara y documenta dispositivos sospechosos.',
      'radioSignals': 'Señales inalámbricas',
      'radioSignalsText':
          'Detecta dispositivos Bluetooth cercanos y dispositivos accesibles en la red Wi-Fi conectada.',
      'privacyNotice': 'Aviso de privacidad',
      'privacyNoticeText':
          'Escanea el código QR de la habitación y compáralo con tus observaciones.',
      'roomDisclaimer':
          'AmbientGuard identifica indicios, pero no puede garantizar que una habitación esté libre de cámaras o micrófonos.',
      'noRoomChecked':
          'Todavía no se ha comprobado ninguna habitación',
      'lastRating':
          'Última valoración: {score}/100',
      'startLocalCheck':
          'Inicia una comprobación local. Las grabaciones no se suben.',
      'scanSummary':
          '{label} · {count} indicios',
      'newRoomCheck':
          'Nueva comprobación',
      'localLog': 'Historial local',
      'noSavedChecks':
          'Todavía no hay comprobaciones guardadas.',
      'savedFindings': '{count} indicios',
    },
    'fr': {
      'language': 'Langue',
      'automatic':
          'Automatique – langue de l’appareil',
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
      'tagline':
          'Mieux évaluer la confidentialité de votre environnement',
      'howItWorks': 'Fonctionnement',
      'visualInspection': 'Inspection visuelle',
      'visualInspectionText':
          'Utilisez la caméra et documentez les appareils inhabituels.',
      'radioSignals': 'Signaux sans fil',
      'radioSignalsText':
          'Détectez les appareils Bluetooth proches et les appareils accessibles sur le réseau Wi-Fi connecté.',
      'privacyNotice':
          'Information sur la confidentialité',
      'privacyNoticeText':
          'Scannez le code QR de la pièce et comparez-le à vos observations.',
      'roomDisclaimer':
          'AmbientGuard identifie des indices, mais ne peut pas garantir qu’une pièce est exempte de caméras ou de microphones.',
      'noRoomChecked':
          'Aucune pièce vérifiée',
      'lastRating':
          'Dernière évaluation : {score}/100',
      'startLocalCheck':
          'Lancez une vérification locale. Aucun enregistrement n’est téléversé.',
      'scanSummary':
          '{label} · {count} indices',
      'newRoomCheck':
          'Nouvelle vérification',
      'localLog': 'Historique local',
      'noSavedChecks':
          'Aucune vérification enregistrée.',
      'savedFindings': '{count} indices',
    },
    'it': {
      'language': 'Lingua',
      'automatic':
          'Automatica – lingua del dispositivo',
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
      'tagline':
          'Valuta meglio la privacy dell’ambiente',
      'howItWorks': 'Come funziona',
      'visualInspection': 'Ispezione visiva',
      'visualInspectionText':
          'Usa la fotocamera e documenta i dispositivi insoliti.',
      'radioSignals': 'Segnali wireless',
      'radioSignalsText':
          'Rileva dispositivi Bluetooth vicini e dispositivi raggiungibili nella rete Wi-Fi connessa.',
      'privacyNotice':
          'Informativa sulla privacy',
      'privacyNoticeText':
          'Scansiona il codice QR dell’ambiente e confrontalo con le osservazioni.',
      'roomDisclaimer':
          'AmbientGuard identifica possibili indizi, ma non può garantire che un ambiente sia privo di telecamere o microfoni.',
      'noRoomChecked':
          'Nessun ambiente controllato',
      'lastRating':
          'Ultima valutazione: {score}/100',
      'startLocalCheck':
          'Avvia un controllo locale. Le registrazioni non vengono caricate.',
      'scanSummary':
          '{label} · {count} indizi',
      'newRoomCheck':
          'Nuovo controllo',
      'localLog': 'Cronologia locale',
      'noSavedChecks':
          'Nessun controllo salvato.',
      'savedFindings': '{count} indizi',
    },
    'pt': {
      'language': 'Idioma',
      'automatic':
          'Automático – idioma do dispositivo',
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
      'tagline':
          'Avalie melhor a privacidade do ambiente',
      'howItWorks': 'Como funciona',
      'visualInspection': 'Inspeção visual',
      'visualInspectionText':
          'Utilize a câmara e documente dispositivos invulgares.',
      'radioSignals': 'Sinais sem fios',
      'radioSignalsText':
          'Detete dispositivos Bluetooth próximos e dispositivos acessíveis na rede Wi-Fi ligada.',
      'privacyNotice':
          'Aviso de privacidade',
      'privacyNoticeText':
          'Leia o código QR do espaço e compare-o com as suas observações.',
      'roomDisclaimer':
          'O AmbientGuard identifica indícios, mas não pode garantir que um espaço esteja livre de câmaras ou microfones.',
      'noRoomChecked':
          'Nenhum espaço verificado',
      'lastRating':
          'Última avaliação: {score}/100',
      'startLocalCheck':
          'Inicie uma verificação local. As gravações não são carregadas.',
      'scanSummary':
          '{label} · {count} indícios',
      'newRoomCheck':
          'Nova verificação',
      'localLog': 'Histórico local',
      'noSavedChecks':
          'Ainda não existem verificações guardadas.',
      'savedFindings': '{count} indícios',
    },
    'nl': {
      'language': 'Taal',
      'automatic':
          'Automatisch – apparaattaal',
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
      'tagline':
          'Beoordeel de privacy in je omgeving',
      'howItWorks': 'Zo werkt het',
      'visualInspection': 'Visuele controle',
      'visualInspectionText':
          'Gebruik de camera en documenteer opvallende apparaten.',
      'radioSignals': 'Draadloze signalen',
      'radioSignalsText':
          'Detecteer Bluetooth-apparaten in de buurt en bereikbare apparaten op het verbonden wifi-netwerk.',
      'privacyNotice': 'Privacyverklaring',
      'privacyNoticeText':
          'Scan de QR-code van de ruimte en vergelijk deze met je waarnemingen.',
      'roomDisclaimer':
          'AmbientGuard herkent aanwijzingen, maar kan niet garanderen dat een ruimte vrij is van camera’s of microfoons.',
      'noRoomChecked':
          'Nog geen ruimte gecontroleerd',
      'lastRating':
          'Laatste beoordeling: {score}/100',
      'startLocalCheck':
          'Start een lokale controle. Opnamen worden niet geüpload.',
      'scanSummary':
          '{label} · {count} aanwijzingen',
      'newRoomCheck':
          'Nieuwe ruimtecontrole',
      'localLog': 'Lokale geschiedenis',
      'noSavedChecks':
          'Nog geen controles opgeslagen.',
      'savedFindings':
          '{count} aanwijzingen',
    },
    'pl': {
      'language': 'Język',
      'automatic':
          'Automatycznie – język urządzenia',
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
      'tagline':
          'Lepiej oceń prywatność otoczenia',
      'howItWorks': 'Jak to działa',
      'visualInspection':
          'Kontrola wzrokowa',
      'visualInspectionText':
          'Użyj aparatu i udokumentuj nietypowe urządzenia.',
      'radioSignals': 'Sygnały bezprzewodowe',
      'radioSignalsText':
          'Wykrywaj pobliskie urządzenia Bluetooth oraz urządzenia dostępne w połączonej sieci Wi-Fi.',
      'privacyNotice':
          'Informacja o prywatności',
      'privacyNoticeText':
          'Zeskanuj kod QR pomieszczenia i porównaj go z obserwacjami.',
      'roomDisclaimer':
          'AmbientGuard wykrywa wskazówki, ale nie może zagwarantować, że pomieszczenie jest wolne od kamer lub mikrofonów.',
      'noRoomChecked':
          'Nie sprawdzono jeszcze pomieszczenia',
      'lastRating':
          'Ostatnia ocena: {score}/100',
      'startLocalCheck':
          'Rozpocznij lokalną kontrolę. Nagrania nie są przesyłane.',
      'scanSummary':
          '{label} · wskazówki: {count}',
      'newRoomCheck':
          'Nowa kontrola pomieszczenia',
      'localLog': 'Historia lokalna',
      'noSavedChecks':
          'Brak zapisanych kontroli.',
      'savedFindings':
          'Wskazówki: {count}',
    },
    'tr': {
      'language': 'Dil',
      'automatic':
          'Otomatik – cihaz dili',
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
      'tagline':
          'Bulunduğunuz ortamdaki gizliliği değerlendirin',
      'howItWorks': 'Nasıl çalışır',
      'visualInspection': 'Görsel inceleme',
      'visualInspectionText':
          'Kamerayı kullanın ve dikkat çeken cihazları belgeleyin.',
      'radioSignals': 'Kablosuz sinyaller',
      'radioSignalsText':
          'Yakındaki Bluetooth cihazlarını ve bağlı Wi-Fi ağındaki erişilebilir cihazları algılayın.',
      'privacyNotice':
          'Gizlilik bildirimi',
      'privacyNoticeText':
          'Odanın QR kodunu tarayın ve gözlemlerinizle karşılaştırın.',
      'roomDisclaimer':
          'AmbientGuard olası işaretleri belirler ancak bir odada kamera veya mikrofon bulunmadığını garanti edemez.',
      'noRoomChecked':
          'Henüz oda kontrol edilmedi',
      'lastRating':
          'Son değerlendirme: {score}/100',
      'startLocalCheck':
          'Yerel bir kontrol başlatın. Kayıtlar yüklenmez.',
      'scanSummary':
          '{label} · {count} bulgu',
      'newRoomCheck': 'Yeni oda kontrolü',
      'localLog': 'Yerel geçmiş',
      'noSavedChecks':
          'Henüz kayıtlı oda kontrolü yok.',
      'savedFindings': '{count} bulgu',
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
          supported.languageCode ==
          locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(
    Locale locale,
  ) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<AppLocalizations>
        old,
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
