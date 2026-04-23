# 🔗 Exemples d'Intégration - CESIZen Mobile

## 🎯 Vue d'Ensemble

Cette section présente des exemples concrets d'intégration pour les fonctionnalités clés de CESIZen Mobile, incluant appels API, gestion d'erreurs et stratégie offline-first.

### Fonctionnalités Couvertes
- ✅ Configuration HTTP client
- ✅ Authentification et tokens
- ✅ Gestion erreurs réseau
- ✅ Cache et synchronisation
- ✅ Upload fichiers
- ✅ Notifications push

## 🌐 Configuration HTTP Client

### Dio Configuration Avancée
```dart
class ApiClient {
  static const String baseUrl = 'https://api.cesizen.com/v1';
  static const Duration timeout = Duration(seconds: 30);

  late Dio _dio;
  late SecureTokenStorage _tokenStorage;

  Dio get dio => _dio;

  ApiClient(this._tokenStorage) {
    _configureDio();
  }

  void _configureDio() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'CESIZen-Mobile/${AppConfig.version}',
      },
    ));

    // Intercepteurs dans l'ordre d'exécution
    _dio.interceptors.addAll([
      _authInterceptor(),
      _loggingInterceptor(),
      _retryInterceptor(),
      _cacheInterceptor(),
    ]);
  }

  // Intercepteur d'authentification
  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Ajouter token JWT si disponible
        final token = await _tokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Ajouter langue utilisateur
        final language = await _getUserLanguage();
        options.headers['Accept-Language'] = language;

        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expiré, essayer refresh
          try {
            final newToken = await _refreshToken();
            if (newToken != null) {
              // Retry requête avec nouveau token
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final response = await _dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            }
          } catch (e) {
            // Refresh échoué, déconnexion
            await _handleAuthFailure();
          }
        }

        handler.next(error);
      },
    );
  }

  // Intercepteur de logging
  Interceptor _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('🌐 REQUEST: ${options.method} ${options.uri}');
        debugPrint('📤 DATA: ${options.data}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
        debugPrint('📥 DATA: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}');
        debugPrint('💥 MESSAGE: ${error.message}');
        handler.next(error);
      },
    );
  }

  // Intercepteur de retry
  Interceptor _retryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (_shouldRetry(error)) {
          try {
            await Future.delayed(const Duration(seconds: 1));
            final response = await _dio.fetch(error.requestOptions);
            handler.resolve(response);
            return;
          } catch (e) {
            // Retry échoué
          }
        }
        handler.next(error);
      },
    );
  }

  // Intercepteur de cache
  Interceptor _cacheInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Vérifier si requête cacheable
        if (_isCacheable(options)) {
          final cachedResponse = await _getCachedResponse(options);
          if (cachedResponse != null) {
            handler.resolve(cachedResponse);
            return;
          }
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        // Cacher réponse si cacheable
        if (_isCacheable(response.requestOptions)) {
          _cacheResponse(response);
        }
        handler.next(response);
      },
    );
  }

  bool _shouldRetry(DioError error) {
    return error.type == DioErrorType.connectTimeout ||
           error.type == DioErrorType.receiveTimeout ||
           error.response?.statusCode == 502 ||
           error.response?.statusCode == 503 ||
           error.response?.statusCode == 504;
  }

  bool _isCacheable(RequestOptions options) {
    // Cache uniquement GET sans paramètres sensibles
    return options.method == 'GET' &&
           !options.uri.toString().contains('auth') &&
           !options.uri.toString().contains('private');
  }

  Future<Response?> _getCachedResponse(RequestOptions options) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _generateCacheKey(options);
    final cachedData = prefs.getString(cacheKey);

    if (cachedData != null) {
      try {
        final decoded = json.decode(cachedData);
        return Response(
          requestOptions: options,
          data: decoded['data'],
          statusCode: decoded['statusCode'],
          statusMessage: decoded['statusMessage'],
        );
      } catch (e) {
        // Cache corrompu
        prefs.remove(cacheKey);
      }
    }
    return null;
  }

  void _cacheResponse(Response response) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _generateCacheKey(response.requestOptions);
    final cacheData = json.encode({
      'data': response.data,
      'statusCode': response.statusCode,
      'statusMessage': response.statusMessage,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    prefs.setString(cacheKey, cacheData);
  }

  String _generateCacheKey(RequestOptions options) {
    return 'api_cache_${options.uri.toString().hashCode}';
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) return null;

      final response = await _dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      final newToken = response.data['accessToken'];
      final newRefreshToken = response.data['refreshToken'];

      await _tokenStorage.storeToken(newToken);
      await _tokenStorage.storeRefreshToken(newRefreshToken);

      return newToken;
    } catch (e) {
      return null;
    }
  }

  Future<void> _handleAuthFailure() async {
    await _tokenStorage.clearTokens();
    // Navigation vers login
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Future<String> _getUserLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? 'fr';
  }
}
```

