# 👤 Profil & Paramètres - CESIZen Mobile

## 🎯 Vue d'Ensemble

Le module Profil & Paramètres permet la gestion du compte utilisateur, des préférences et des paramètres de l'application.

### Fonctionnalités Clés
- ✅ Gestion du profil utilisateur
- ✅ Paramètres de notifications
- ✅ Préférences d'application
- ✅ Gestion des données
- ✅ Support et aide

## 📊 Modèle de Données Profil

### Profil Utilisateur
```dart
class UserProfile {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isPremium;
  final UserPreferences preferences;
  final List<UserBadge> badges;
  final Map<String, dynamic> stats;
}
```

### Préférences Utilisateur
```dart
class UserPreferences {
  final bool notificationsEnabled;
  final bool dailyReminders;
  final bool exerciseReminders;
  final bool articleRecommendations;
  final ThemeMode themeMode;
  final String language;
  final bool hapticFeedback;
  final bool soundEffects;
  final BreathingReminderSettings breathingReminders;
  final PrivacySettings privacySettings;
}
```

### Paramètres de Notifications
```dart
class NotificationSettings {
  final bool pushEnabled;
  final bool emailEnabled;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;
  final List<String> enabledCategories;
  final Map<String, bool> exerciseReminders;
  final Map<String, bool> articleReminders;
}
```

## 🎨 Écran Profil

### Wireframe Profil
```
┌─────────────────────────────────┐
│  ← Profil                       │
│                                 │
│  ┌─────────────────────────┐    │
│  │         [Avatar]        │    │
│  │                         │    │
│  │   Jean Dupont           │    │
│  │   jean@example.com      │    │
│  │   Membre depuis 2023    │    │
│  └─────────────────────────┘    │
│                                 │
│  🏆 Badges (3)                  │
│  🔥 7 jours • 📚 15 articles    │
│                                 │
│  ⚙️ Paramètres                  │
│  🔔 Notifications              │
│  🌙 Thème                       │
│  🔒 Confidentialité             │
│                                 │
│  📊 Statistiques                │
│  💾 Données & Stockage          │
│                                 │
│  ❓ Aide & Support               │
│  🚪 Déconnexion                 │
└─────────────────────────────────┘
```

