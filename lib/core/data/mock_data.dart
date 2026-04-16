import 'package:cesizen_mobile/core/models/article.dart';
import 'package:cesizen_mobile/core/models/article_view_record.dart';
import 'package:cesizen_mobile/core/models/breathing_preset.dart';
import 'package:cesizen_mobile/core/models/breathing_session_record.dart';
import 'package:cesizen_mobile/core/models/fake_user.dart';
import 'package:cesizen_mobile/core/models/resource_item.dart';

class MockData {
  static const demoPassword = 'Cesizen123!';

  static const users = [
    FakeUser(
      id: 'usr_001',
      role: 'UTILISATEUR',
      firstName: 'Lea',
      lastName: 'Martin',
      email: 'lea.martin@example.test',
      createdAt: '2026-03-02T09:15:00Z',
      rgpdConsent: true,
      accountStatus: 'ACTIF',
      preferences: UserPreferences(
        defaultDurationMin: 5,
        rhythm: '5-5',
        haptics: true,
        zenTheme: true,
      ),
    ),
    FakeUser(
      id: 'usr_002',
      role: 'UTILISATEUR',
      firstName: 'Yanis',
      lastName: 'Petit',
      email: 'yanis.petit@example.test',
      createdAt: '2026-02-18T14:42:00Z',
      rgpdConsent: true,
      accountStatus: 'ACTIF',
      preferences: UserPreferences(
        defaultDurationMin: 3,
        rhythm: '4-6',
        haptics: false,
        zenTheme: true,
      ),
    ),
  ];

  static const presets = [
    BreathingPreset(
      name: 'Apaisement standard',
      pattern: '5-5',
      defaultDurationMin: 5,
      hapticsRecommended: true,
    ),
    BreathingPreset(
      name: 'Ancrage rapide',
      pattern: '4-6',
      defaultDurationMin: 3,
      hapticsRecommended: false,
    ),
    BreathingPreset(
      name: 'Session longue',
      pattern: '5-5',
      defaultDurationMin: 10,
      hapticsRecommended: true,
    ),
  ];

  static const sessions = [
    BreathingSessionRecord(
      id: 'ses_1001',
      mode: 'CONNECTE',
      userId: 'usr_001',
      startedAt: '2026-04-10T07:30:00Z',
      durationMin: 5,
      pattern: '5-5',
      haptics: true,
      source: 'RESPIRATION_PAGE',
      completed: true,
    ),
    BreathingSessionRecord(
      id: 'ses_1002',
      mode: 'CONNECTE',
      userId: 'usr_002',
      startedAt: '2026-04-10T18:10:00Z',
      durationMin: 10,
      pattern: '4-6',
      haptics: false,
      source: 'RESPIRATION_PAGE',
      completed: true,
    ),
    BreathingSessionRecord(
      id: 'ses_1003',
      mode: 'ANONYME',
      userId: null,
      startedAt: '2026-04-11T12:03:00Z',
      durationMin: 3,
      pattern: '5-5',
      haptics: false,
      source: 'HOME_URGENCE',
      completed: true,
      note: 'RG-PRIV-01: pas de persistance serveur',
    ),
    BreathingSessionRecord(
      id: 'ses_1004',
      mode: 'ANONYME',
      userId: null,
      startedAt: '2026-04-11T22:40:00Z',
      durationMin: 5,
      pattern: '5-5',
      haptics: true,
      source: 'HOME_URGENCE',
      completed: false,
      note: 'Session interrompue hors-ligne',
    ),
  ];

  static const categories = ['Stress', 'Sommeil', 'Angoisse au travail'];