## 🔐 Appels API Authentification

### Service Authentification
```dart
class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

  // Connexion
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post('/auth/login', data: request.toJson());

      final authResponse = AuthResponse.fromJson(response.data);

      // Stocker tokens
      await _storeTokens(authResponse);

      return authResponse;
    } on DioError catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Inscription
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.dio.post('/auth/register', data: request.toJson());

      final authResponse = AuthResponse.fromJson(response.data);

      // Stocker tokens
      await _storeTokens(authResponse);

      return authResponse;
    } on DioError catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Refresh token
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      final authResponse = AuthResponse.fromJson(response.data);

      // Mettre à jour tokens
      await _storeTokens(authResponse);

      return authResponse;
    } on DioError catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Mot de passe oublié
  Future<void> forgotPassword(String email) async {
    try {
      await _apiClient.dio.post('/auth/forgot-password', data: {'email': email});
    } on DioError catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Réinitialisation mot de passe
  Future<void> resetPassword(ResetPasswordRequest request) async {
    try {
      await _apiClient.dio.post('/auth/reset-password', data: request.toJson());
    } on DioError catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Vérification email
  Future<void> verifyEmail(String token) async {
    try {
      await _apiClient.dio.post('/auth/verify-email', data: {'token': token});
    } on DioError catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } catch (e) {
      // Ignorer erreurs logout
    } finally {
      // Nettoyer tokens locaux
      await _clearTokens();
    }
  }

  Future<void> _storeTokens(AuthResponse response) async {
    final tokenStorage = getIt<SecureTokenStorage>();
    await tokenStorage.storeToken(response.accessToken);
    await tokenStorage.storeRefreshToken(response.refreshToken);
  }

  Future<void> _clearTokens() async {
    final tokenStorage = getIt<SecureTokenStorage>();
    await tokenStorage.clearTokens();
  }

  AuthException _handleAuthError(DioError error) {
    switch (error.response?.statusCode) {
      case 400:
        return AuthException.invalidCredentials();
      case 401:
        return AuthException.unauthorized();
      case 403:
        return AuthException.forbidden();
      case 409:
        return AuthException.userAlreadyExists();
      case 422:
        final errors = error.response?.data['errors'] as Map<String, dynamic>?;
        return AuthException.validationFailed(errors ?? {});
      case 429:
        return AuthException.tooManyRequests();
      default:
        return AuthException.unknown();
    }
  }
}

// Modèles de données
class LoginRequest {
  final String email;
  final String password;
  final bool rememberMe;

  LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'rememberMe': rememberMe,
  };
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String? referralCode;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    this.referralCode,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'referralCode': referralCode,
  };
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      user: User.fromJson(json['user']),
    );
  }
}
```

## 📚 Appels API Articles

