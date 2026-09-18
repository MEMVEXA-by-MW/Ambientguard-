import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../state/app_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    required this.state,
    super.key,
  });

  final AppState state;

  @override
  State<OnboardingScreen> createState() {
    return _OnboardingScreenState();
  }
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {
  final controller = PageController();
  int page = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.l10n.languageCode;
    final items = _items(language);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: controller,
                  onPageChanged: (value) {
                    setState(() {
                      page = value;
                    });
                  },
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final item = items[index];

                    return Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.$1,
                          size: 96,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          item.$2,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight:
                                    FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.$3,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: List.generate(
                  items.length,
                  (index) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      width: index == page ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: index == page
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                            : Colors.grey.shade400,
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  if (page < items.length - 1) {
                    await controller.nextPage(
                      duration: const Duration(
                        milliseconds: 250,
                      ),
                      curve: Curves.easeOut,
                    );
                  } else {
                    await widget.state
                        .finishOnboarding();

                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: Text(
                  page < items.length - 1
                      ? context.tr('continue')
                      : _startText(language),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<(IconData, String, String)> _items(
  String language,
) {
  return switch (language) {
    'de' => const [
        (
          Icons.shield_outlined,
          'Privatsphäre sichtbar machen',
          'AmbientGuard sammelt lokale Hinweise auf vernetzte oder sensorfähige Geräte in einem Raum.',
        ),
        (
          Icons.phonelink_lock_outlined,
          'Direkt auf dem Gerät',
          'Deine Prüfungen bleiben auf diesem Gerät. Es gibt kein Konto und keinen Upload in eine Cloud.',
        ),
        (
          Icons.rule,
          'Ehrlich bei Unsicherheit',
          'Jeder Hinweis erhält eine Konfidenz. Die App verspricht niemals einen garantiert sicheren Raum.',
        ),
      ],
    'es' => const [
        (
          Icons.shield_outlined,
          'Haz visible la privacidad',
          'AmbientGuard recopila localmente indicios de dispositivos conectados o con sensores presentes en una habitación.',
        ),
        (
          Icons.phonelink_lock_outlined,
          'Directamente en el dispositivo',
          'Tus comprobaciones permanecen en este dispositivo. No necesitas una cuenta y no se suben datos a la nube.',
        ),
        (
          Icons.rule,
          'Transparencia ante la incertidumbre',
          'Cada indicio recibe un nivel de confianza. La aplicación nunca promete una habitación completamente segura.',
        ),
      ],
    'fr' => const [
        (
          Icons.shield_outlined,
          'Rendre la confidentialité visible',
          'AmbientGuard collecte localement des indices concernant les appareils connectés ou équipés de capteurs dans une pièce.',
        ),
        (
          Icons.phonelink_lock_outlined,
          'Directement sur l’appareil',
          'Vos vérifications restent sur cet appareil. Aucun compte ni téléversement dans le cloud.',
        ),
        (
          Icons.rule,
          'Transparent face à l’incertitude',
          'Chaque indice reçoit un niveau de confiance. L’application ne promet jamais une pièce totalement sûre.',
        ),
      ],
    'it' => const [
        (
          Icons.shield_outlined,
          'Rendi visibile la privacy',
          'AmbientGuard raccoglie localmente indizi relativi a dispositivi connessi o dotati di sensori presenti nell’ambiente.',
        ),
        (
          Icons.phonelink_lock_outlined,
          'Direttamente sul dispositivo',
          'I controlli restano su questo dispositivo. Non sono necessari account o caricamenti nel cloud.',
        ),
        (
          Icons.rule,
          'Trasparente sull’incertezza',
          'Ogni indizio riceve un livello di affidabilità. L’app non promette mai un ambiente completamente sicuro.',
        ),
      ],
    'pt' => const [
        (
          Icons.shield_outlined,
          'Torne a privacidade visível',
          'O AmbientGuard recolhe localmente indícios de dispositivos ligados ou com sensores presentes num espaço.',
        ),
        (
          Icons.phonelink_lock_outlined,
          'Diretamente no dispositivo',
          'As verificações permanecem neste dispositivo. Não existe conta nem carregamento para a nuvem.',
        ),
        (
          Icons.rule,
          'Transparente perante a incerteza',
          'Cada indício recebe um nível de confiança. A aplicação nunca promete um espaço completamente seguro.',
        ),
      ],
    'nl' => const [
        (
          Icons.shield_outlined,
          'Maak privacy zichtbaar',
          'AmbientGuard verzamelt lokaal aanwijzingen voor verbonden apparaten of apparaten met sensoren in een ruimte.',
        ),
        (
          Icons.phonelink_lock_outlined,
          'Direct op het apparaat',
          'Je controles blijven op dit apparaat. Er is geen account en er worden geen gegevens naar de cloud geüpload.',
        ),
        (
          Icons.rule,
          'Eerlijk over onzekerheid',
          'Elke aanwijzing krijgt een betrouwbaarheidsniveau. De app belooft nooit dat een ruimte volledig veilig is.',
        ),
      ],
    'pl' => const [
        (
          Icons.shield_outlined,
          'Zobacz poziom prywatności',
          'AmbientGuard lokalnie zbiera wskazówki dotyczące urządzeń połączonych lub wyposażonych w czujniki.',
        ),
        (
          Icons.phonelink_lock_outlined,
          'Bezpośrednio na urządzeniu',
          'Kontrole pozostają na tym urządzeniu. Konto i przesyłanie danych do chmury nie są wymagane.',
        ),
        (
          Icons.rule,
          'Uczciwie o niepewności',
          'Każda wskazówka otrzymuje poziom wiarygodności. Aplikacja nigdy nie gwarantuje całkowicie bezpiecznego pomieszczenia.',
        ),
      ],
    'tr' => const [
        (
          Icons.shield_outlined,
          'Gizliliği görünür kılın',
          'AmbientGuard, odadaki bağlı veya sensörlü cihazlara ilişkin işaretleri yerel olarak toplar.',
        ),
        (
          Icons.phonelink_lock_outlined,
          'Doğrudan cihaz üzerinde',
          'Kontrolleriniz bu cihazda kalır. Hesap gerekmez ve buluta veri yüklenmez.',
        ),
        (
          Icons.rule,
          'Belirsizlik konusunda şeffaf',
          'Her bulguya bir güven düzeyi verilir. Uygulama hiçbir zaman tamamen güvenli bir oda garantisi vermez.',
        ),
      ],
    _ => const [
        (
          Icons.shield_outlined,
          'Make privacy visible',
          'AmbientGuard locally collects indicators of connected or sensor-enabled devices in a room.',
        ),
        (
          Icons.phonelink_lock_outlined,
          'On-device first',
          'Your checks remain on this device. No account is required and nothing is uploaded to the cloud.',
        ),
        (
          Icons.rule,
          'Honest about uncertainty',
          'Every finding receives a confidence level. The app never promises a completely secure room.',
        ),
      ],
  };
}

String _startText(String language) {
  return switch (language) {
    'de' => 'AmbientGuard starten',
    'es' => 'Iniciar AmbientGuard',
    'fr' => 'Démarrer AmbientGuard',
    'it' => 'Avvia AmbientGuard',
    'pt' => 'Iniciar AmbientGuard',
    'nl' => 'AmbientGuard starten',
    'pl' => 'Uruchom AmbientGuard',
    'tr' => 'AmbientGuard’ı başlat',
    _ => 'Start AmbientGuard',
  };
}
