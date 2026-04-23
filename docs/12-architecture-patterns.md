# 🏗️ Architecture & Patterns - CESIZen Mobile

## 🎯 Vue d'Ensemble

L'architecture de CESIZen Mobile suit les meilleures pratiques Flutter avec une séparation claire des responsabilités et des patterns éprouvés.

### Principes Architecturaux
- ✅ **Separation of Concerns**: Chaque couche a une responsabilité unique
- ✅ **Dependency Injection**: Injection de dépendances pour testabilité
- ✅ **Repository Pattern**: Abstraction des sources de données
- ✅ **Provider Pattern**: Gestion d'état réactive
- ✅ **Clean Architecture**: Indépendance des frameworks

## 📁 Structure du Projet

### Arborescence Détaillée
```
lib/
├── main.dart                          # Point d'entrée de l'application
├── app.dart                           # Configuration globale de l'app
├── core/                              # Code partagé et utilitaires
│   ├── config/                        # Configuration (API, thèmes)
│   │   ├── api_config.dart           # URLs et endpoints API
│   │   ├── app_config.dart           # Configuration générale
│   │   └── theme_config.dart         # Thèmes clair/sombre
│   ├── data/                          # Sources de données
│   │   ├── repositories/             # Implémentations repository
│   │   ├── services/                 # Services externes (API, cache)
│   │   └── models/                   # DTOs et entités de données
│   ├── network/                       # Couche réseau
│   │   ├── api_client.dart           # Client HTTP générique
│   │   ├── interceptors/             # Intercepteurs HTTP
│   │   └── endpoints/                # Définition des endpoints
│   ├── theme/                         # Thèmes et styles
│   │   ├── app_theme.dart            # Thème principal
│   │   ├── colors.dart               # Palette de couleurs
│   │   └── text_styles.dart          # Styles de texte
│   ├── widgets/                       # Composants réutilisables
│   │   ├── buttons/                  # Boutons personnalisés
│   │   ├── cards/                    # Cartes d'affichage
│   │   ├── inputs/                   # Champs de saisie
│   │   └── loading/                  # Indicateurs de chargement
│   ├── utils/                         # Utilitaires
│   │   ├── constants.dart            # Constantes globales
│   │   ├── extensions.dart           # Extensions Dart
│   │   ├── helpers.dart              # Fonctions helper
│   │   └── validators.dart           # Validateurs de formulaires
│   └── di/                           # Dependency Injection
│       ├── injector.dart             # Configuration DI
│       └── modules/                  # Modules DI
├── features/                          # Fonctionnalités métier
│   ├── auth/                         # Authentification
│   │   ├── data/                     # Données auth (models, repositories)
│   │   ├── domain/                   # Logique métier auth
│   │   ├── presentation/             # UI auth (screens, widgets)
│   │   └── di/                       # Injection dépendances auth
│   ├── breathing/                    # Exercices respiration
│   │   ├── data/                     # Données exercices
│   │   ├── domain/                   # Logique exercices
│   │   ├── presentation/             # UI exercices
│   │   └── di/                       # DI exercices
│   ├── home/                         # Dashboard
│   ├── prevention/                   # Articles prévention
│   ├── profile/                      # Profil utilisateur
│   └── support/                      # Support & aide
├── shared/                            # Code partagé entre features
│   ├── widgets/                      # Widgets partagés
│   ├── models/                       # Modèles partagés
│   └── utils/                        # Utilitaires partagés
└── l10n/                             # Internationalisation
    ├── app_en.arb                    # Traductions anglais
    ├── app_fr.arb                    # Traductions français
    └── l10n.dart                     # Configuration i18n
```

## 🏛️ Patterns Architecturaux

### 1. Clean Architecture

#### Couches de Clean Architecture
```
┌─────────────────────────────────────┐
│          Presentation Layer         │ ← Screens, Widgets, State Management
├─────────────────────────────────────┤
│          Domain Layer               │ ← Business Logic, Use Cases, Entities
├─────────────────────────────────────┤
│          Data Layer                 │ ← Repositories, Data Sources, Models
└─────────────────────────────────────┘
```