### Service Articles
```dart
class ArticlesApiService {
  final ApiClient _apiClient;

  ArticlesApiService(this._apiClient);

  // Récupérer articles avec filtres
  Future<PaginatedResponse<Article>> getArticles({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

      final response = await _apiClient.dio.get('/articles', queryParameters: queryParams);

      return PaginatedResponse<Article>.fromJson(
        response.data,
        (json) => Article.fromJson(json),
      );
    } on DioError catch (e) {
      throw _handleArticlesError(e);
    }
  }

  // Récupérer article par ID
  Future<Article> getArticle(String id) async {
    try {
      final response = await _apiClient.dio.get('/articles/$id');
      return Article.fromJson(response.data);
    } on DioError catch (e) {
      throw _handleArticlesError(e);
    }
  }

  // Récupérer catégories
  Future<List<ArticleCategory>> getCategories() async {
    try {
      final response = await _apiClient.dio.get('/articles/categories');
      final categories = response.data as List;
      return categories.map((json) => ArticleCategory.fromJson(json)).toList();
    } on DioError catch (e) {
      throw _handleArticlesError(e);
    }
  }

  // Marquer article comme lu
  Future<void> markAsRead(String articleId) async {
    try {
      await _apiClient.dio.post('/articles/$articleId/read');
    } on DioError catch (e) {
      throw _handleArticlesError(e);
    }
  }

  // Ajouter/retirer favori
  Future<void> toggleFavorite(String articleId) async {
    try {
      await _apiClient.dio.post('/articles/$articleId/favorite');
    } on DioError catch (e) {
      throw _handleArticlesError(e);
    }
  }

  // Sauvegarder progression lecture
  Future<void> saveReadingProgress(String articleId, double progress) async {
    try {
      await _apiClient.dio.post('/articles/$articleId/progress', data: {
        'progress': progress,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } on DioError catch (e) {
      throw _handleArticlesError(e);
    }
  }

  // Rechercher articles
  Future<List<Article>> searchArticles(String query, {int limit = 10}) async {
    try {
      final response = await _apiClient.dio.get('/articles/search', queryParameters: {
        'q': query,
        'limit': limit,
      });

      final articles = response.data as List;
      return articles.map((json) => Article.fromJson(json)).toList();
    } on DioError catch (e) {
      throw _handleArticlesError(e);
    }
  }

  ArticlesException _handleArticlesError(DioError error) {
    switch (error.response?.statusCode) {
      case 404:
        return ArticlesException.articleNotFound();
      case 403:
        return ArticlesException.accessDenied();
      case 429:
        return ArticlesException.rateLimited();
      default:
        return ArticlesException.unknown();
    }
  }
}

// Modèle pagination
class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = json['data'] as List;
    return PaginatedResponse(
      data: data.map((item) => fromJson(item)).toList(),
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      totalPages: json['totalPages'],
      hasNext: json['hasNext'],
      hasPrev: json['hasPrev'],
    );
  }
}
```

## 🫁 Appels API Exercices

### Service Exercices
```dart
class ExercisesApiService {
  final ApiClient _apiClient;

  ExercisesApiService(this._apiClient);

  // Récupérer exercices
  Future<List<BreathingExercise>> getExercises({
    String? category,
    Difficulty? difficulty,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (difficulty != null) queryParams['difficulty'] = difficulty.name;
      if (search != null) queryParams['search'] = search;

      final response = await _apiClient.dio.get('/exercises', queryParameters: queryParams);

      final exercises = response.data as List;
      return exercises.map((json) => BreathingExercise.fromJson(json)).toList();
    } on DioError catch (e) {
      throw _handleExercisesError(e);
    }
  }

  // Sauvegarder session
  Future<void> saveSession(BreathingSession session) async {
    try {
      await _apiClient.dio.post('/sessions', data: session.toJson());
    } on DioError catch (e) {
      // Sauvegarder localement pour sync ultérieure
      await _saveSessionLocally(session);
      throw _handleExercisesError(e);
    }
  }

  // Récupérer historique sessions
  Future<List<BreathingSession>> getSessions({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit};
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _apiClient.dio.get('/sessions', queryParameters: queryParams);

      final sessions = response.data as List;
      return sessions.map((json) => BreathingSession.fromJson(json)).toList();
    } on DioError catch (e) {
      throw _handleExercisesError(e);
    }
  }

  // Statistiques utilisateur
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await _apiClient.dio.get('/sessions/stats');
      return response.data;
    } on DioError catch (e) {
      throw _handleExercisesError(e);
    }
  }

  // Créer exercice personnalisé
  Future<BreathingExercise> createCustomExercise(CreateExerciseRequest request) async {
    try {
      final response = await _apiClient.dio.post('/exercises/custom', data: request.toJson());
      return BreathingExercise.fromJson(response.data);
    } on DioError catch (e) {
      throw _handleExercisesError(e);
    }
  }

  Future<void> _saveSessionLocally(BreathingSession session) async {
    final localStorage = getIt<LocalStorageService>();
    await localStorage.savePendingSession(session);
  }

  ExercisesException _handleExercisesError(DioError error) {
    switch (error.response?.statusCode) {
      case 400:
        return ExercisesException.invalidData();
      case 404:
        return ExercisesException.exerciseNotFound();
      default:
        return ExercisesException.unknown();
    }
  }
}
```

