# Architektur und Sicherheitsmodell

## Vertrauensgrenze

Alle MVP-Daten bleiben innerhalb der Android-App-Sandbox. Es existieren keine
API-Schlüssel, kein Backend und keine Telemetrie. Eingelesene QR-Inhalte gelten
als nicht vertrauenswürdig und werden nur als Text dargestellt.

## Auswertung

Ein `Finding` enthält Quelle, vermuteten Gerätetyp, Risiko, Begründung und eine
Konfidenz zwischen 0 und 1. Ein `RoomScan` aggregiert diese Hinweise. Ein leerer
Scan erhält absichtlich nur den neutralen Score 50: „nichts gefunden“ bedeutet
nicht „sicher“.

## Aktuelle Grenzen

- BLE deckt nur Geräte ab, die im Scan-Zeitraum tatsächlich senden.
- Gerätenamen können fehlen, beliebig gewählt oder irreführend sein.
- Die manuelle Sichtprüfung ist nutzergeführt; noch kein CV-Modell entscheidet.
- QR-Hinweise werden im MVP erfasst, aber noch nicht semantisch validiert.
- Das Protokoll ist lokal, jedoch noch nicht zusätzlich anwendungsseitig
  verschlüsselt.

## Regeln für kommende Detektoren

Jeder neue Detektor muss nachvollziehbare Evidenz, eine kalibrierte Konfidenz
und eine nutzerlesbare Begründung liefern. Passive Erkennung ist zulässig;
offensive Netzwerktests, das Umgehen von Zugangsschutz oder das Manipulieren
fremder Geräte sind ausgeschlossen.