#### Avantages
- **Testabilité**: Chaque couche testable indépendamment
- **Maintenabilité**: Changements isolés par couche
- **Indépendance**: Changement de framework sans impact métier
- **Réutilisabilité**: Logique métier réutilisable

### 2. MVVM Pattern (Model-View-ViewModel)

#### Structure MVVM
```dart
// Model - Données et logique métier
class ArticleModel {
  final String id;
  final String title;
  final String content;

  ArticleModel({required this.id, required this.title, required this.content});
}

// ViewModel - Logique présentation et état
class ArticleViewModel extends ChangeNotifier {
  final ArticleRepository _repository;

  ArticleModel? _article;
  bool _isLoading = false;
  String? _error;

  ArticleModel? get article => _article;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadArticle(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _article = await _repository.getArticle(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// View - Interface utilisateur
class ArticleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ArticleViewModel(ArticleRepository()),
      child: Consumer<ArticleViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return CircularProgressIndicator();
          }

          if (viewModel.error != null) {
            return Text('Erreur: ${viewModel.error}');
          }

          return Text(viewModel.article?.title ?? 'No article');
        },
      ),
    );
  }
}
```

### 3. Repository Pattern

#### Interface Repository
```dart
abstract class ArticleRepository {
  Future<List<Article>> getArticles({
    int page = 1,
    String? category,
    String? searchQuery,
  });

  Future<Article> getArticle(String id);

  Future<void> saveArticle(Article article);

  Future<void> deleteArticle(String id);
}
```

#### Implémentation Repository
```dart
class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleLocalDataSource _localDataSource;
  final ArticleRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ArticleRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._networkInfo,
  );

  @override
  Future<List<Article>> getArticles({
    int page = 1,
    String? category,
    String? searchQuery,
  }) async {
    try {
      // Essayer d'abord les données locales pour rapidité
      final localArticles = await _localDataSource.getArticles(
        page: page,
        category: category,
        searchQuery: searchQuery,
      );

      // Si connecté, synchroniser avec serveur en arrière-plan
      if (await _networkInfo.isConnected) {
        _syncWithRemote(page, category, searchQuery);
      }

      return localArticles;
    } catch (e) {
      // Fallback vers données serveur si locales indisponibles
      if (await _networkInfo.isConnected) {
        return await _remoteDataSource.getArticles(
          page: page,
          category: category,
          searchQuery: searchQuery,
        );
      }
      throw e;
    }
  }

  Future<void> _syncWithRemote(int page, String? category, String? searchQuery) async {
    try {
      final remoteArticles = await _remoteDataSource.getArticles(
        page: page,
        category: category,
        searchQuery: searchQuery,
      );
      await _localDataSource.saveArticles(remoteArticles);
    } catch (e) {
      // Log erreur sync silencieuse
    }
  }

  @override
  Future<Article> getArticle(String id) async {
    try {
      // Essayer local d'abord
      return await _localDataSource.getArticle(id);
    } catch (e) {
      // Fallback vers remote
      final article = await _remoteDataSource.getArticle(id);
      await _localDataSource.saveArticle(article);
      return article;
    }
  }

  @override
  Future<void> saveArticle(Article article) async {
    await _localDataSource.saveArticle(article);

    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.saveArticle(article);
      } catch (e) {
        // Marquer pour sync ultérieure
        await _localDataSource.markForSync(article.id);
      }
    }
  }

  @override
  Future<void> deleteArticle(String id) async {
    await _localDataSource.deleteArticle(id);

    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.deleteArticle(id);
      } catch (e) {
        // Log erreur
      }
    }
  }
}
```

### 4. Provider Pattern pour State Management