## 📤 Upload de Fichiers

### Service Upload
```dart
class FileUploadService {
  final ApiClient _apiClient;

  FileUploadService(this._apiClient);

  // Upload avatar
  Future<String> uploadAvatar(File imageFile) async {
    try {
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Compresser image
      final compressedFile = await _compressImage(imageFile);

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          compressedFile.path,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
        'type': 'avatar',
      });

      final response = await _apiClient.dio.post('/upload/avatar', data: formData);

      return response.data['url'];
    } on DioError catch (e) {
      throw _handleUploadError(e);
    }
  }

  // Upload fichier session (audio)
  Future<String> uploadSessionAudio(File audioFile, String sessionId) async {
    try {
      final fileName = 'session_${sessionId}_${DateTime.now().millisecondsSinceEpoch}.m4a';

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioFile.path,
          filename: fileName,
          contentType: MediaType('audio', 'm4a'),
        ),
        'sessionId': sessionId,
        'type': 'session_audio',
      });

      final response = await _apiClient.dio.post('/upload/session-audio', data: formData);

      return response.data['url'];
    } on DioError catch (e) {
      throw _handleUploadError(e);
    }
  }

  // Upload multiple fichiers
  Future<List<String>> uploadMultipleFiles(List<File> files, String type) async {
    final uploadFutures = files.map((file) => _uploadSingleFile(file, type));
    final results = await Future.wait(uploadFutures);
    return results;
  }

  Future<String> _uploadSingleFile(File file, String type) async {
    final fileName = '${type}_${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
      'type': type,
    });

    final response = await _apiClient.dio.post('/upload/file', data: formData);
    return response.data['url'];
  }

  Future<File> _compressImage(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Invalid image');

    // Redimensionner si trop grande
    final resized = img.copyResize(image, width: 800);

    // Compresser
    final compressed = img.encodeJpg(resized, quality: 85);

    final tempDir = await getTemporaryDirectory();
    final compressedFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await compressedFile.writeAsBytes(compressed);

    return compressedFile;
  }

  UploadException _handleUploadError(DioError error) {
    switch (error.response?.statusCode) {
      case 413:
        return UploadException.fileTooLarge();
      case 415:
        return UploadException.invalidFileType();
      case 422:
        return UploadException.invalidFile();
      default:
        return UploadException.unknown();
    }
  }
}
```

## 🔄 Stratégie Offline-First

### Service Synchronisation
```dart
class SyncService {
  final ApiClient _apiClient;
  final LocalStorageService _localStorage;
  final Connectivity _connectivity;

  SyncService(this._apiClient, this._localStorage, this._connectivity);

  // Synchronisation complète
  Future<void> syncAll() async {
    if (!await _connectivity.checkConnectivity()) return;

    try {
      await _syncPendingSessions();
      await _syncPendingProgress();
      await _syncPendingFavorites();
      await _syncUserData();

      debugPrint('✅ Synchronisation terminée');
    } catch (e) {
      debugPrint('❌ Erreur synchronisation: $e');
    }
  }

  // Sync sessions en attente
  Future<void> _syncPendingSessions() async {
    final pendingSessions = await _localStorage.getPendingSessions();

    for (final session in pendingSessions) {
      try {
        await _apiClient.dio.post('/sessions', data: session.toJson());
        await _localStorage.removePendingSession(session.id);
      } catch (e) {
        debugPrint('Erreur sync session ${session.id}: $e');
      }
    }
  }

  // Sync progression lecture
  Future<void> _syncPendingProgress() async {
    final pendingProgress = await _localStorage.getPendingProgress();

    for (final progress in pendingProgress) {
      try {
        await _apiClient.dio.post('/articles/${progress.articleId}/progress', data: {
          'progress': progress.progress,
          'timestamp': progress.timestamp.toIso8601String(),
        });
        await _localStorage.removePendingProgress(progress.articleId);
      } catch (e) {
        debugPrint('Erreur sync progression ${progress.articleId}: $e');
      }
    }
  }

  // Sync favoris
  Future<void> _syncPendingFavorites() async {
    final pendingFavorites = await _localStorage.getPendingFavorites();

    for (final favorite in pendingFavorites) {
      try {
        await _apiClient.dio.post('/articles/${favorite.articleId}/favorite', data: {
          'isFavorite': favorite.isFavorite,
        });
        await _localStorage.removePendingFavorite(favorite.articleId);
      } catch (e) {
        debugPrint('Erreur sync favori ${favorite.articleId}: $e');
      }
    }
  }

  // Sync données utilisateur
  Future<void> _syncUserData() async {
    try {
      final localProfile = await _localStorage.getLocalProfile();
      if (localProfile != null) {
        await _apiClient.dio.put('/user/profile', data: localProfile.toJson());
      }
    } catch (e) {
      debugPrint('Erreur sync profil: $e');
    }
  }

  // Sync périodique
  void startPeriodicSync() {
    Timer.periodic(const Duration(minutes: 15), (timer) async {
      if (await _connectivity.checkConnectivity()) {
        await syncAll();
      }
    });
  }

  // Sync à la connexion
  void startConnectivitySync() {
    _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        syncAll();
      }
    });
  }
}
```

