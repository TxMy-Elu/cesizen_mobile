import 'package:flutter/material.dart';

import 'package:cesizen_mobile/app/navigation/root_shell.dart';
import 'package:cesizen_mobile/core/data/repositories/article_repository.dart';
import 'package:cesizen_mobile/core/data/repositories/auth_repository.dart';
import 'package:cesizen_mobile/core/data/repositories/consultation_repository.dart';
import 'package:cesizen_mobile/core/data/repositories/exercise_repository.dart';
import 'package:cesizen_mobile/core/network/api_client.dart';
import 'package:cesizen_mobile/core/models/user_session.dart';
import 'package:cesizen_mobile/core/theme/app_theme.dart';

class CesizenApp extends StatefulWidget {
  const CesizenApp({super.key});

  @override
  State<CesizenApp> createState() => _CesizenAppState();
}

class _CesizenAppState extends State<CesizenApp> {
  final UserSession _session = UserSession();
  late final ApiClient _apiClient;
  late final AuthRepository _authRepository;
  late final ArticleRepository _articleRepository;
  late final ExerciseRepository _exerciseRepository;
  late final ConsultationRepository _consultationRepository;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _authRepository = AuthRepository(_apiClient);
    _articleRepository = ArticleRepository(_apiClient);
    _exerciseRepository = ExerciseRepository(_apiClient);
    _consultationRepository = ConsultationRepository(_apiClient);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CESIZEN',
      debugShowCheckedModeBanner: false,
      theme: buildCesizenTheme(),
      home: RootShell(
        session: _session,
        authRepository: _authRepository,
        articleRepository: _articleRepository,
        exerciseRepository: _exerciseRepository,
        consultationRepository: _consultationRepository,
      ),
    );
  }
}