#### Configuration Provider
```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        // Services core
        Provider<NetworkInfo>(create: (_) => NetworkInfoImpl()),
        Provider<LocalStorageService>(create: (_) => LocalStorageServiceImpl()),

        // Repositories
        ProxyProvider<NetworkInfo, ArticleRepository>(
          update: (_, networkInfo, __) => ArticleRepositoryImpl(
            ArticleLocalDataSourceImpl(),
            ArticleRemoteDataSourceImpl(),
            networkInfo,
          ),
        ),

        // ViewModels / Providers
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthRepository>(),
            context.read<SecureTokenStorage>(),
          ),
        ),

        ChangeNotifierProvider<DashboardProvider>(
          create: (context) => DashboardProvider(
            context.read<DashboardRepository>(),
            context.read<LocalStorageService>(),
          ),
        ),

        // Feature providers
        ChangeNotifierProxyProvider<AuthProvider, ArticlesProvider>(
          create: (context) => ArticlesProvider(
            context.read<ArticleRepository>(),
            context.read<LocalStorageService>(),
          ),
          update: (context, auth, previous) => previous!..updateAuth(auth),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

## 🧩 Composants Réutilisables

### 1. Custom Widgets

#### LoadingButton Widget
```dart
class LoadingButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final Widget child;
  final ButtonStyle? style;

  const LoadingButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.style,
  }) : super(key: key);

  @override
  _LoadingButtonState createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    setState(() => _isLoading = true);

    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handlePress,
      style: widget.style,
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : widget.child,
    );
  }
}
```

#### NetworkAwareWidget
```dart
class NetworkAwareWidget extends StatelessWidget {
  final Widget onlineChild;
  final Widget offlineChild;

  const NetworkAwareWidget({
    Key? key,
    required this.onlineChild,
    required this.offlineChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final isOnline = snapshot.data != ConnectivityResult.none;
        return isOnline ? onlineChild : offlineChild;
      },
    );
  }
}
```

#### CachedImage Widget
```dart
class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? const CircularProgressIndicator(),
      errorWidget: (context, url, error) => errorWidget ?? const Icon(Icons.error),
      // Configuration cache
      maxWidthDiskCache: 1000,
      maxHeightDiskCache: 1000,
      memCacheWidth: 500,
      memCacheHeight: 500,
    );
  }
}
```

### 2. Custom Hooks (avec flutter_hooks)

#### useDebounce Hook
```dart
Timer? useDebounce(VoidCallback callback, Duration delay) {
  return useEffect(() {
    final timer = Timer(delay, callback);
    return timer.cancel;
  }, [callback]);
}
```

#### useAsync Hook
```dart
AsyncSnapshot<T> useAsync<T>(Future<T> Function() future) {
  final snapshot = useState<AsyncSnapshot<T>>(const AsyncSnapshot.nothing());

  useEffect(() {
    snapshot.value = const AsyncSnapshot.waiting();
    future().then(
      (data) => snapshot.value = AsyncSnapshot.withData(ConnectionState.done, data),
      onError: (error) => snapshot.value = AsyncSnapshot.withError(ConnectionState.done, error),
    );
  }, [future]);

  return snapshot.value;
}
```

## 🔧 Services et Utilitaires

### 1. Network Service
```dart
class NetworkService {
  final Dio _dio;
  final Connectivity _connectivity;

  NetworkService(this._dio, this._connectivity) {
    _configureDio();
  }

  void _configureDio() {
    _dio.options
      ..baseUrl = ApiConfig.baseUrl
      ..connectTimeout = const Duration(seconds: 30)
      ..receiveTimeout = const Duration(seconds: 30)
      ..headers = {'Content-Type': 'application/json'};

    // Intercepteurs
    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
      RetryInterceptor(_dio),
    ]);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioError error) {
    switch (error.type) {
      case DioErrorType.connectTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        return NetworkTimeoutException();
      case DioErrorType.response:
        return _handleResponseError(error.response);
      default:
        return NetworkException('Erreur réseau inconnue');
    }
  }

  Exception _handleResponseError(Response? response) {
    if (response?.statusCode == 401) {
      return UnauthorizedException();
    } else if (response?.statusCode == 403) {
      return ForbiddenException();
    } else if (response?.statusCode == 404) {
      return NotFoundException();
    }
    return ServerException(response?.statusCode, response?.data);
  }
}
```

### 2. Cache Service
```dart
class CacheService {
  final SharedPreferences _prefs;
  final String _prefix;