## 🔔 Notifications Push

### Service Notifications
```dart
class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging;
  final LocalNotificationService _localNotifications;
  final ApiClient _apiClient;

  PushNotificationService(
    this._firebaseMessaging,
    this._localNotifications,
    this._apiClient,
  );

  Future<void> initialize() async {
    // Demander permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Récupérer token FCM
      final fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        await _registerToken(fcmToken);
      }

      // Écouter changements token
      _firebaseMessaging.onTokenRefresh.listen(_registerToken);

      // Configurer handlers
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessageStatic);
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      await _apiClient.dio.post('/notifications/register-token', data: {
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      });
    } catch (e) {
      debugPrint('Erreur enregistrement token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Afficher notification locale
    _localNotifications.showNotification(
      title: message.notification?.title ?? 'CESIZen',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    // Navigation selon type notification
    final type = message.data['type'];
    switch (type) {
      case 'article':
        navigatorKey.currentState?.pushNamed('/article-detail', arguments: message.data['articleId']);
        break;
      case 'exercise':
        navigatorKey.currentState?.pushNamed('/exercise-detail', arguments: message.data['exerciseId']);
        break;
      case 'reminder':
        navigatorKey.currentState?.pushNamed('/breathing-session', arguments: message.data['exerciseId']);
        break;
    }
  }

  // Planifier rappel local
  Future<void> scheduleReminder({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await _localNotifications.scheduleNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      payload: payload,
    );
  }

  // Annuler rappels
  Future<void> cancelAllReminders() async {
    await _localNotifications.cancelAll();
  }

  // Vérifier statut permission
  Future<bool> hasPermission() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}

// Handler statique pour background
Future<void> _handleBackgroundMessageStatic(RemoteMessage message) async {
  // Logique pour messages en background
  debugPrint('Message background: ${message.messageId}');
}
```

## 🧪 Tests d'Intégration

### Tests API
```dart
void main() {
  group('API Integration Tests', () {
    late Dio mockDio;
    late ApiClient apiClient;

    setUp(() {
      mockDio = Dio();
      apiClient = ApiClient(MockTokenStorage());
      // Remplacer dio avec mock
      apiClient._dio = mockDio;
    });

    test('should handle successful login', () async {
      // Mock response
      when(mockDio.post('/auth/login', data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                data: {
                  'accessToken': 'token',
                  'refreshToken': 'refresh',
                  'user': {'id': '1', 'email': 'test@example.com'}
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: '/auth/login'),
              ));

      final authService = AuthApiService(apiClient);
      final result = await authService.login(LoginRequest(
        email: 'test@example.com',
        password: 'password',
      ));

      expect(result.accessToken, 'token');
      expect(result.user.email, 'test@example.com');
    });

    test('should handle network timeout', () async {
      when(mockDio.post('/auth/login', data: anyNamed('data')))
          .thenThrow(DioError(
            type: DioErrorType.connectTimeout,
            requestOptions: RequestOptions(path: '/auth/login'),
          ));

      final authService = AuthApiService(apiClient);

      expect(
        () => authService.login(LoginRequest(
          email: 'test@example.com',
          password: 'password',
        )),
        throwsA(isA<NetworkTimeoutException>()),
      );
    });
  });
}
```

---

*Dernière mise à jour: 21 avril 2026*
