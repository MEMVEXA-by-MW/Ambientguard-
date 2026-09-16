# AmbientGuard

AmbientGuard ist eine **on-device-first Android-App**, die Datenschutzrisiken in
physischen Räumen verständlich macht. Sie sammelt sichtbare Beobachtungen,
Bluetooth-Hinweise und Datenschutz-QR-Codes und erstellt daraus eine erklärbare
Risikoeinschätzung mit Konfidenzwerten.

> AmbientGuard kann niemals beweisen, dass ein Raum frei von Kameras oder
> Mikrofonen ist. Das Produkt zeigt Hinweise und Unsicherheit – kein falsches
> Sicherheitsversprechen.

## Aktueller MVP

- deutsches Onboarding und Material-3-Design
- manuelle Sichtprüfung für Kameras, Mikrofone, Smart Speaker und Displays
- reale BLE-Umgebungssuche mit lokaler, heuristischer Klassifikation
- QR-Scanner für Datenschutzinformationen des Raum-Betreibers
- erklärbarer Privacy Score, Risikostufe und Konfidenz je Fund
- vollständig lokales Expositionsprotokoll ohne Konto oder Cloud
- Datenlöschung in der App
- Android 7.0+ (`minSdk 24`), Ziel-SDK 36
- GitHub Actions für Analyse, Tests, Universal APK und Play-Store-AAB

## Projekt starten

Voraussetzungen: Flutter stable, Android SDK 36, Java 17.

```bash
flutter create --platforms=android --org de.ambientguard --project-name ambientguard .
flutter pub get
flutter run
```

Der erste Befehl ergänzt nur generierte Flutter-/Gradle-Dateien wie den Wrapper.
Die bereits vorhandenen App-Dateien bleiben erhalten.

## Android-Build

```bash
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
```

Bei jedem Push auf `main` erzeugt GitHub Actions beide Artefakte. Unter
**Actions → Build Android APK and AAB → Artifacts** kann `AmbientGuard-Android`
heruntergeladen werden.

## Architektur

```text
lib/
├── core/theme/       Designsystem
├── models/           Finding und RoomScan
├── services/         BLE-Scanner und lokale Speicherung
├── state/            schlanker App-Zustand
└── screens/          Onboarding, Dashboard, Scan, Ergebnis, Verlauf, Settings
```

Es gibt bewusst keine Server-Komponente. `SharedPreferences` speichert das
kleine MVP-Protokoll lokal als JSON. Für die nächste Ausbaustufe sollte dies
durch verschlüsselte SQLite-Speicherung ersetzt werden.

## Produktgrenzen und Compliance

- keine Netzwerkangriffe, Port-Scans, Deauthentifizierung oder Exploits
- keine heimliche Bild-, Ton- oder Standortaufzeichnung
- keine Aussage „Raum ist sicher“ oder „kamera-/mikrofonfrei“
- BLE-Namen sind unzuverlässige Indizien; daher werden Konfidenzen angezeigt
- Kamera-KI darf erst mit dokumentiertem Datensatz, Schwellenwerten und
  False-Positive-Tests als automatische Erkennung veröffentlicht werden
- vor Play-Store-Veröffentlichung: Datenschutzerklärung, Data-Safety-Formular,
  produktive Signierung und Berechtigungsbegründungen ergänzen

## Nächste technische Meilensteine

1. TFLite-Modell für sichtbare Kamera-/Speaker-/Display-Erkennung integrieren.
2. ARCore-Overlays und räumliche Positionen erkannter Geräte ergänzen.
3. mDNS/NSD nur passiv zur lokalen Geräte-Korrelation nutzen.
4. QR-Privacy-Notice strukturiert auswerten und Abweichungen erklären.
5. verschlüsselte SQLite-Datenbank plus optionalen, lokalen PDF-Bericht bauen.
6. B2B-Modus für Hotel-/Coworking-Audits getrennt vom Consumer-MVP entwickeln.

## Lizenz

Copyright © 2026. Alle Rechte vorbehalten. Vor einer öffentlichen
Open-Source-Veröffentlichung eine gewünschte Lizenz ergänzen.