  static const articles = [
    Article(
      id: 'art_201',
      slug: 'respirer-pendant-une-crise',
      title: 'Respirer pendant une crise d angoisse',
      category: 'Stress',
      summary: 'Technique simple en 3 minutes pour reduire la montee d anxiete.',
      markdownContent:
          '## Etapes\n1. Inspire 5s\n2. Expire 5s\n3. Repete 3 minutes',
      status: 'PUBLIE',
      isValidatedByHealthPro: true,
      updatedAt: '2026-04-01T10:00:00Z',
    ),
    Article(
      id: 'art_202',
      slug: 'sommeil-et-routine-apaisante',
      title: 'Sommeil: creer une routine apaisante',
      category: 'Sommeil',
      summary: 'Checklist de 5 habitudes pour mieux dormir.',
      markdownContent:
          '## Routine\n- Lumiere douce\n- Pas d ecran 30 min avant\n- Respiration 5 min',
      status: 'PUBLIE',
      isValidatedByHealthPro: true,
      updatedAt: '2026-03-26T16:20:00Z',
    ),
    Article(
      id: 'art_203',
      slug: 'angoisse-au-travail-signaux',
      title: 'Angoisse au travail: reconnaitre les signaux',
      category: 'Angoisse au travail',
      summary: 'Identifier les premiers signaux et agir tot.',
      markdownContent:
          '## Signaux\n- Tension\n- Ruminations\n- Fatigue\n\n## Action\n- Pause + respiration',
      status: 'BROUILLON',
      isValidatedByHealthPro: true,
      updatedAt: '2026-04-12T09:05:00Z',
    ),
  ];

  static const resources = [
    ResourceItem(
      id: 'res_301',
      title: 'Fiche respiration 5-5',
      type: 'PDF',
      fileName: 'fiche-respiration-5-5.pdf',
      sizeKb: 420,
      category: 'Stress',
      status: 'PUBLIE',
      updatedAt: '2026-04-08T11:30:00Z',
    ),
    ResourceItem(
      id: 'res_302',
      title: 'Audio guide anti-panique 3 min',
      type: 'AUDIO',
      fileName: 'audio-anti-panique-3min.mp3',
      sizeKb: 3580,
      category: 'Urgence',
      status: 'PUBLIE',
      updatedAt: '2026-04-07T08:55:00Z',
    ),
    ResourceItem(
      id: 'res_303',
      title: 'Guide sommeil - version courte',
      type: 'PDF',
      fileName: 'guide-sommeil-court.pdf',
      sizeKb: 760,
      category: 'Sommeil',
      status: 'ARCHIVE',
      updatedAt: '2026-03-14T13:10:00Z',
    ),
  ];

  static const articleViews = [
    ArticleViewRecord(
      id: 'cons_001',
      userId: 'usr_001',
      articleId: 'art_201',
      viewedAt: '2026-04-12T09:00:00Z',
    ),
    ArticleViewRecord(
      id: 'cons_002',
      userId: 'usr_001',
      articleId: 'art_202',
      viewedAt: '2026-04-11T20:00:00Z',
    ),
    ArticleViewRecord(
      id: 'cons_003',
      userId: 'usr_001',
      articleId: 'art_201',
      viewedAt: '2026-04-10T09:30:00Z',
    ),
    ArticleViewRecord(
      id: 'cons_004',
      userId: 'usr_001',
      articleId: 'art_202',
      viewedAt: '2026-04-08T18:15:00Z',
    ),
    ArticleViewRecord(
      id: 'cons_005',
      userId: 'usr_002',
      articleId: 'art_201',
      viewedAt: '2026-04-05T14:45:00Z',
    ),
  ];

  static FakeUser? findUserByEmail(String email) {
    final lower = email.toLowerCase();
    for (final user in users) {
      if (user.email.toLowerCase() == lower) {
        return user;
      }
    }
    return null;
  }

  static List<Article> get publicArticles =>
      articles.where((article) => article.isPublished).toList();

  static List<BreathingSessionRecord> sessionsByUser(String userId) =>
      sessions.where((session) => session.userId == userId).toList();

    static List<ArticleViewRecord> articleViewsByUser(String userId) =>
      articleViews.where((item) => item.userId == userId).toList();
}
