# 🧪 Prompt de Génération de Cahier de Recettes - Tests Fonctionnels

## 📋 PROMPT RÉUTILISABLE - Copier/Coller

Utilisez ce prompt pour générer un cahier de recettes complet pour n'importe quelle application. Adaptez simplement les variables entre `{}`.

---

```
Tu es un expert QA spécialisé dans la création de cahiers de recettes professionnels.
Je veux que tu crées un CAHIER DE RECETTES COMPLET ET STRUCTURÉ pour mon application.

## 📌 CONTEXTE DE L'APPLICATION

**Nom de l'Application:** {NOM_APPLICATION}
**Type:** {TYPE: Application Web / Application Mobile / API REST / PWA}
**Platform:** {PLATFORMS: Web / iOS / Android / Cross-platform}
**Stack Technologique:** {TECHNOLOGIES}
**Objectif Principal:** {DESCRIPTION_COURTE}

## 👥 COMPTES DE TEST

Fournir les comptes de test avec leurs rôles:
- Admin: {EMAIL_ADMIN} / {PASSWORD_ADMIN} (ROLE_ADMIN)
- User Standard: {EMAIL_USER} / {PASSWORD_USER} (ROLE_USER)
- {AUTRES_ROLES_SI_APPLICABLE}

## 📊 STRUCTURE À CRÉER

Je veux UN fichier Markdown complet avec:

### 1️⃣ EN-TÊTE PROFESSIONNEL (5-10 lignes)
- Titre: "📋 Cahier de Recettes - Tests Fonctionnels {NOM_APPLICATION}"
- Date de création, version, auteur
- Objectif et scope
- Plateforme testée

### 2️⃣ TABLE DES MATIÈRES (Automatique)
- Liens hypertexte vers toutes les sections
- Profondeur: H1, H2, H3

### 3️⃣ INTRODUCTION (15-20 lignes)
- Contexte des tests
- Format de chaque test
- Nomenclature des IDs
- Durée estimée par test

### 4️⃣ PRÉREQUIS GÉNÉRAUX (20-30 lignes)
- Environnement requis (émulateur, appareil, navigateur)
- Version minimale de l'app
- **TOUS les comptes de test fournis**
- Permissions/configurations nécessaires
- Données d'exemple requises
- Outils recommandés (screenshots, logs, etc.)

### 5️⃣ TESTS PAR FONCTIONNALITÉ (CŒUR DU DOCUMENT)

Pour chaque fonctionnalité majeure de l'app, créer une SECTION avec:

#### Structure de chaque test:
```
#### TEST-XXX : Titre du Test
- **Objectif** : Décrire en 1 phrase ce qu'on teste
- **Prérequis** : Conditions avant de démarrer
- **Données de Test** : Comptes/données spécifiques à utiliser
- **Étapes** : Numéroter les actions (minimum 3-5 étapes)
- **Résultats Attendus** : Comportements corrects attendus
- **Critères de Succès** : Conditions pour valider le test
- **Observations** : Points spécifiques à vérifier
```

#### Les sections de fonctionnalités:
Pour CHAQUE fonctionnalité majeure de l'app:
- Créer une section H3
- Inclure {NB_TESTS} tests minimum
- Couvrir: cas nominal + cas d'erreur + cas limites

**Exemples pour une app mobile:**
- Authentification (login, register, forgot password, 2FA)
- Navigation (menu, écrans, routage)
- Listing/Recherche (filtres, pagination, tri)
- Création/Édition (formulaires, validation)
- Suppression (confirmations, cascades)
- Push notifications
- Offline/Mode hors ligne
- Partage et export
- Permissions

### 6️⃣ TESTS NON-FONCTIONNELS (3-5 tests)

- Performance (temps de chargement)
- Mode hors ligne / Cache
- Responsive design / Orientations
- Gestion batterie
- Accessibilité
- Sécurité (session, stockage, données sensibles)

### 7️⃣ MODÈLE DE RAPPORT DE TEST (10-15 lignes)

Template à remplir après exécution:
```
- Date/Heure: [YYYY-MM-DD HH:mm]
- Testeur: [Nom]
- Environnement: [Appareil/Navigateur - Version OS - Version App]
- Résultats: [✅ Réussi / ❌ Échoué / ⚠️ Anomalie]
- Détails: [Description du problème si applicable]
- Screenshots: [Liens ou descriptions]
- Temps total: [XXX minutes]
```

### 8️⃣ MÉTRIQUES ET KPIs (5-10 lignes)

- Taux de réussite (% tests passés)
- Bugs découverts (nombre et sévérité)
- Temps moyen par test
- Couverture fonctionnelle (%)
- Temps total de test

## 📊 QUALITÉ REQUISE

✅ **Professionnalisme:**
- Emojis pour identifier les sections
- Formatage Markdown cohérent
- Tables pour résumés
- Listes numérotées et à puces
- Code inline pour valeurs/données
- Liens internes cohérents

✅ **Complétude:**
- Minimum {NB_TESTS_MIN} tests (25-40 typiquement)
- Tous les scénarios critiques couverts
- Cas nominaux + cas d'erreur + cas limites
- Tous les rôles/permissions testés
- Cas d'accès refusé vérifiés

✅ **Clarté:**
- Étapes simples et précises
- Vocabulaire cohérent
- Aucune ambiguïté
- Prêt pour testeur non-tech

✅ **Maintenabilité:**
- IDs de test uniques (TEST-001, TEST-002, etc.)
- Facile d'ajouter/modifier tests
- Sections bien séparées
- Notes de mise à jour

## 🔍 CONTENU SPÉCIFIQUE

**Pour CHAQUE test:**
1. ✓ ID unique (TEST-XXX)
2. ✓ Titre descriptif
3. ✓ Objectif en 1 phrase
4. ✓ Prérequis explicites
5. ✓ 3-7 étapes numérotées
6. ✓ Résultats attendus clairs
7. ✓ Critères de succès mesurables
8. ✓ Données de test (comptes, valeurs)

**Cas d'erreur à couvrir:**
- Accès non authentifié
- Permission insuffisante (RBAC)
- Données invalides
- Champs obligatoires manquants
- Format incorrect
- Limite dépassée (max items, file size)
- Ressource non trouvée

**Cas limites à couvrir:**
- Première utilisation
- État limite (0 items, max items)
- Réseau lent/offline
- Timeout
- Changement de rôle/permission

## 📱 CONTEXTE {NOM_APPLICATION}

Spécificités à couvrir:
- {SPECIFICITE_1}
- {SPECIFICITE_2}
- {SPECIFICITE_3}
- Tous les écrans/pages de l'app
- Tous les flux utilisateur critiques

## 🎨 FORMAT & STYLE

- Titre principal: H1 avec emoji
- Sections: H2 avec emoji
- Fonctionnalités: H3
- Tests: H4
- Code inline: backticks
- Champs clés: **gras**
- URLs: [texte](url)
- Listes: - ou 1. selon contexte

## 📝 COMPTES DE DÉMO À INCLURE

Utiliser ABSOLUMENT:
- Admin: {EMAIL_ADMIN} / {PASSWORD_ADMIN} (ROLE_ADMIN)
- User: {EMAIL_USER} / {PASSWORD_USER} (ROLE_USER)
- {AUTRES_COMPTES_SI_APPLICABLE}

## 🚀 INSTRUCTIONS FINALES

1. **Créer UN fichier Markdown** complet et autonome
2. **Nommer:** `15-test-cases.md` ou `tests-cahier-recettes.md`
3. **Inclure:** Table des matières au début
4. **Utiliser:** Français pour toute la documentation
5. **Valider:** Tous les liens hypertexte fonctionnent
6. **Afficher résumé:** Statistiques finales (nb tests, couverture, etc.)

Commence par:
1. Lister TOUTES les fonctionnalités à tester
2. Identifier les écrans/pages
3. Identifier les flux critiques
4. Identifier les rôles/permissions

Puis crée le cahier en:
1. Section par fonctionnalité majeure
2. 3-5 tests par section
3. Format cohérent pour chaque test
```

