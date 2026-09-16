import 'package:flutter/material.dart';

import '../state/app_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.state, super.key});
  final AppState state;
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int page = 0;

  static const items = [
    (Icons.shield_outlined, 'Privatsphäre sichtbar machen', 'AmbientGuard sammelt lokale Hinweise auf vernetzte oder sensorfähige Geräte in einem Raum.'),
    (Icons.phonelink_lock_outlined, 'On-device first', 'Deine Prüfungen bleiben auf diesem Gerät. Es gibt kein Konto und keinen Upload in eine Cloud.'),
    (Icons.rule, 'Ehrlich bei Unsicherheit', 'Jeder Hinweis erhält eine Konfidenz. Die App verspricht niemals einen garantiert sicheren Raum.'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Expanded(
                child: PageView.builder(
                  controller: controller,
                  onPageChanged: (value) => setState(() => page = value),
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final item = items[index];
                    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(item.$1, size: 96, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 32),
                      Text(item.$2, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      Text(item.$3, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
                    ]);
                  },
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(items.length, (i) => Container(margin: const EdgeInsets.all(4), width: i == page ? 24 : 8, height: 8, decoration: BoxDecoration(color: i == page ? Theme.of(context).colorScheme.primary : Colors.grey.shade400, borderRadius: BorderRadius.circular(8))))),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  if (page < items.length - 1) {
                    await controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                  } else {
                    await widget.state.finishOnboarding();
                    if (context.mounted) Navigator.of(context).pop();
                  }
                },
                child: Text(page < items.length - 1 ? 'Weiter' : 'AmbientGuard starten'),
              ),
            ]),
          ),
        ),
      );
}
