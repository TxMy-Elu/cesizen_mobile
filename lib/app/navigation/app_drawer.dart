import 'package:flutter/material.dart';

import 'package:cesizen_mobile/core/models/user_session.dart';
import 'package:cesizen_mobile/features/support/contact_page.dart';
import 'package:cesizen_mobile/features/support/info_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.session});

  final UserSession session;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5B7D6A), Color(0xFF3E5B4B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.spa_rounded, color: Colors.white, size: 36),
                const SizedBox(height: 12),
                const Text(
                  'CESIZEN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  session.isAuthenticated
                      ? 'Connecté : ${session.userName}'
                      : 'Mode visiteur anonyme',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.phone_in_talk_rounded),
            title: const Text('Contact et urgence'),
            onTap: () => _openSimplePage(context, const ContactPage()),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_rounded),
            title: const Text('Confidentialité'),
            onTap: () => _openSimplePage(
              context,
              const InfoPage(
                title: 'Confidentialité',
                content:
                    'Le consentement explicite est obligatoire avant toute collecte de données de santé. Les données sensibles sont protégées et supprimées sur demande (droit à l\'oubli).',
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.cookie_rounded),
            title: const Text('Cookies'),
            onTap: () => _openSimplePage(
              context,
              const InfoPage(
                title: 'Cookies',
                content:
                    'Les cookies optionnels ne sont activés qu\'après consentement. Les préférences peuvent être modifiées à tout moment.',
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.accessibility_new_rounded),
            title: const Text('Accessibilité'),
            onTap: () => _openSimplePage(
              context,
              const InfoPage(
                title: 'Accessibilité',
                content:
                    'L\'application respecte des contrastes élevés, des cibles tactiles supérieures à 44 px et des alternatives pour les animations réduites.',
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.help_rounded),
            title: const Text('FAQ'),
            onTap: () => _openSimplePage(
              context,
              const InfoPage(
                title: 'FAQ',
                content:
                    'Cette version mobile couvre les modules citoyens : respiration, prévention, auth, profil et pages légales.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openSimplePage(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}
