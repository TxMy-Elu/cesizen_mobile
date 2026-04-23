# 📋 Vue d'Ensemble - App Mobile CESIZen

## 🎯 Présentation Générale

L'**App Mobile CESIZen** est une application cross-platform développée avec Flutter, dédiée à la promotion de la santé mentale et physique à travers des exercices de respiration guidés et des articles de prévention.

### Objectifs Principaux
- ✅ Fournir des exercices de respiration accessibles
- ✅ Offrir un contenu éducatif sur la prévention santé
- ✅ Suivre la progression utilisateur
- ✅ Assurer une expérience offline-first

## 🛠️ Stack Technologique

| Composant | Technologie | Version | Rôle |
|-----------|-------------|---------|------|
| **Framework** | Flutter | 3.x | UI cross-platform |
| **Langage** | Dart | 3.x | Développement |
| **State Management** | Provider + GetX | - | Gestion d'état |
| **Backend** | Firebase | - | Auth, DB, Storage |
| **Base Locale** | SQLite | - | Stockage offline |
| **HTTP Client** | HTTP/Dio | - | Appels API |
| **Auth** | Firebase Auth | - | Authentification |

## 🏗️ Architecture Générale

### Pattern MVVM (Model-View-ViewModel)
```
lib/
├── main.dart              # Point d'entrée
├── app/                   # Configuration app
├── core/                  # Services partagés
│   ├── config/           # Configuration
│   ├── data/             # Repositories
│   ├── models/           # DTOs & Entities
│   ├── network/          # API clients
│   ├── theme/            # Thèmes UI
│   └── widgets/          # Composants réutilisables
└── features/             # Fonctionnalités métier
    ├── auth/             # Authentification
    ├── breathing/        # Exercices respiration
    ├── home/             # Dashboard
    ├── prevention/       # Articles prévention
    ├── profile/          # Profil utilisateur
    └── support/          # Support & aide
```

### Flux de Données
1. **View** → Déclenche actions utilisateur
2. **ViewModel** → Gère logique métier, appels API
3. **Model** → Structures de données
4. **Repository** → Abstraction données (API + Local)

## 📊 Modèle de Données

### Utilisateur (User)
```dart
class User {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;
  final UserPreferences preferences;
  final List<ExerciseProgress> progress;
}
```

### Article (Article)
```dart
class Article {
  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime publishedAt;
  final bool isRead;
}
```

### Exercice (Exercise)
```dart
class Exercise {
  final String id;
  final String name;
  final String description;
  final Duration duration;
  final List<Step> steps;
  final Difficulty difficulty;
}
```

### Progression (Progress)
```dart
class ExerciseProgress {
  final String exerciseId;
  final DateTime completedAt;
  final Duration actualDuration;
  final int sessionsCount;
}
```

## 🔄 États de l'Application

### États Globaux
- **AuthState**: Connecté/Déconnecté
- **ThemeState**: Clair/Sombre
- **NetworkState**: Online/Offline
- **LoadingState**: Chargement en cours

### États Locaux par Écran
- **ArticleListState**: Liste filtrée/triée
- **ExerciseState**: En cours/Pause/Terminé
- **ProfileState**: Édition/Sauvegarde

## 🌐 Intégrations Externes

### Firebase
- **Authentication**: Login social + email/password
- **Firestore**: Données utilisateurs synchronisées
- **Storage**: Images articles/exercices
- **Analytics**: Suivi utilisation
- **Crashlytics**: Rapports d'erreur

### API REST
- **Base URL**: `https://api.cesizen.com/v1`
- **Auth**: Bearer token JWT
- **Format**: JSON
- **Rate Limit**: 1000 req/h

## 📱 Fonctionnalités Clés

### 1️⃣ Authentification
- Login/Register avec validation
- Biométrie (Face ID/Touch ID)
- Refresh token automatique
- Déconnexion sécurisée

### 2️⃣ Exercices de Respiration
- Mode guidé avec minuteur
- Suivi progression
- Exercices personnalisés
- Mode hors-ligne

### 3️⃣ Articles & Prévention
- Recherche et filtres
- Lecture hors-ligne
- Favoris et historique
- Notifications push

### 4️⃣ Dashboard Personnel
- Statistiques progression
- Graphiques évolution
- Rappels personnalisés
- Récompenses

## 🔒 Sécurité & Confidentialité

### Stockage Sécurisé
- **Tokens JWT**: Secure Storage
- **Données sensibles**: Chiffrement AES
- **Biométrie**: Keychain/iOS, Keystore/Android

### Permissions
- **Caméra**: Photos profil
- **Localisation**: Non utilisée
- **Notifications**: Rappels exercices
- **Stockage**: Sauvegarde offline

## 📈 Performance & Optimisation

### Métriques Cibles
- **Temps de démarrage**: < 2s
- **Taille APK**: < 50MB
- **Batterie**: Optimisé pour usage quotidien
- **Mémoire**: < 100MB en usage normal

### Optimisations
- **Lazy Loading**: Écrans et données
- **Caching**: Images et API responses
- **Background Tasks**: Sync hors-ligne
- **Bundle Splitting**: Code splitting

## 🧪 Testing Strategy

### Tests Unitaires
- Models et ViewModels
- Services et repositories
- Utilitaires et helpers

### Tests d'Intégration
- Flux authentification
- Appels API
- Navigation

### Tests UI (Widget)
- Écrans principaux
- Composants réutilisables
- États d'erreur

## 🚀 Roadmap & Évolutions

### Version 1.1
- Mode sombre complet
- Exercices audio
- Partage social

### Version 1.2
- Wear OS support
- Mode famille
- Intégration santé Apple/Google

---

*Dernière mise à jour: 21 avril 2026*
