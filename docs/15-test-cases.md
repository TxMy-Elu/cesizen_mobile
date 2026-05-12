# 📋 Cahier de Recettes - Tests Fonctionnels App Mobile CESIZen

**Date de création**: 2026-04-22  
**Version**: 1.0  
**Auteur**: Documentation Automatisée  
**Application**: CESIZen Mobile (Flutter)  
**Objectif**: Fournir un guide complet pour tester chaque fonctionnalité de l'application mobile CESIZen.

---

## 📖 Table des Matières

1. [Introduction](#introduction)
2. [Prérequis Généraux](#prérequis-généraux)
3. [Tests par Fonctionnalité](#tests-par-fonctionnalité)
   - [Splash Screen & Onboarding](#splash-screen--onboarding)
   - [Authentification](#authentification)
   - [Articles](#articles)
   - [Catégories](#catégories)
   - [Exercices](#exercices)
   - [Tableau de Bord](#tableau-de-bord)
   - [Profil & Paramètres](#profil--paramètres)
4. [Tests Non-Fonctionnels](#tests-non-fonctionnels)
5. [Rapport de Test](#rapport-de-test)

---

## 🎯 Introduction

Ce cahier de recettes détaille les procédures de test pour chaque fonctionnalité majeure de l'application mobile CESIZen. Chaque test est structuré selon le format suivant :

- **ID Test** : Identifiant unique
- **Titre** : Description courte
- **Objectif** : But du test
- **Prérequis** : Conditions nécessaires
- **Étapes** : Actions à effectuer
- **Résultats Attendus** : Comportement correct
- **Critères de Succès** : Conditions de validation
- **Données de Test** : Comptes/données à utiliser

Les tests sont conçus pour être exécutés manuellement sur un émulateur ou appareil réel.

---

## 🔧 Prérequis Généraux

- **Environnement** : Émulateur Android/iOS ou appareil physique
- **Version App** : Dernière build de développement
- **Comptes de Test** :
  - Administrateur : `admin@cesizen.fr` / `password` (ROLE_ADMIN) ✅
  - Utilisateur standard : `user@cesizen.fr` / `password` (ROLE_USER) ✅
- **Connexion** : WiFi stable pour tests en ligne
- **Permissions** : Caméra, stockage, notifications activées
- **Données** : Base de données avec articles et exercices d'exemple

---

## 🧪 Tests par Fonctionnalité

### Splash Screen & Onboarding

#### TEST-001 : Affichage Splash Screen
- **Objectif** : Vérifier l'affichage correct du splash screen au lancement
- **Prérequis** : App non installée ou données effacées
- **Étapes** :
  1. Lancer l'application
  2. Observer l'écran de démarrage
- **Résultats Attendus** :
  - Logo CESIZen affiché
  - Animation fluide (2-3 secondes)
  - Transition automatique vers onboarding
- **Critères de Succès** : Splash visible et transition sans erreur

#### TEST-002 : Parcours Onboarding Complet
- **Objectif** : Tester le flux d'introduction pour nouveaux utilisateurs
- **Prérequis** : Première utilisation ou données reset
- **Étapes** :
  1. Lancer l'app après splash
  2. Naviguer à travers les écrans d'onboarding (3-5 écrans)
  3. Terminer l'onboarding
- **Résultats Attendus** :
  - Contenu informatif affiché
  - Boutons "Suivant" et "Passer" fonctionnels
  - Redirection vers écran d'authentification
- **Critères de Succès** : Onboarding complété sans blocage

#### TEST-003 : Skip Onboarding
- **Objectif** : Vérifier la possibilité de sauter l'onboarding
- **Prérequis** : Première utilisation
- **Étapes** :
  1. Démarrer l'onboarding
  2. Cliquer sur "Passer"
- **Résultats Attendus** : Redirection directe vers authentification
- **Critères de Succès** : Navigation fluide

---

### Authentification

#### TEST-004 : Inscription Utilisateur
- **Objectif** : Tester la création d'un nouveau compte
- **Prérequis** : Accès à l'écran d'inscription
- **Étapes** :
  1. Accéder à l'écran d'inscription
  2. Remplir le formulaire (nom, email, mot de passe)
  3. Accepter les conditions
  4. Soumettre le formulaire
- **Résultats Attendus** :
  - Validation des champs
  - Email de confirmation envoyé
  - Redirection vers écran de connexion
- **Critères de Succès** : Compte créé avec succès
- **Données de Test** : `nouveau@example.com` / `Test123!`

#### TEST-005 : Connexion Utilisateur
- **Objectif** : Vérifier la connexion avec identifiants valides
- **Prérequis** : Compte existant
- **Étapes** :
  1. Accéder à l'écran de connexion
  2. Saisir email et mot de passe
  3. Cliquer sur "Se connecter"
- **Résultats Attendus** :
  - Authentification réussie
  - Redirection vers tableau de bord
  - Token stocké localement
- **Critères de Succès** : Accès à l'app authentifié
- **Données de Test** : `user@cesizen.fr` / `password`

#### TEST-006 : Connexion avec Biométrie
- **Objectif** : Tester l'authentification biométrique
- **Prérequis** : Biométrie configurée sur l'appareil
- **Étapes** :
  1. Se connecter normalement
  2. Activer la biométrie dans les paramètres
  3. Se déconnecter
  4. Tenter reconnexion avec biométrie
- **Résultats Attendus** : Authentification via empreinte/visage
- **Critères de Succès** : Connexion sans saisie manuelle

#### TEST-007 : Mot de Passe Oublié
- **Objectif** : Tester la récupération de mot de passe
- **Prérequis** : Compte existant
- **Étapes** :
  1. Cliquer sur "Mot de passe oublié"
  2. Saisir l'email
  3. Soumettre
- **Résultats Attendus** : Email de reset envoyé
- **Critères de Succès** : Processus de reset initié

#### TEST-008 : Validation Formulaire Auth
- **Objectif** : Vérifier les validations des formulaires
- **Prérequis** : Accès aux formulaires
- **Étapes** :
  1. Laisser champs vides
  2. Saisir email invalide
  3. Mot de passe trop court
  4. Soumettre
- **Résultats Attendus** : Messages d'erreur appropriés
- **Critères de Succès** : Validation côté client fonctionnelle

---

### Articles

#### TEST-009 : Liste Articles
- **Objectif** : Afficher la liste des articles disponibles
- **Prérequis** : Utilisateur connecté
- **Étapes** :
  1. Accéder à l'onglet Articles
  2. Observer la liste
  3. Scroller vers le bas
- **Résultats Attendus** :
  - Articles affichés avec titre, image, résumé
  - Pagination ou infinite scroll
  - Tri par défaut (date décroissante)
- **Critères de Succès** : Liste chargée sans erreur

#### TEST-010 : Recherche Articles
- **Objectif** : Tester la fonctionnalité de recherche
- **Prérequis** : Liste d'articles chargée
- **Étapes** :
  1. Cliquer sur l'icône recherche
  2. Saisir un mot-clé
  3. Valider la recherche
- **Résultats Attendus** : Résultats filtrés affichés
- **Critères de Succès** : Recherche fonctionnelle et rapide

#### TEST-011 : Filtres Articles
- **Objectif** : Appliquer des filtres sur les articles
- **Prérequis** : Liste d'articles
- **Étapes** :
  1. Ouvrir les filtres
  2. Sélectionner catégorie, date, auteur
  3. Appliquer les filtres
- **Résultats Attendus** : Liste filtrée selon critères
- **Critères de Succès** : Filtres appliqués correctement

#### TEST-012 : Détail Article
- **Objectif** : Consulter le contenu complet d'un article
- **Prérequis** : Article sélectionné
- **Étapes** :
  1. Cliquer sur un article de la liste
  2. Lire le contenu
  3. Utiliser les contrôles (zoom, partage)
- **Résultats Attendus** :
  - Contenu affiché correctement
  - Images et formatage préservés
  - Temps de lecture tracké
- **Critères de Succès** : Lecture fluide et complète

#### TEST-013 : Tracking Consultation
- **Objectif** : Vérifier le suivi des lectures
- **Prérequis** : Article lu
- **Étapes** :
  1. Lire un article complètement
  2. Vérifier dans l'historique
- **Résultats Attendus** : Article marqué comme lu
- **Critères de Succès** : Historique mis à jour

---

### Catégories

#### TEST-014 : Navigation par Catégorie
- **Objectif** : Parcourir les articles par catégorie
- **Prérequis** : Utilisateur connecté
- **Étapes** :
  1. Accéder à l'onglet Catégories
  2. Sélectionner une catégorie
  3. Observer les articles filtrés
- **Résultats Attendus** : Liste d'articles de la catégorie
- **Critères de Succès** : Filtrage correct

#### TEST-015 : Arborescence Catégories
- **Objectif** : Tester la hiérarchie des catégories
- **Prérequis** : Catégories définies
- **Étapes** :
  1. Naviguer dans l'arborescence
  2. Sélectionner sous-catégories
- **Résultats Attendus** : Navigation fluide
- **Critères de Succès** : Structure respectée

#### TEST-016 : Filtres Catégories
- **Objectif** : Appliquer des filtres avancés
- **Prérequis** : Catégorie sélectionnée
- **Étapes** :
  1. Ouvrir les options de filtre
  2. Sélectionner critères multiples
- **Résultats Attendus** : Résultats filtrés
- **Critères de Succès** : Filtres combinés fonctionnels

---

### Exercices

#### TEST-017 : Liste Exercices
- **Objectif** : Afficher les exercices disponibles
- **Prérequis** : Utilisateur connecté
- **Étapes** :
  1. Accéder à l'onglet Exercices
  2. Observer la liste
- **Résultats Attendus** : Exercices avec titre, durée, difficulté
- **Critères de Succès** : Liste chargée

#### TEST-018 : Détail Exercice
- **Objectif** : Consulter les détails d'un exercice
- **Prérequis** : Exercice sélectionné
- **Étapes** :
  1. Cliquer sur un exercice
  2. Lire description et instructions
- **Résultats Attendus** : Informations complètes affichées
- **Critères de Succès** : Détails accessibles

#### TEST-019 : Minuteur Intégré
- **Objectif** : Tester le chronomètre d'exercice
- **Prérequis** : Exercice avec durée définie
- **Étapes** :
  1. Démarrer un exercice
  2. Observer le minuteur
  3. Attendre la fin
- **Résultats Attendus** : Compte à rebours précis
- **Critères de Succès** : Minuteur fonctionnel

#### TEST-020 : Mode Guidé
- **Objectif** : Tester le mode d'accompagnement
- **Prérequis** : Exercice en mode guidé
- **Étapes** :
  1. Sélectionner mode guidé
  2. Suivre les instructions vocales/visuelles
- **Résultats Attendus** : Guidage étape par étape
- **Critères de Succès** : Accompagnement efficace

#### TEST-021 : Tracking Participation
- **Objectif** : Vérifier le suivi des exercices
- **Prérequis** : Exercice terminé
- **Étapes** :
  1. Compléter un exercice
  2. Vérifier les statistiques
- **Résultats Attendus** : Progression enregistrée
- **Critères de Succès** : Données trackées

---

### Tableau de Bord

#### TEST-022 : Affichage Dashboard
- **Objectif** : Vérifier l'écran principal utilisateur
- **Prérequis** : Utilisateur connecté
- **Étapes** :
  1. Se connecter
  2. Observer le tableau de bord
- **Résultats Attendus** : Statistiques et raccourcis affichés
- **Critères de Succès** : Dashboard chargé

#### TEST-023 : Statistiques Utilisateur
- **Objectif** : Consulter les métriques personnelles
- **Prérequis** : Données utilisateur disponibles
- **Étapes** :
  1. Accéder aux statistiques
  2. Observer les graphiques
- **Résultats Attendus** : Données visualisées
- **Critères de Succès** : Graphiques corrects

#### TEST-024 : Historique Activités
- **Objectif** : Parcourir l'historique des actions
- **Prérequis** : Activités enregistrées
- **Étapes** :
  1. Ouvrir l'historique
  2. Filtrer par date/type
- **Résultats Attendus** : Liste chronologique
- **Critères de Succès** : Historique accessible

#### TEST-025 : Graphiques et Tendances
- **Objectif** : Analyser les tendances via graphiques
- **Prérequis** : Données suffisantes
- **Étapes** :
  1. Sélectionner période
  2. Observer les graphiques
- **Résultats Attendus** : Visualisations interactives
- **Critères de Succès** : Graphiques informatifs

---

### Profil & Paramètres

#### TEST-026 : Consultation Profil
- **Objectif** : Afficher les informations utilisateur
- **Prérequis** : Utilisateur connecté
- **Étapes** :
  1. Accéder au profil
  2. Observer les données
- **Résultats Attendus** : Profil complet affiché
- **Critères de Succès** : Données correctes

#### TEST-027 : Modification Profil
- **Objectif** : Éditer les informations personnelles
- **Prérequis** : Profil accessible
- **Étapes** :
  1. Cliquer sur "Modifier"
  2. Changer nom, photo, bio
  3. Sauvegarder
- **Résultats Attendus** : Modifications appliquées
- **Critères de Succès** : Profil mis à jour

#### TEST-028 : Paramètres Application
- **Objectif** : Configurer les préférences
- **Prérequis** : Accès paramètres
- **Étapes** :
  1. Ouvrir les paramètres
  2. Modifier notifications, thème, langue
- **Résultats Attendus** : Paramètres sauvegardés
- **Critères de Succès** : Configuration persistante

#### TEST-029 : Gestion Notifications
- **Objectif** : Configurer les alertes
- **Prérequis** : Permissions accordées
- **Étapes** :
  1. Activer/désactiver types de notifications
  2. Tester envoi de notification test
- **Résultats Attendus** : Notifications contrôlées
- **Critères de Succès** : Gestion fonctionnelle

#### TEST-030 : Déconnexion
- **Objectif** : Tester la déconnexion sécurisée
- **Prérequis** : Utilisateur connecté
- **Étapes** :
  1. Cliquer sur "Déconnexion"
  2. Confirmer
- **Résultats Attendus** :
  - Session terminée
  - Redirection vers authentification
  - Données locales effacées
- **Critères de Succès** : Déconnexion complète

---

## 🔄 Tests Non-Fonctionnels

#### TEST-NF-001 : Performance Chargement
- **Objectif** : Mesurer les temps de réponse
- **Étapes** : Chronométrer les chargements d'écrans
- **Critères** : < 3 secondes pour écrans principaux

#### TEST-NF-002 : Mode Hors Ligne
- **Objectif** : Tester la fonctionnalité offline
- **Étapes** : Désactiver réseau et utiliser l'app
- **Critères** : Contenu mis en cache accessible

#### TEST-NF-003 : Responsive Design
- **Objectif** : Vérifier l'adaptation aux écrans
- **Étapes** : Tester sur différentes tailles/orientations
- **Critères** : Interface adaptée

#### TEST-NF-004 : Gestion Batterie
- **Objectif** : Évaluer l'impact sur la batterie
- **Étapes** : Utiliser l'app intensivement
- **Critères** : Consommation raisonnable

---

## 📊 Rapport de Test

### Modèle de Rapport

Pour chaque exécution de test, créer un rapport avec :

- **Date/Heure** : Timestamp de l'exécution
- **Testeur** : Nom du testeur
- **Environnement** : Appareil, OS, version app
- **Résultats** :
  - ✅ Réussi
  - ❌ Échoué
  - ⚠️ Anomalie
- **Commentaires** : Détails des problèmes rencontrés
- **Captures d'écran** : Si applicable

### Métriques à Suivre

- **Taux de Réussite** : % tests passés
- **Temps Moyen** : Durée par test
- **Bugs Découverts** : Liste des anomalies
- **Couverture** : % fonctionnalités testées

---

## 📞 Support et Maintenance

- **Mise à Jour** : Réviser ce document à chaque nouvelle version
- **Feedback** : Signaler les tests manquants ou obsolètes
- **Automatisation** : Considérer les tests automatisés pour la régression

---

**Fin du Cahier de Recettes**  
*Document généré automatiquement - Version 1.0*</content>
<parameter name="filePath">C:\Users\Elio\Documents\GitHub\cesizen_mobile\docs\15-test-cases.md
