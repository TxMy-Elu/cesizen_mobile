# 📚 Gestion des Articles - CESIZen Mobile

## 🎯 Vue d'Ensemble

Le module Articles permet aux utilisateurs de consulter du contenu éducatif sur la prévention santé, avec recherche avancée et système de favoris.

### Fonctionnalités Clés
- ✅ Liste paginée d'articles
- ✅ Recherche en temps réel
- ✅ Filtres par catégorie
- ✅ Système de favoris
- ✅ Lecture hors-ligne
- ✅ Suivi progression lecture

## 📊 Modèle de Données

### Article
```dart
class Article {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String author;
  final DateTime publishedAt;
  final String category;
  final List<String> tags;
  final String imageUrl;
  final int readTime; // en minutes
  final bool isPremium;
  final int viewCount;
  final double rating;

  // État local
  bool isRead;
  bool isFavorite;
  double readProgress; // 0.0 à 1.0
}
```

### Catégorie
```dart
class ArticleCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final Color color;
  final int articleCount;
}
```

## 🎨 Écran Liste Articles

### Wireframe Description
```
┌─────────────────────────────────┐
│  ← Articles                     │
│  ┌─────────────────────────┐    │
│  │ 🔍 Rechercher...        │    │
│  └─────────────────────────┘    │
│                                 │
│  📂 Catégories ▼                │
│  ┌─────────────────────────┐    │
│  │ 🏃‍♂️ Sport & Santé       │    │
│  │ 🧠 Mental & Bien-être    │    │
│  │ 🥗 Nutrition             │    │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │ [Image] Titre article    │    │
│  │ Résumé...                │    │
│  │ ⭐ 4.5 • 5 min • ♥       │    │
│  └─────────────────────────┘    │
│                                 │
│  [Charger plus...]              │
└─────────────────────────────────┘
```

### Implémentation Liste
```dart
class ArticlesListScreen extends StatefulWidget {
  const ArticlesListScreen({Key? key}) : super(key: key);

  @override
  _ArticlesListScreenState createState() => _ArticlesListScreenState();
}

class _ArticlesListScreenState extends State<ArticlesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Article> _articles = [];
  List<ArticleCategory> _categories = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _selectedCategoryId;
  String _searchQuery = '';
  int _currentPage = 1;
  bool _hasMorePages = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadArticles();

    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await context.read<ArticlesProvider>().getCategories();
      setState(() => _categories = categories);
    } catch (e) {
      _showErrorSnackBar('Erreur chargement catégories');
    }
  }

  Future<void> _loadArticles({bool loadMore = false}) async {
    if (_isLoading || _isLoadingMore) return;

    setState(() {
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
        _currentPage = 1;
        _hasMorePages = true;
      }
    });

    try {
      final articlesProvider = context.read<ArticlesProvider>();
      final newArticles = await articlesProvider.getArticles(
        page: loadMore ? _currentPage + 1 : 1,
        categoryId: _selectedCategoryId,
        searchQuery: _searchQuery,
      );

      setState(() {
        if (loadMore) {
          _articles.addAll(newArticles);
          _currentPage++;
        } else {
          _articles = newArticles;
        }

        _hasMorePages = newArticles.length >= 20; // Page size
      });
    } catch (e) {
      _showErrorSnackBar('Erreur chargement articles');
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMorePages && !_isLoadingMore) {
        _loadArticles(loadMore: true);
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query != _searchQuery) {
      setState(() => _searchQuery = query);
      _debounceSearch();
    }
  }

  Timer? _searchTimer;
  void _debounceSearch() {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      _loadArticles();
    });
  }

  void _onCategoryChanged(String? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    _loadArticles();
  }

  void _toggleFavorite(Article article) async {
    try {
      final articlesProvider = context.read<ArticlesProvider>();
      await articlesProvider.toggleFavorite(article.id);

      setState(() {
        article.isFavorite = !article.isFavorite;
      });
    } catch (e) {
      _showErrorSnackBar('Erreur mise à jour favori');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher des articles...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Filtres catégories
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(
                  label: const Text('Tous'),
                  selected: _selectedCategoryId == null,
                  onSelected: (_) => _onCategoryChanged(null),
                ),
                const SizedBox(width: 8),
                ..._categories.map((category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category.name),
                    selected: _selectedCategoryId == category.id,
                    onSelected: (_) => _onCategoryChanged(category.id),
                  ),
                )),
              ],
            ),
          ),

          // Liste articles
          Expanded(
            child: _isLoading && _articles.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _articles.isEmpty
                    ? const Center(
                        child: Text('Aucun article trouvé'),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _articles.length + (_hasMorePages ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _articles.length) {
                            return _isLoadingMore
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : TextButton(
                                    onPressed: () => _loadArticles(loadMore: true),
                                    child: const Text('Charger plus'),
                                  );
                          }

                          final article = _articles[index];
                          return ArticleCard(
                            article: article,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/article-detail',
                              arguments: article,
                            ),
                            onFavoriteToggle: () => _toggleFavorite(article),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
```

