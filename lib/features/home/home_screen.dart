import 'package:flutter/material.dart';

import 'package:cesizen_mobile/core/widgets/cesizen_cards.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onChangeTab});

  final ValueChanged<int> onChangeTab;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        HeroCard(
          title: 'Besoin d\'apaiser une crise maintenant ?',
          subtitle:
              'Accède rapidement au module de respiration guidée ou contacte les services d\'urgence.',
          actions: [
            FilledButton.icon(
              onPressed: () => onChangeTab(1),
              icon: const Icon(Icons.air_rounded),
              label: const Text('Lancer respiration'),
            ),
            OutlinedButton.icon(
              onPressed: () => _showEmergencySheet(context),
              icon: const Icon(Icons.warning_amber_rounded),
              label: const Text('Numéros d\'urgence'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SectionCard(
          icon: Icons.shield_rounded,
          title: 'Anonymat visiteur',
          content:
              'Sans connexion, l\'application fonctionne sans suivi personnel en backend.',
        ),
        const SizedBox(height: 12),
        const SectionCard(
          icon: Icons.lock_rounded,
          title: 'Confidentialité RGPD',
          content:
              'Consentement explicite, sécurité JWT et droit à l\'oubli font partie des règles du produit.',
        ),
      ],
    );
  }

  void _showEmergencySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Urgence immédiate',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12),
            ListTile(leading: Icon(Icons.local_hospital), title: Text('15 - SAMU')),
            ListTile(leading: Icon(Icons.call), title: Text('112 - Urgences Europe')),
            ListTile(
              leading: Icon(Icons.support_agent),
              title: Text('3114 - Prévention du suicide'),
            ),
          ],
        ),
      ),
    );
  }
}