### Implémentation Écran Profil
```dart
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final profileProvider = context.read<ProfileProvider>();
      _profile = await profileProvider.getProfile();

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur chargement profil')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_profile == null) {
      return const Scaffold(
        body: Center(child: Text('Erreur de chargement')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditProfile(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête profil
            _buildProfileHeader(),

            const SizedBox(height: 24),

            // Badges
            _buildBadgesSection(),

            const SizedBox(height: 24),

            // Paramètres
            _buildSettingsSection(),

            const SizedBox(height: 24),

            // Statistiques
            _buildStatsSection(),

            const SizedBox(height: 24),

            // Actions
            _buildActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _profile!.avatarUrl != null
                      ? NetworkImage(_profile!.avatarUrl!)
                      : null,
                  child: _profile!.avatarUrl == null
                      ? Text(
                          _profile!.name?.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(fontSize: 32),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      onPressed: _changeAvatar,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Informations
            Text(
              _profile!.name ?? 'Utilisateur',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              _profile!.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 8),

            // Statut membre
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _profile!.isPremium ? Colors.amber[100] : Colors.blue[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _profile!.isPremium ? 'Membre Premium' : 'Membre Gratuit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _profile!.isPremium ? Colors.amber[800] : Colors.blue[800],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Date d'inscription
            Text(
              'Membre depuis ${_formatDate(_profile!.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesSection() {
    if (_profile!.badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '🏆 Badges',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/badges'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _profile!.badges.length,
            itemBuilder: (context, index) {
              final badge = _profile!.badges[index];
              return Container(
                width: 70,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.amber[100],
                      child: Text(badge.icon, style: const TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      badge.name,
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⚙️ Paramètres',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Gérer les rappels et alertes',
          onTap: () => Navigator.pushNamed(context, '/notification-settings'),
        ),
        _buildSettingItem(
          icon: Icons.palette,
          title: 'Thème',
          subtitle: 'Mode clair/sombre',
          onTap: () => _showThemeDialog(),
        ),
        _buildSettingItem(
          icon: Icons.lock,
          title: 'Confidentialité',
          subtitle: 'Contrôles de données',
          onTap: () => Navigator.pushNamed(context, '/privacy-settings'),
        ),
        _buildSettingItem(
          icon: Icons.language,
          title: 'Langue',
          subtitle: 'Français',
          onTap: () => _showLanguageDialog(),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 Statistiques',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.play_circle,
                  value: '${_profile!.stats['totalSessions'] ?? 0}',
                  label: 'Sessions',
                ),
                _buildStatItem(
                  icon: Icons.timer,
                  value: '${_profile!.stats['totalMinutes'] ?? 0}',
                  label: 'Minutes',
                ),
                _buildStatItem(
                  icon: Icons.article,
                  value: '${_profile!.stats['articlesRead'] ?? 0}',
                  label: 'Articles',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          icon: Icons.help,
          title: 'Aide & Support',
          subtitle: 'FAQ, contact, tutoriels',
          onTap: () => Navigator.pushNamed(context, '/support'),
        ),
        _buildSettingItem(
          icon: Icons.storage,
          title: 'Données & Stockage',
          subtitle: 'Exporter, supprimer données',
          onTap: () => Navigator.pushNamed(context, '/data-management'),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Déconnexion'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _navigateToEditProfile() {
    Navigator.pushNamed(context, '/edit-profile');
  }

  Future<void> _changeAvatar() async {
    // Implémentation changement avatar
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Upload et mise à jour
      try {
        final profileProvider = context.read<ProfileProvider>();
        await profileProvider.updateAvatar(image.path);
        await _loadProfile(); // Recharger
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur mise à jour avatar')),
        );
      }
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choisir un thème'),
        children: [
          SimpleDialogOption(
            onPressed: () => _setTheme(ThemeMode.light),
            child: const Text('☀️ Clair'),
          ),
          SimpleDialogOption(
            onPressed: () => _setTheme(ThemeMode.dark),
            child: const Text('🌙 Sombre'),
          ),
          SimpleDialogOption(
            onPressed: () => _setTheme(ThemeMode.system),
            child: const Text('🔄 Système'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choisir une langue'),
        children: [
          SimpleDialogOption(
            onPressed: () => _setLanguage('fr'),
            child: const Text('🇫🇷 Français'),
          ),
          SimpleDialogOption(
            onPressed: () => _setLanguage('en'),
            child: const Text('🇺🇸 English'),
          ),
        ],
      ),
    );
  }

  Future<void> _setTheme(ThemeMode themeMode) async {
    try {
      final profileProvider = context.read<ProfileProvider>();
      await profileProvider.updateTheme(themeMode);
      Navigator.pop(context);
      // Recharger l'app avec le nouveau thème
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur mise à jour thème')),
      );
    }
  }

  Future<void> _setLanguage(String language) async {
    try {
      final profileProvider = context.read<ProfileProvider>();
      await profileProvider.updateLanguage(language);
      Navigator.pop(context);
      // Recharger l'app avec la nouvelle langue
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur mise à jour langue')),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final authProvider = context.read<AuthProvider>();
        await authProvider.signOut();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur déconnexion')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.year}';
  }
}
```

## 🔔 Écran Paramètres Notifications

### Wireframe Notifications
```
┌─────────────────────────────────┐
│  ← Notifications               │
│                                 │
│  🔔 Notifications Push          │
│  [ON] Activées                  │
│                                 │
│  📧 Notifications Email         │
│  [OFF] Désactivées              │
│                                 │
│  ⏰ Heures Calmes                │
│  De 22:00 à 08:00               │
│                                 │
│  🏃‍♂️ Rappels Exercices           │
│  [ON] Quotidien 09:00           │
│  [ON] Anti-stress 14:00         │
│  [OFF] Sommeil 20:00            │
│                                 │
│  📚 Articles Recommandés        │
│  [ON] Hebdomadaire              │
└─────────────────────────────────┘
```

