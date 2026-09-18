import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/finding.dart';
import '../models/room_scan.dart';
import '../state/app_state.dart';
import 'onboarding_screen.dart';
import 'scan_detail_screen.dart';
import 'scan_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.state,
    super.key,
  });

  final AppState state;

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  @override
  void initState() {
    super.initState();

    widget.state.addListener(_refresh);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _showOnboarding(),
    );
  }

  @override
  void dispose() {
    widget.state.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _showOnboarding() async {
    if (widget.state.onboardingComplete || !mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) {
          return OnboardingScreen(
            state: widget.state,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _Dashboard(
        state: widget.state,
        onScan: _startScan,
      ),
      _History(state: widget.state),
      SettingsScreen(state: widget.state),
    ];

    return Scaffold(
      body: SafeArea(
        child: pages[index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() {
            index = value;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(
              Icons.shield_outlined,
            ),
            selectedIcon: const Icon(Icons.shield),
            label: context.tr('overview'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            label: context.tr('history'),
          ),
          NavigationDestination(
            icon: const Icon(
              Icons.settings_outlined,
            ),
            label: context.tr('settings'),
          ),
        ],
      ),
      floatingActionButton: index == 0
          ? FloatingActionButton.extended(
              onPressed: _startScan,
              icon: const Icon(Icons.radar),
              label: Text(
                context.tr('checkRoom'),
              ),
            )
          : null,
    );
  }

  Future<void> _startScan() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return ScanScreen(
            state: widget.state,
          );
        },
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({
    required this.state,
    required this.onScan,
  });

  final AppState state;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final last =
        state.scans.isEmpty ? null : state.scans.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        104,
      ),
      children: [
        Text(
          'AmbientGuard',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          context.tr('tagline'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        _StatusCard(
          scan: last,
          onScan: onScan,
        ),
        const SizedBox(height: 24),
        Text(
          context.tr('howItWorks'),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        _Step(
          icon: Icons.camera_alt_outlined,
          title: context.tr('visualInspection'),
          text: context.tr('visualInspectionText'),
        ),
        _Step(
          icon: Icons.wifi_tethering,
          title: context.tr('radioSignals'),
          text: context.tr('radioSignalsText'),
        ),
        _Step(
          icon: Icons.qr_code_scanner,
          title: context.tr('privacyNotice'),
          text: context.tr('privacyNoticeText'),
        ),
        const SizedBox(height: 16),
        Card(
          color: Theme.of(context)
              .colorScheme
              .secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.tr('roomDisclaimer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.scan,
    required this.onScan,
  });

  final RoomScan? scan;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final color = scan == null
        ? Theme.of(context).colorScheme.primary
        : _riskColor(scan!.overallRisk);

    final title = scan == null
        ? context.tr('noRoomChecked')
        : context.tr(
            'lastRating',
            {'score': scan!.score},
          );

    final subtitle = scan == null
        ? context.tr('startLocalCheck')
        : context.tr(
            'scanSummary',
            {
              'label': scan!.label,
              'count': scan!.findings.length,
            },
          );

    return Card(
      color: color.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              scan == null
                  ? Icons.shield_outlined
                  : Icons.shield,
              size: 42,
              color: color,
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(subtitle),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.radar),
              label: Text(
                context.tr('newRoomCheck'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(text),
      ),
    );
  }
}

class _History extends StatelessWidget {
  const _History({
    required this.state,
  });

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('localLog'),
        ),
      ),
      body: state.scans.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  context.tr('noSavedChecks'),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.scans.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 8);
              },
              itemBuilder: (context, index) {
                final scan = state.scans[index];

                final date =
                    MaterialLocalizations.of(context)
                        .formatCompactDate(
                  scan.createdAt,
                );

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          _riskColor(
                            scan.overallRisk,
                          ).withValues(alpha: 0.15),
                      child: Text('${scan.score}'),
                    ),
                    title: Text(
                      scan.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      '$date · ${context.tr(
                        'savedFindings',
                        {
                          'count':
                              scan.findings.length,
                        },
                      )}',
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) {
                            return ScanDetailScreen(
                              scan: scan,
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

Color _riskColor(RiskLevel risk) {
  return switch (risk) {
    RiskLevel.low => const Color(0xFF16855B),
    RiskLevel.medium => const Color(0xFFE28A08),
    RiskLevel.high => const Color(0xFFD43D3D),
  };
}