## 🃏 Composant Carte Article

### ArticleCard Widget
```dart
class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const ArticleCard({
    Key? key,
    required this.article,
    required this.onTap,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image article
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: article.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.article),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Résumé
                    Text(
                      article.summary,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Métadonnées
                    Row(
                      children: [
                        // Rating
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              article.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),

                        const SizedBox(width: 12),

                        // Temps de lecture
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${article.readTime} min',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Indicateur premium
                        if (article.isPremium) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'PREMIUM',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Bouton favori
                        IconButton(
                          icon: Icon(
                            article.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: article.isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: onFavoriteToggle,
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),

                    // Barre de progression si commencé
                    if (article.readProgress > 0) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: article.readProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 📖 Écran Détail Article

### Wireframe Détail
```
┌─────────────────────────────────┐
│  ← Titre Article                │
│                                 │
│  [Image couverture]             │
│                                 │
│  Résumé article...              │
│                                 │
│  ──────────────────────────     │
│                                 │
│  Contenu complet de l'article   │
│  avec mise en forme riche...    │
│                                 │
│  [Progression: ████████░░░░]    │
│                                 │
│  ♥ Favori • 🔗 Partager         │
└─────────────────────────────────┘
```

### Implémentation Détail
```dart
class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({Key? key, required this.article}) : super(key: key);

  @override
  _ArticleDetailScreenState createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  double _readProgress = 0.0;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _readProgress = widget.article.readProgress;
    _isBookmarked = widget.article.isFavorite;

    _scrollController.addListener(_updateReadProgress);
  }

  void _updateReadProgress() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll > 0) {
      final progress = currentScroll / maxScroll;
      setState(() => _readProgress = progress.clamp(0.0, 1.0));

      // Sauvegarder progression
      _saveReadProgress();
    }
  }

  Future<void> _saveReadProgress() async {
    try {
      final articlesProvider = context.read<ArticlesProvider>();
      await articlesProvider.updateReadProgress(widget.article.id, _readProgress);
    } catch (e) {
      // Gestion erreur silencieuse
    }
  }

  Future<void> _toggleBookmark() async {
    try {
      final articlesProvider = context.read<ArticlesProvider>();
      await articlesProvider.toggleFavorite(widget.article.id);

      setState(() => _isBookmarked = !_isBookmarked);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBookmarked ? 'Ajouté aux favoris' : 'Retiré des favoris'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur mise à jour favori')),
      );
    }
  }

  Future<void> _shareArticle() async {
    final text = '${widget.article.title}\n\n${widget.article.summary}';
    await Share.share(text, subject: widget.article.title);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App bar avec image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.article.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[300]),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                  // Overlay dégradé
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                onPressed: _toggleBookmark,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareArticle,
              ),
            ],
          ),

          // Contenu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    widget.article.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Métadonnées
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey[300],
                        child: Text(widget.article.author[0].toUpperCase()),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.article.author,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _formatDate(widget.article.publishedAt),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16),
                          const SizedBox(width: 4),
                          Text('${widget.article.readTime} min'),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Tags
                  Wrap(
                    spacing: 8,
                    children: widget.article.tags.map((tag) => Chip(
                      label: Text(tag),
                      backgroundColor: Colors.blue[50],
                    )).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Résumé
                  Text(
                    widget.article.summary,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Barre de progression
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progression: ${(_readProgress * 100).round()}%',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _readProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Contenu
                  HtmlWidget(
                    widget.article.content,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _toggleBookmark,
                        icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                        label: Text(_isBookmarked ? 'Favori' : 'Ajouter favori'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _shareArticle,
                        icon: const Icon(Icons.share),
                        label: const Text('Partager'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
```

## 🔄 Provider Articles

### ArticlesProvider
```dart
class ArticlesProvider extends ChangeNotifier {
  final ArticlesRepository _repository;
  final LocalStorageService _localStorage;

  List<Article> _articles = [];
  List<ArticleCategory> _categories = [];
  bool _isLoading = false;

  ArticlesProvider(this._repository, this._localStorage);

  // Getters
  List<Article> get articles => _articles;
  List<ArticleCategory> get categories => _categories;
  bool get isLoading => _isLoading;

  // Charger catégories
  Future<List<ArticleCategory>> getCategories() async {
    try {
      _categories = await _repository.getCategories();
      notifyListeners();
      return _categories;
    } catch (e) {
      // Retourner cache local si disponible
      final cached = await _localStorage.getCachedCategories();
      if (cached.isNotEmpty) {
        _categories = cached;
        notifyListeners();
        return cached;
      }
      rethrow;
    }
  }

  // Charger articles avec filtres
  Future<List<Article>> getArticles({
    int page = 1,
    String? categoryId,
    String? searchQuery,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final articles = await _repository.getArticles(
        page: page,
        categoryId: categoryId,
        searchQuery: searchQuery,
      );

      // Fusionner avec données locales (favoris, progression)
      final enrichedArticles = await _enrichArticlesWithLocalData(articles);

      if (page == 1) {
        _articles = enrichedArticles;
      } else {
        _articles.addAll(enrichedArticles);
      }

      // Cache pour offline
      await _localStorage.cacheArticles(enrichedArticles);

      return enrichedArticles;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Enrichir avec données locales
  Future<List<Article>> _enrichArticlesWithLocalData(List<Article> articles) async {
    final favorites = await _localStorage.getFavoriteArticleIds();
    final progressMap = await _localStorage.getReadProgressMap();

    return articles.map((article) {
      return article.copyWith(
        isFavorite: favorites.contains(article.id),
        readProgress: progressMap[article.id] ?? 0.0,
      );
    }).toList();
  }

  // Toggle favori
  Future<void> toggleFavorite(String articleId) async {
    await _localStorage.toggleFavorite(articleId);
    // Mettre à jour liste locale
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      final article = _articles[index];
      _articles[index] = article.copyWith(isFavorite: !article.isFavorite);
      notifyListeners();
    }
  }

  // Mettre à jour progression
  Future<void> updateReadProgress(String articleId, double progress) async {
    await _localStorage.saveReadProgress(articleId, progress);
    // Mettre à jour liste locale
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      final article = _articles[index];
      _articles[index] = article.copyWith(readProgress: progress);
      notifyListeners();
    }
  }

  // Recherche locale (offline)
  Future<List<Article>> searchLocalArticles(String query) async {
    final cachedArticles = await _localStorage.getCachedArticles();
    final lowercaseQuery = query.toLowerCase();

    return cachedArticles.where((article) {
      return article.title.toLowerCase().contains(lowercaseQuery) ||
             article.summary.toLowerCase().contains(lowercaseQuery) ||
             article.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }
}
```

## 🧪 Tests Articles

### Tests Unitaires
```dart
void main() {
  group('ArticlesProvider', () {
    test('should load articles successfully', () async {
      final mockRepo = MockArticlesRepository();
      final mockStorage = MockLocalStorageService();
      final provider = ArticlesProvider(mockRepo, mockStorage);

      when(mockRepo.getArticles()).thenAnswer((_) async => [mockArticle]);

      final articles = await provider.getArticles();

      expect(articles.length, 1);
      expect(articles.first.id, mockArticle.id);
    });

    test('should toggle favorite status', () async {
      final mockStorage = MockLocalStorageService();
      final provider = ArticlesProvider(mockRepo, mockStorage);

      when(mockStorage.toggleFavorite('article1')).thenAnswer((_) async => true);

      await provider.toggleFavorite('article1');

      verify(mockStorage.toggleFavorite('article1')).called(1);
    });
  });
}
```

---

*Dernière mise à jour: 21 avril 2026*
