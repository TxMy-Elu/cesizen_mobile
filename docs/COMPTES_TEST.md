# 👤 Comptes de Test - Référence Rapide

**Date**: 2026-04-22  
**Application**: CESIZen Mobile  
**Environnement**: Développement / Staging / QA

---

## 🔑 Accès Direct

### Compte Administrateur
```
Email:    admin@cesizen.fr
Mot de passe: password
Rôle:     ROLE_ADMIN
```

**Permissions:**
- ✅ Gestion complète de l'application
- ✅ Accès à tous les articles/exercices
- ✅ Gestion utilisateurs
- ✅ Paramètres système
- ✅ Statistiques globales

---

### Compte Utilisateur Standard
```
Email:    user@cesizen.fr
Mot de passe: password
Rôle:     ROLE_USER
```

**Permissions:**
- ✅ Lecture articles
- ✅ Pratique exercices
- ✅ Consultation profil
- ✅ Consultation statistiques personnelles
- ❌ Gestion administrateur
- ❌ Modification autres utilisateurs

---

## 📋 Checklist Avant Test

- [ ] Vérifier version app correcte
- [ ] Comptes créés dans la BD de test
- [ ] Permissions assignées correctement
- [ ] Permissions des appareils accordées
- [ ] Connexion internet stable
- [ ] Base de données peuplée (articles, exercices)

---

## 🔄 Actions de Base

### Connexion
```
1. Ouvrir l'app
2. Cliquer "Se connecter"
3. Email: admin@cesizen.fr (ou user@cesizen.fr)
4. Mot de passe: password
5. Cliquer "Connexion"
```

### Déconnexion
```
1. Profil > Paramètres
2. Défilement vers le bas
3. Cliquer "Déconnexion"
4. Confirmer
```

### Réinitialiser Session
```
1. Fermer complètement l'app
2. Vider le cache (Paramètres > Stockage > Vider cache)
3. Relancer l'app
```

---

## ⚙️ Configurations Recommandées

### Environnement de Test
- **Émulateur** : Android 12+ / iOS 14+
- **Navigateur** : Chrome, Safari (si web)
- **Réseau** : WiFi stable ou 4G/5G
- **Stockage** : Minimum 500MB libres

### Permissions À Activer
- [ ] Notifications
- [ ] Caméra (si applicable)
- [ ] Localisation (si applicable)
- [ ] Stockage (si applicable)
- [ ] Microphone (si applicable)

---

## 🐛 Troubleshooting

### "Accès Refusé"
- Vérifier email exact : `admin@cesizen.fr` ou `user@cesizen.fr`
- Vérifier mot de passe : `password`
- Vérifier rôle assigné en base de données

### "Compte Bloqué"
- Contacter administrateur BD
- Réinitialiser mot de passe
- Vérifier logs d'authentification

### "Permissions Insuffisantes"
- Vérifier rôle : ROLE_ADMIN vs ROLE_USER
- Vérifier permissions assignées
- Vérifier accès aux ressources

---

## 📞 Support

- **Base de Données** : Vérifier connexion DB de test
- **Backend** : Vérifier service authentification
- **Frontend** : Vérifier logs console
- **Appareil** : Redémarrer émulateur/device

---

**Mise à jour**: 2026-04-22  
**Status**: ✅ Actif  
**Mainteneur**: Équipe QA CESIZen

# Documentation
*.md
!README.md
!**/README.md
!/docs
!**/docs