### Implémentation Paramètres Notifications
```dart
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  _NotificationSettingsScreenState createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  NotificationSettings? _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final profileProvider = context.read<ProfileProvider>();
      _settings = await profileProvider.getNotificationSettings();

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur chargement paramètres')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _settings == null) {
      return const Scaffold(
        appBar: AppBar(title: Text('Notifications')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: [
          // Notifications Push
          SwitchListTile(
            title: const Text('Notifications Push'),
            subtitle: const Text('Recevoir des notifications dans l\'app'),
            value: _settings!.pushEnabled,
            onChanged: _updatePushEnabled,
          ),

          const Divider(),

          // Notifications Email
          SwitchListTile(
            title: const Text('Notifications Email'),
            subtitle: const Text('Recevoir des emails de CESIZen'),
            value: _settings!.emailEnabled,
            onChanged: _updateEmailEnabled,
          ),

          const Divider(),

          // Heures Calmes
          ListTile(
            title: const Text('Heures Calmes'),
            subtitle: Text(
              'De ${_formatTime(_settings!.quietHoursStart)} à ${_formatTime(_settings!.quietHoursEnd)}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showQuietHoursDialog,
          ),

          const Divider(),

          // Rappels Exercices
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Rappels Exercices',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ..._settings!.exerciseReminders.entries.map((entry) {
            return SwitchListTile(
              title: Text(_getExerciseReminderTitle(entry.key)),
              subtitle: Text(_getExerciseReminderSubtitle(entry.key)),
              value: entry.value,
              onChanged: (value) => _updateExerciseReminder(entry.key, value),
            );
          }),

          const Divider(),

          // Articles Recommandés
          SwitchListTile(
            title: const Text('Articles Recommandés'),
            subtitle: const Text('Recevoir des suggestions d\'articles'),
            value: _settings!.articleReminders['weekly'] ?? false,
            onChanged: (value) => _updateArticleReminders(value),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePushEnabled(bool value) async {
    try {
      final profileProvider = context.read<ProfileProvider>();
      await profileProvider.updateNotificationSettings(
        _settings!.copyWith(pushEnabled: value),
      );
      setState(() => _settings = _settings!.copyWith(pushEnabled: value));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur mise à jour')),
      );
    }
  }

  Future<void> _updateEmailEnabled(bool value) async {
    try {
      final profileProvider = context.read<ProfileProvider>();
      await profileProvider.updateNotificationSettings(
        _settings!.copyWith(emailEnabled: value),
      );
      setState(() => _settings = _settings!.copyWith(emailEnabled: value));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur mise à jour')),
      );
    }
  }

  void _showQuietHoursDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Heures Calmes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Début'),
              trailing: Text(_formatTime(_settings!.quietHoursStart)),
              onTap: () => _selectTime(true),
            ),
            ListTile(
              title: const Text('Fin'),
              trailing: Text(_formatTime(_settings!.quietHoursEnd)),
              onTap: () => _selectTime(false),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(bool isStart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStart ? _settings!.quietHoursStart : _settings!.quietHoursEnd,
    );

    if (time != null) {
      final updated = isStart
          ? _settings!.copyWith(quietHoursStart: time)
          : _settings!.copyWith(quietHoursEnd: time);

      try {
        final profileProvider = context.read<ProfileProvider>();
        await profileProvider.updateNotificationSettings(updated);
        setState(() => _settings = updated);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur mise à jour')),
        );
      }
    }
  }

  Future<void> _updateExerciseReminder(String key, bool value) async {
    final updated = Map<String, bool>.from(_settings!.exerciseReminders);
    updated[key] = value;

    try {
      final profileProvider = context.read<ProfileProvider>();
      await profileProvider.updateNotificationSettings(
        _settings!.copyWith(exerciseReminders: updated),
      );
      setState(() => _settings = _settings!.copyWith(exerciseReminders: updated));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur mise à jour')),
      );
    }
  }

  Future<void> _updateArticleReminders(bool value) async {
    final updated = Map<String, bool>.from(_settings!.articleReminders);
    updated['weekly'] = value;

    try {
      final profileProvider = context.read<ProfileProvider>();
      await profileProvider.updateNotificationSettings(
        _settings!.copyWith(articleReminders: updated),
      );
      setState(() => _settings = _settings!.copyWith(articleReminders: updated));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur mise à jour')),
      );
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getExerciseReminderTitle(String key) {
    switch (key) {
      case 'daily':
        return 'Rappel Quotidien';
      case 'stress':
        return 'Anti-Stress';
      case 'sleep':
        return 'Sommeil';
      default:
        return key;
    }
  }

  String _getExerciseReminderSubtitle(String key) {
    switch (key) {
      case 'daily':
        return 'Rappel pour commencer votre journée';
      case 'stress':
        return 'Pause respiration en milieu de journée';
      case 'sleep':
        return 'Préparation au sommeil';
      default:
        return '';
    }
  }
}
```