---

## 📋 VARIABLES À ADAPTER

Remplacez les `{VARIABLES}` par vos informations réelles:

| Variable | Exemple |
|----------|---------|
| `{NOM_APPLICATION}` | "App Mobile CESIZen" |
| `{TYPE}` | "Application Mobile Cross-platform" |
| `{PLATFORMS}` | "iOS, Android" |
| `{TECHNOLOGIES}` | "Flutter, Dart, Firebase" |
| `{DESCRIPTION_COURTE}` | "App de respiration et exercices de bien-être" |
| `{EMAIL_ADMIN}` | "admin@cesizen.fr" ✅ |
| `{PASSWORD_ADMIN}` | "password" ✅ |
| `{EMAIL_USER}` | "user@cesizen.fr" ✅ |
| `{PASSWORD_USER}` | "password" ✅ |
| `{NB_TESTS}` | "3-5" |
| `{NB_TESTS_MIN}` | "30" |

---

## 🎯 EXEMPLE D'UTILISATION POUR CESIZen MOBILE

```
Nom de l'Application: App Mobile CESIZen
Type: Application Mobile Cross-platform
Platform: iOS, Android
Stack: Flutter, Dart, Provider, Firebase
Objectif: Plateforme mobile d'articles et exercices de respiration

Comptes de test:
- Admin: admin@cesizen.fr / password (ROLE_ADMIN)
- User: user@cesizen.fr / password (ROLE_USER)

Fonctionnalités à tester:
- Authentification (login, register, 2FA)
- Splash Screen & Onboarding
- Articles (liste, recherche, détail, favoris)
- Catégories (navigation, filtres)
- Exercices (timer, mode guidé, tracking)
- Tableau de bord (stats, historique)
- Profil & Paramètres
- Notifications push
- Mode offline
```

