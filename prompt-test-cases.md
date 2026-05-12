# 🚀 Prompt de Génération - Cahier de Recettes Tests Fonctionnels

**Date de création**: 2026-04-22  
**Version**: 1.0  
**Application cible**: App all CESIZen  
**Objectif**: Générer automatiquement un cahier de recettes complet pour les tests fonctionnels.

---

## 📋 PROMPT RÉUTILISABLE - Copier/Coller

Utilisez ce prompt pour générer un cahier de recettes de tests pour n'importe quelle application mobile. Adaptez simplement les variables entre `{}`.

---

```
Tu es un expert en assurance qualité et tests logiciels, spécialisé dans les applications mobiles Flutter/Dart. Je veux que tu crées un CAHIER DE RECETTES COMPLET pour tester chaque fonctionnalité de mon application mobile.

## 📌 CONTEXTE DE L'APPLICATION

**Nom de l'App**: {NOM_APP}
**Type**: Application Mobile Cross-platform
**Stack Technologique**: {TECHNOLOGIES} (ex: Flutter, Dart, Provider, Firebase)
**Objectif Principal**: {DESCRIPTION_COURTE}
**Fonctionnalités Majeures**:
- {FONCTIONNALITE_1} (ex: Authentification)
- {FONCTIONNALITE_2} (ex: Articles)
- {FONCTIONNALITE_3} (ex: Exercices)
- {FONCTIONNALITE_4} (ex: Profil)
- {FONCTIONNALITE_5} (ex: Dashboard)
- {AUTRES_FONCTIONNALITES}

## 🎯 STRUCTURE DU CAHIER À CRÉER

Crée un document Markdown structuré avec exactement cette organisation:

### 1. En-tête du Document
- Titre professionnel
- Métadonnées (date, version, auteur)
- Table des matières

### 2. Introduction
- Explication du format des tests
- Méthodologie (tests manuels sur émulateur/appareil)

### 3. Prérequis Généraux
- Environnements de test
- Comptes de test (3-5 comptes avec rôles différents)
- Permissions requises
- Données d'exemple

### 4. Tests par Fonctionnalité
Pour CHAQUE fonctionnalité majeure, créer 3-5 tests avec ce format:

#### TEST-XXX : Titre du Test
- **Objectif** : But précis du test
- **Prérequis** : Conditions nécessaires
- **Étapes** : Liste numérotée des actions
- **Résultats Attendus** : Comportements corrects détaillés
- **Critères de Succès** : Conditions de validation
- **Données de Test** : Comptes/données spécifiques (si applicable)

### 5. Tests Non-Fonctionnels
- Performance (chargement < 3s)
- Mode hors ligne
- Responsive design
- Gestion batterie/ressources

### 6. Rapport de Test
- Modèle de rapport d'exécution
- Métriques à suivre (taux réussite, temps, bugs)

## 📊 QUALITÉ REQUISE

✅ **Couverture Complète**:
- Minimum 25-35 tests fonctionnels
- Toutes les fonctionnalités couvertes
- Scénarios positifs ET négatifs
- Cas d'erreur et edge cases

✅ **Détail Professionnel**:
- ID unique pour chaque test (TEST-001, TEST-002...)
- Étapes claires et reproductibles
- Résultats attendus spécifiques
- Critères de succès mesurables

✅ **Praticabilité**:
- Tests exécutables manuellement
- Temps estimé par test (< 5 minutes)
- Données de test réalistes
- Environnements accessibles

✅ **Maintenabilité**:
- Structure modulaire par fonctionnalité
- Facile à mettre à jour
- Liens entre tests si dépendances
- Versionnage indiqué

## 🔧 SPÉCIFICITÉS MOBILES REQUISES

Pour chaque test, considérer:
- ✅ Gestion du clavier (show/hide)
- ✅ Permissions (caméra, stockage, notifications)
- ✅ Orientation écran (portrait/landscape)
- ✅ Connexion réseau (online/offline)
- ✅ Stockage local (persistence données)
- ✅ Notifications push
- ✅ Biométrie (si applicable)

## 📝 DONNÉES DE TEST

Inclure:
- Comptes utilisateur: standard, premium, admin
- Données d'exemple: articles, exercices, catégories
- Scénarios d'erreur: réseau coupé, permissions refusées
- Edge cases: données vides, caractères spéciaux

## 🚀 INSTRUCTIONS FINALES

1. **Générer le document complet** en français
2. **Utiliser le format Markdown** avec emojis et tableaux
3. **Numéroter les tests séquentiellement** (TEST-001 à TEST-035+)
4. **Ajouter une table des matières** avec ancres
5. **Inclure des métadonnées** (date, version, auteur)
6. **Terminer par une section Support/Maintenance**

Commence par créer le document avec tous les tests détaillés.
```

---

## 📋 VARIABLES À ADAPTER

Pour adapter ce prompt à votre application, remplacez:

| Variable | Exemple pour CESIZen |
|----------|---------------------|
| `{NOM_APP}` | "CESIZen Mobile" |
| `{TECHNOLOGIES}` | "Flutter, Dart, Provider, Firebase, SQLite" |
| `{DESCRIPTION_COURTE}` | "Application mobile pour exercices respiration et articles" |
| `{FONCTIONNALITE_1}` | "Authentification (login/register/biometrie)" |
| `{FONCTIONNALITE_2}` | "Articles (liste, recherche, detail, tracking)" |
| `{FONCTIONNALITE_3}` | "Exercices (liste, minuteur, mode guide, tracking)" |
| `{FONCTIONNALITE_4}` | "Categories (navigation, filtres)" |
| `{FONCTIONNALITE_5}` | "Tableau de bord (stats, historique, graphiques)" |

---

## 🎯 EXEMPLE D'UTILISATION

**Pour une app e-commerce mobile:**

```
Nom de l'App: ShopMobile
Technologies: React Native, Redux, Node.js
Description: Application mobile de e-commerce
Fonctionnalités:
- Authentification
- Catalogue produits
- Panier/Commandes
- Profil client
- Paiement
```

**Pour une app fitness:**

```
Nom de l'App: FitTracker
Technologies: Flutter, Firebase, Health Kit
Description: Suivi d'activités sportives
Fonctionnalités:
- Authentification
- Enregistrement séances
- Statistiques
- Challenges
- Profil
```

---

## ✨ OPTIMISATIONS POSSIBLES

### Pour Apps Complexes
- Ajouter des tests d'intégration (API calls)
- Inclure des tests de sécurité (JWT, données sensibles)
- Tests de performance (mémoire, CPU)
- Tests d'accessibilité (screen readers, contrastes)

### Pour Équipes QA
- Ajouter des colonnes "Priorité" et "Sévérité"
- Inclure des captures d'écran attendues
- Définir des seuils d'acceptation
- Intégrer avec outils de bug tracking

---

## 📞 CONSEILS PRO

1. **Réutilisez ce prompt** pour toutes vos apps mobiles
2. **Adaptez les fonctionnalités** selon votre domaine métier
3. **Maintenez à jour** les comptes de test
4. **Automatisez** les tests récurrents une fois stabilisés
5. **Collectez feedback** des testeurs pour améliorer

---

**Dernière mise à jour**: 2026-04-22  
**Format**: Réutilisable pour tout projet mobile  
**Résultat attendu**: Cahier de recettes professionnel avec 30+ tests détaillés</content>
<parameter name="filePath">C:\Users\Elio\Documents\GitHub\cesizen_mobile\docs\prompt-test-cases.md
