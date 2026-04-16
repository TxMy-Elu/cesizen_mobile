import 'package:flutter/material.dart';

import 'package:cesizen_mobile/app/navigation/app_drawer.dart';
import 'package:cesizen_mobile/core/data/repositories/article_repository.dart';
import 'package:cesizen_mobile/core/data/repositories/auth_repository.dart';
import 'package:cesizen_mobile/core/data/repositories/consultation_repository.dart';
import 'package:cesizen_mobile/core/data/repositories/exercise_repository.dart';
import 'package:cesizen_mobile/core/models/user_session.dart';
import 'package:cesizen_mobile/features/auth/login_screen.dart';
import 'package:cesizen_mobile/features/breathing/breathing_screen.dart';
import 'package:cesizen_mobile/features/home/home_screen.dart';
import 'package:cesizen_mobile/features/prevention/prevention_screen.dart';
import 'package:cesizen_mobile/features/profile/profile_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({
    super.key,
    required this.session,
    required this.authRepository,
    required this.articleRepository,
    required this.exerciseRepository,
    required this.consultationRepository,
  });

  final UserSession session;
  final AuthRepository authRepository;
  final ArticleRepository articleRepository;
  final ExerciseRepository exerciseRepository;
  final ConsultationRepository consultationRepository;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onChangeTab: _setTab),
      BreathingScreen(
        session: widget.session,
        exerciseRepository: widget.exerciseRepository,
      ),
      PreventionScreen(
        session: widget.session,
        articleRepository: widget.articleRepository,
      ),
      ProfileScreen(
        session: widget.session,
        authRepository: widget.authRepository,
        exerciseRepository: widget.exerciseRepository,
        consultationRepository: widget.consultationRepository,
        onSessionChanged: _refresh,
      ),
    ];

    const labels = ['Accueil', 'Respiration', 'Prevention', 'Profil'];

    return Scaffold(
      appBar: AppBar(
        title: Text(labels[_index]),
        actions: [
          IconButton(
            tooltip: 'Connexion',
            onPressed: () => _openLogin(context),
            icon: Icon(
              widget.session.isAuthenticated
                  ? Icons.verified_user_rounded
                  : Icons.login_rounded,
            ),
          ),
        ],
      ),
      drawer: AppDrawer(session: widget.session),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: screens[_index],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _setTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Accueil'),
          NavigationDestination(
            icon: Icon(Icons.air_rounded),
            label: 'Respiration',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Prevention',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  void _setTab(int value) {
    setState(() => _index = value);
  }

  Future<void> _openLogin(BuildContext context) async {
    final wasAuthenticated = widget.session.isAuthenticated;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          session: widget.session,
          authRepository: widget.authRepository,
        ),
      ),
    );
    if (!wasAuthenticated && widget.session.isAuthenticated) {
      _setTab(3);
    }
    _refresh();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }
}