---

## ✨ OPTIMISATIONS PAR TYPE D'APP

### Pour Application Web
```
Ajouter tests spécifiques:
- Responsive design (desktop, tablet, mobile)
- Navigateurs (Chrome, Firefox, Safari, Edge)
- SEO et métadonnées
- Accessibilité (WCAG)
- Sessions et cookies
```

### Pour Application Mobile
```
Ajouter tests spécifiques:
- Orientations (portrait, paysage)
- Appareil (émulateur, device physique)
- Permissions (caméra, localisation, etc.)
- Batterie et consommation
- Mode offline et sync
- Push notifications
- Keyboard et input
```

### Pour API REST
```
Ajouter tests spécifiques:
- Authentification (JWT, OAuth)
- RBAC et autorisations
- Rate limiting
- Validation des inputs
- Codes HTTP (200, 400, 401, 403, 404, 500)
- Pagination et filtrage
- Transactions et rollback
```

---

## 📊 RÉSULTAT ATTENDU

À la fin, vous aurez:
- ✅ 1 fichier Markdown complet et professionnel
- ✅ 25-40 tests détaillés et structurés
- ✅ Table des matières avec liens
- ✅ Tous les scénarios critiques couverts
- ✅ Tous les comptes de test documentés
- ✅ Prêt à être utilisé par l'équipe QA
- ✅ Facile à maintenir et mettre à jour

---

## 🔄 PROCESSUS DE MAINTENANCE

1. **Mise à jour** : Revoir après chaque release
2. **Feedback** : Collectez les commentaires de l'équipe QA
3. **Versionning** : Incrémentez la version à chaque changement
4. **Archivage** : Gardez historique des versions
5. **Automatisation** : Intégrez avec vos outils QA

---

## 📞 CONSEILS PRO

1. **Testabilité** - Écrire des tests exécutables par n'importe qui
2. **Complétude** - Ne pas oublier les cas d'erreur et limites
3. **Clarté** - Éviter ambiguïtés, soyez précis
4. **Maintenabilité** - Structure facile à naviguer
5. **Évolution** - Prévoir les nouvelles fonctionnalités futures

---

**Dernière mise à jour**: 2026-04-22  
**Format**: Réutilisable pour toute application

