import 'package:flutter/material.dart';

import '../services/wifi_environment_scanner_service.dart';

class WifiEnvironmentScreen extends StatefulWidget {
  const WifiEnvironmentScreen({super.key});

  @override
  State<WifiEnvironmentScreen> createState() =>
      _WifiEnvironmentScreenState();
}

class _WifiEnvironmentScreenState extends State<WifiEnvironmentScreen> {
  List<WifiEnvironmentNetwork> networks = [];
  bool scanning = false;
  bool scanCompleted = false;
  String? errorMessage;

  _WifiStrings get strings => _WifiStrings(
        Localizations.localeOf(context).languageCode,
      );

  Future<void> _scan() async {
    setState(() {
      scanning = true;
      errorMessage = null;
    });

    try {
      final results = await WifiEnvironmentScannerService().scan();

      if (!mounted) {
        return;
      }

      setState(() {
        networks = results;
        scanCompleted = true;
      });
    } on WifiEnvironmentScanException {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage = strings.text('permissionError');
        scanCompleted = true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage = strings.text('scanError');
        scanCompleted = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          scanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(text.text('title')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(text.text('explanation')),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: scanning ? null : _scan,
            icon: scanning
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.wifi_find),
            label: Text(
              scanning
                  ? text.text('scanning')
                  : text.text('startScan'),
            ),
          ),
          const SizedBox(height: 20),
          if (errorMessage != null)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(errorMessage!),
              ),
            ),
          if (scanCompleted && errorMessage == null) ...[
            Text(
              text.text('networksFound', count: networks.length),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            if (networks.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(text.text('noneFound')),
                ),
              )
            else
              ...networks.map(
                (network) => _NetworkCard(
                  network: network,
                  strings: text,
                ),
              ),
          ],
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(text.text('disclaimer')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkCard extends StatelessWidget {
  const _NetworkCard({
    required this.network,
    required this.strings,
  });

  final WifiEnvironmentNetwork network;
  final _WifiStrings strings;

  @override
  Widget build(BuildContext context) {
    final color = network.isOpen
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return Card(
      child: ListTile(
        leading: Icon(
          _signalIcon(network.signalLevel),
          color: color,
        ),
        title: Text(
          network.isHidden
              ? strings.text('hiddenNetwork')
              : network.ssid,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${network.frequencyBand} • '
          '${network.signalLevel} dBm\n'
          '${network.isOpen ? strings.text('openNetwork') : strings.text('protectedNetwork')}'
          '${network.isVeryClose ? ' • ${strings.text('veryClose')}' : ''}',
        ),
        isThreeLine: true,
        trailing: Icon(
          network.isOpen
              ? Icons.lock_open_outlined
              : Icons.lock_outline,
          color: color,
        ),
      ),
    );
  }

  IconData _signalIcon(int level) {
    if (level >= -50) {
      return Icons.signal_wifi_4_bar;
    }
    if (level >= -65) {
      return Icons.network_wifi_3_bar;
    }
    if (level >= -75) {
      return Icons.network_wifi_2_bar;
    }
    return Icons.network_wifi_1_bar;
  }
}

class _WifiStrings {
  const _WifiStrings(this.languageCode);

  final String languageCode;

  String text(String key, {int? count}) {
    final language = _values.containsKey(languageCode)
        ? languageCode
        : 'en';

    var value =
        _values[language]?[key] ??
        _values['en']?[key] ??
        key;

    if (count != null) {
      value = value.replaceAll('{count}', count.toString());
    }

    return value;
  }

  static const Map<String, Map<String, String>> _values = {
    'de': {
      'title': 'WLAN-Umgebung',
      'explanation':
          'Findet sichtbare WLAN-Netze in der Nähe. Eine Verbindung mit diesen Netzwerken ist nicht erforderlich.',
      'startScan': 'WLAN-Umgebung scannen',
      'scanning': 'WLAN-Netze werden gesucht …',
      'networksFound': 'Sichtbare WLAN-Netze ({count})',
      'noneFound': 'Keine sichtbaren WLAN-Netze gefunden.',
      'hiddenNetwork': 'Verstecktes WLAN',
      'openNetwork': 'Offenes Netzwerk',
      'protectedNetwork': 'Geschütztes Netzwerk',
      'veryClose': 'sehr starkes Signal',
      'permissionError':
          'Der WLAN-Scan benötigt die Berechtigung für Geräte in der Nähe und den aktivierten Standortdienst.',
      'scanError': 'Der WLAN-Umgebungsscan ist fehlgeschlagen.',
      'disclaimer':
          'Ein sichtbares oder starkes WLAN-Signal ist kein Beweis für eine Kamera oder ein Mikrofon.',
    },
    'en': {
      'title': 'Wi-Fi environment',
      'explanation':
          'Finds nearby visible Wi-Fi networks. You do not need to connect to these networks.',
      'startScan': 'Scan Wi-Fi environment',
      'scanning': 'Searching for Wi-Fi networks …',
      'networksFound': 'Visible Wi-Fi networks ({count})',
      'noneFound': 'No visible Wi-Fi networks found.',
      'hiddenNetwork': 'Hidden Wi-Fi network',
      'openNetwork': 'Open network',
      'protectedNetwork': 'Protected network',
      'veryClose': 'very strong signal',
      'permissionError':
          'Wi-Fi scanning requires nearby-device permission and enabled location services.',
      'scanError': 'The Wi-Fi environment scan failed.',
      'disclaimer':
          'A visible or strong Wi-Fi signal is not proof of a camera or microphone.',
    },
    'es': {
      'title': 'Entorno Wi-Fi',
      'explanation':
          'Encuentra redes Wi-Fi visibles cercanas sin necesidad de conectarse.',
      'startScan': 'Escanear entorno Wi-Fi',
      'scanning': 'Buscando redes Wi-Fi …',
      'networksFound': 'Redes Wi-Fi visibles ({count})',
      'noneFound': 'No se encontraron redes Wi-Fi visibles.',
      'hiddenNetwork': 'Red Wi-Fi oculta',
      'openNetwork': 'Red abierta',
      'protectedNetwork': 'Red protegida',
      'veryClose': 'señal muy fuerte',
      'permissionError':
          'El escaneo requiere permiso para dispositivos cercanos y la ubicación activada.',
      'scanError': 'El escaneo del entorno Wi-Fi falló.',
      'disclaimer':
          'Una señal Wi-Fi visible o fuerte no demuestra que exista una cámara o un micrófono.',
    },
    'fr': {
      'title': 'Environnement Wi-Fi',
      'explanation':
          'Détecte les réseaux Wi-Fi visibles à proximité sans devoir s’y connecter.',
      'startScan': 'Analyser les réseaux Wi-Fi',
      'scanning': 'Recherche des réseaux Wi-Fi …',
      'networksFound': 'Réseaux Wi-Fi visibles ({count})',
      'noneFound': 'Aucun réseau Wi-Fi visible trouvé.',
      'hiddenNetwork': 'Réseau Wi-Fi masqué',
      'openNetwork': 'Réseau ouvert',
      'protectedNetwork': 'Réseau protégé',
      'veryClose': 'signal très puissant',
      'permissionError':
          'L’analyse nécessite l’autorisation des appareils à proximité et la localisation activée.',
      'scanError': 'L’analyse de l’environnement Wi-Fi a échoué.',
      'disclaimer':
          'Un signal Wi-Fi visible ou puissant ne prouve pas la présence d’une caméra ou d’un microphone.',
    },
    'it': {
      'title': 'Ambiente Wi-Fi',
      'explanation':
          'Trova le reti Wi-Fi visibili nelle vicinanze senza connettersi.',
      'startScan': 'Scansiona ambiente Wi-Fi',
      'scanning': 'Ricerca delle reti Wi-Fi …',
      'networksFound': 'Reti Wi-Fi visibili ({count})',
      'noneFound': 'Nessuna rete Wi-Fi visibile trovata.',
      'hiddenNetwork': 'Rete Wi-Fi nascosta',
      'openNetwork': 'Rete aperta',
      'protectedNetwork': 'Rete protetta',
      'veryClose': 'segnale molto forte',
      'permissionError':
          'La scansione richiede il permesso per i dispositivi vicini e la posizione attiva.',
      'scanError': 'Scansione dell’ambiente Wi-Fi non riuscita.',
      'disclaimer':
          'Un segnale Wi-Fi visibile o forte non dimostra la presenza di una fotocamera o di un microfono.',
    },
    'pt': {
      'title': 'Ambiente Wi-Fi',
      'explanation':
          'Encontra redes Wi-Fi visíveis próximas sem ser necessário estabelecer ligação.',
      'startScan': 'Analisar ambiente Wi-Fi',
      'scanning': 'A procurar redes Wi-Fi …',
      'networksFound': 'Redes Wi-Fi visíveis ({count})',
      'noneFound': 'Nenhuma rede Wi-Fi visível encontrada.',
      'hiddenNetwork': 'Rede Wi-Fi oculta',
      'openNetwork': 'Rede aberta',
      'protectedNetwork': 'Rede protegida',
      'veryClose': 'sinal muito forte',
      'permissionError':
          'A análise requer permissão para dispositivos próximos e a localização ativada.',
      'scanError': 'A análise do ambiente Wi-Fi falhou.',
      'disclaimer':
          'Um sinal Wi-Fi visível ou forte não prova a existência de uma câmara ou microfone.',
    },
    'nl': {
      'title': 'Wifi-omgeving',
      'explanation':
          'Zoekt zichtbare wifi-netwerken in de buurt zonder ermee te verbinden.',
      'startScan': 'Wifi-omgeving scannen',
      'scanning': 'Wifi-netwerken zoeken …',
      'networksFound': 'Zichtbare wifi-netwerken ({count})',
      'noneFound': 'Geen zichtbare wifi-netwerken gevonden.',
      'hiddenNetwork': 'Verborgen wifi-netwerk',
      'openNetwork': 'Open netwerk',
      'protectedNetwork': 'Beveiligd netwerk',
      'veryClose': 'zeer sterk signaal',
      'permissionError':
          'De scan vereist toestemming voor apparaten in de buurt en ingeschakelde locatie.',
      'scanError': 'De wifi-omgevingsscan is mislukt.',
      'disclaimer':
          'Een zichtbaar of sterk wifi-signaal bewijst niet dat er een camera of microfoon aanwezig is.',
    },
    'pl': {
      'title': 'Otoczenie Wi-Fi',
      'explanation':
          'Wykrywa pobliskie widoczne sieci Wi-Fi bez konieczności łączenia się z nimi.',
      'startScan': 'Skanuj otoczenie Wi-Fi',
      'scanning': 'Wyszukiwanie sieci Wi-Fi …',
      'networksFound': 'Widoczne sieci Wi-Fi ({count})',
      'noneFound': 'Nie znaleziono widocznych sieci Wi-Fi.',
      'hiddenNetwork': 'Ukryta sieć Wi-Fi',
      'openNetwork': 'Sieć otwarta',
      'protectedNetwork': 'Sieć chroniona',
      'veryClose': 'bardzo silny sygnał',
      'permissionError':
          'Skanowanie wymaga uprawnienia do pobliskich urządzeń i włączonej lokalizacji.',
      'scanError': 'Skanowanie otoczenia Wi-Fi nie powiodło się.',
      'disclaimer':
          'Widoczny lub silny sygnał Wi-Fi nie potwierdza obecności kamery ani mikrofonu.',
    },
    'tr': {
      'title': 'Wi-Fi ortamı',
      'explanation':
          'Bağlantı kurmadan yakındaki görünür Wi-Fi ağlarını bulur.',
      'startScan': 'Wi-Fi ortamını tara',
      'scanning': 'Wi-Fi ağları aranıyor …',
      'networksFound': 'Görünür Wi-Fi ağları ({count})',
      'noneFound': 'Görünür Wi-Fi ağı bulunamadı.',
      'hiddenNetwork': 'Gizli Wi-Fi ağı',
      'openNetwork': 'Açık ağ',
      'protectedNetwork': 'Korumalı ağ',
      'veryClose': 'çok güçlü sinyal',
      'permissionError':
          'Tarama için yakındaki cihaz izni ve konum hizmetinin açık olması gerekir.',
      'scanError': 'Wi-Fi ortam taraması başarısız oldu.',
      'disclaimer':
          'Görünür veya güçlü bir Wi-Fi sinyali kamera ya da mikrofon bulunduğunu kanıtlamaz.',
    },
  };
}