## 🔄 Provider Profil

### ProfileProvider
```dart
class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;
  final LocalStorageService _localStorage;

  UserProfile? _profile;
  NotificationSettings? _notificationSettings;

  ProfileProvider(this._repository, this._localStorage);

  Future<UserProfile> getProfile() async {
    try {
      _profile = await _repository.getProfile();
      return _profile!;
    } catch (e) {
      // Fallback vers données locales
      final local = await _localStorage.getLocalProfile();
      _profile = local;
      return local;
    }
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    try {
      await _repository.updateProfile(updatedProfile);
      _profile = updatedProfile;
      await _localStorage.saveProfile(updatedProfile);
      notifyListeners();
    } catch (e) {
      throw Exception('Erreur mise à jour profil');
    }
  }

  Future<void> updateAvatar(String imagePath) async {
    try {
      final avatarUrl = await _repository.uploadAvatar(imagePath);
      if (_profile != null) {
        final updated = _profile!.copyWith(avatarUrl: avatarUrl);
        await updateProfile(updated);
      }
    } catch (e) {
      throw Exception('Erreur upload avatar');
    }
  }

  Future<NotificationSettings> getNotificationSettings() async {
    try {
      _notificationSettings = await _repository.getNotificationSettings();
      return _notificationSettings!;
    } catch (e) {
      // Fallback vers paramètres locaux
      final local = await _localStorage.getLocalNotificationSettings();
      _notificationSettings = local;
      return local;
    }
  }

  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    try {
      await _repository.updateNotificationSettings(settings);
      _notificationSettings = settings;
      await _localStorage.saveNotificationSettings(settings);
      notifyListeners();
    } catch (e) {
      throw Exception('Erreur mise à jour paramètres');
    }
  }

  Future<void> updateTheme(ThemeMode themeMode) async {
    try {
      await _repository.updateTheme(themeMode);
      // Mettre à jour les préférences locales
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', themeMode.toString());
      notifyListeners();
    } catch (e) {
      throw Exception('Erreur mise à jour thème');
    }
  }

  Future<void> updateLanguage(String language) async {
    try {
      await _repository.updateLanguage(language);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', language);
      notifyListeners();
    } catch (e) {
      throw Exception('Erreur mise à jour langue');
    }
  }

  Future<void> exportData() async {
    try {
      final data = await _repository.exportUserData();
      // Sauvegarder fichier localement
      await _localStorage.saveExportedData(data);
    } catch (e) {
      throw Exception('Erreur export données');
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _repository.deleteAccount();
      await _localStorage.clearAllData();
    } catch (e) {
      throw Exception('Erreur suppression compte');
    }
  }
}
```

## 🧪 Tests Profil

### Tests Unitaires
```dart
void main() {
  group('ProfileProvider', () {
    test('should load profile successfully', () async {
      final mockRepo = MockProfileRepository();
      final provider = ProfileProvider(mockRepo, mockStorage);

      when(mockRepo.getProfile()).thenAnswer((_) async => mockProfile);

      final profile = await provider.getProfile();

      expect(profile.id, mockProfile.id);
    });

    test('should update profile and notify listeners', () async {
      final mockRepo = MockProfileRepository();
      final provider = ProfileProvider(mockRepo, mockStorage);

      final updatedProfile = mockProfile.copyWith(name: 'New Name');

      await provider.updateProfile(updatedProfile);

      verify(mockRepo.updateProfile(updatedProfile)).called(1);
      // Vérifier que notifyListeners a été appelé
    });
  });

  group('NotificationSettingsScreen', () {
    testWidgets('should display notification settings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NotificationSettingsScreen(),
        ),
      );

      expect(find.text('Notifications Push'), findsOneWidget);
      expect(find.text('Notifications Email'), findsOneWidget);
    });
  });
}
```

---

*Dernière mise à jour: 21 avril 2026*