  CacheService(this._prefs, this._prefix);

  Future<T?> get<T>(String key, T Function(String) fromJson) async {
    final jsonString = _prefs.getString('$_prefix$key');
    if (jsonString == null) return null;

    try {
      return fromJson(jsonString);
    } catch (e) {
      await remove(key); // Supprimer données corrompues
      return null;
    }
  }

  Future<void> set<T>(String key, T value, String Function(T) toJson) async {
    final jsonString = toJson(value);
    await _prefs.setString('$_prefix$key', jsonString);
  }

  Future<void> remove(String key) async {
    await _prefs.remove('$_prefix$key');
  }

  Future<void> clear() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  Future<bool> has(String key) async {
    return _prefs.containsKey('$_prefix$key');
  }

  Future<DateTime?> getTimestamp(String key) async {
    final timestamp = _prefs.getInt('$_prefix${key}_timestamp');
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  Future<void> setTimestamp(String key) async {
    await _prefs.setInt('$_prefix${key}_timestamp', DateTime.now().millisecondsSinceEpoch);
  }
}
```

## 🧪 Testing Architecture

### Tests Unitaires
```dart
void main() {
  group('ArticleRepository', () {
    late MockLocalDataSource mockLocal;
    late MockRemoteDataSource mockRemote;
    late MockNetworkInfo mockNetwork;
    late ArticleRepository repository;

    setUp(() {
      mockLocal = MockLocalDataSource();
      mockRemote = MockRemoteDataSource();
      mockNetwork = MockNetworkInfo();
      repository = ArticleRepositoryImpl(mockLocal, mockRemote, mockNetwork);
    });

    test('should return local data when available', () async {
      // Arrange
      when(mockLocal.getArticles()).thenAnswer((_) async => [testArticle]);
      when(mockNetwork.isConnected).thenAnswer((_) async => true);

      // Act
      final result = await repository.getArticles();

      // Assert
      expect(result, [testArticle]);
      verify(mockLocal.getArticles()).called(1);
      verifyNever(mockRemote.getArticles());
    });

    test('should return remote data when local fails and network available', () async {
      // Arrange
      when(mockLocal.getArticles()).thenThrow(Exception('Local error'));
      when(mockNetwork.isConnected).thenAnswer((_) async => true);
      when(mockRemote.getArticles()).thenAnswer((_) async => [testArticle]);

      // Act
      final result = await repository.getArticles();

      // Assert
      expect(result, [testArticle]);
      verify(mockRemote.getArticles()).called(1);
    });
  });
}
```

### Tests d'Intégration
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('user can login and view dashboard', (tester) async {
      // Setup
      await tester.pumpWidget(const MyApp());

      // Login
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify dashboard
      expect(find.text('Bienvenue'), findsOneWidget);
      expect(find.text('Tableau de Bord'), findsOneWidget);
    });
  });
}
```

## 🚀 Performance & Optimisations

### Optimisations UI
- **Lazy Loading**: Listes avec pagination
- **Image Caching**: CachedNetworkImage
- **Widget Reuse**: const constructors
- **Build Optimization**: Selective rebuilds

### Optimisations Mémoire
- **Object Pooling**: Réutilisation objets
- **Image Compression**: Réduction taille images
- **Background Cleanup**: Nettoyage données anciennes

### Optimisations Réseau
- **Request Batching**: Regrouper requêtes
- **Response Caching**: Cache HTTP intelligent
- **Delta Sync**: Sync différentielle

---

*Dernière mise à jour: 21 avril 2026*
