# 📂 Navigation par Catégories - CESIZen Mobile

## 🎯 Vue d'Ensemble

Le système de catégories permet une navigation intuitive et organisée du contenu, avec filtres avancés et hiérarchie claire.

### Fonctionnalités Clés
- ✅ Arborescence catégories
- ✅ Navigation par onglets
- ✅ Filtres combinés
- ✅ Statistiques par catégorie
- ✅ Interface adaptative

## 📊 Modèle de Données Catégories

### Catégorie
```dart
class ArticleCategory {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final Color color;
  final String? parentId; // Pour hiérarchie
  final int articleCount;
  final int totalReadTime; // Minutes totales
  final DateTime lastUpdated;
  final bool isActive;

  // Statistiques utilisateur
  final int userReadCount;
  final double userProgress; // 0.0 à 1.0
  final bool isFavorite;
}
```

### Filtre
```dart
class CategoryFilter {
  final String? categoryId;
  final DateRange? dateRange;
  final SortOrder sortOrder;
  final bool onlyUnread;
  final bool onlyFavorites;
  final List<String> tags;
  final Difficulty? difficulty;

  CategoryFilter({
    this.categoryId,
    this.dateRange,
    this.sortOrder = SortOrder.newest,
    this.onlyUnread = false,
    this.onlyFavorites = false,
    this.tags = const [],
    this.difficulty,
  });
}

enum SortOrder { newest, oldest, mostRead, rating, readTime }
enum Difficulty { beginner, intermediate, advanced }
```

## 🎨 Écran Catégories

### Wireframe Navigation
```
┌─────────────────────────────────┐
│  📂 Catégories                  │
│                                 │
│  ┌─────────────────────────┐    │
│  │ 🏃‍♂️ Sport & Santé (12)   │    │
│  │     Articles lus: 8/12       │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │ 🧠 Mental & Bien-être (8) │    │
│  │     Articles lus: 3/8        │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │ 🥗 Nutrition (15)        │    │
│  │     Articles lus: 10/15      │
│  └─────────────────────────┘    │
│                                 │
│  [Voir toutes les catégories]   │
└─────────────────────────────────┘
```

### Implémentation Écran Principal
```dart
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<ArticleCategory> _categories = [];
  bool _isLoading = false;
  CategoryFilter _currentFilter = CategoryFilter();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);

    try {
      final categoriesProvider = context.read<CategoriesProvider>();
      _categories = await categoriesProvider.getCategories();

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur chargement catégories')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Explorer', icon: Icon(Icons.explore)),
            Tab(text: 'Mes Favoris', icon: Icon(Icons.favorite)),
            Tab(text: 'Progression', icon: Icon(Icons.trending_up)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildExploreTab(),
                _buildFavoritesTab(),
                _buildProgressTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterDialog,
        child: const Icon(Icons.filter_list),
      ),
    );
  }

  Widget _buildExploreTab() {
    final topCategories = _categories.where((c) => c.parentId == null).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: topCategories.length,
      itemBuilder: (context, index) {
        final category = topCategories[index];
        return CategoryCard(
          category: category,
          onTap: () => _navigateToCategory(category),
          showProgress: true,
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    final favoriteCategories = _categories.where((c) => c.isFavorite).toList();

    return favoriteCategories.isEmpty
        ? const Center(
            child: Text('Aucune catégorie favorite'),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteCategories.length,
            itemBuilder: (context, index) {
              final category = favoriteCategories[index];
              return CategoryCard(
                category: category,
                onTap: () => _navigateToCategory(category),
                showProgress: true,
              );
            },
          );
  }

  Widget _buildProgressTab() {
    final sortedCategories = _categories
        .where((c) => c.userReadCount > 0)
        .toList()
      ..sort((a, b) => b.userProgress.compareTo(a.userProgress));

    return sortedCategories.isEmpty
        ? const Center(
            child: Text('Commencez à lire pour voir votre progression'),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedCategories.length,
            itemBuilder: (context, index) {
              final category = sortedCategories[index];
              return CategoryCard(
                category: category,
                onTap: () => _navigateToCategory(category),
                showProgress: true,
                highlightProgress: true,
              );
            },
          );
  }

  void _navigateToCategory(ArticleCategory category) {
    Navigator.pushNamed(
      context,
      '/category-articles',
      arguments: {'category': category, 'filter': _currentFilter},
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => CategoryFilterSheet(
        currentFilter: _currentFilter,
        categories: _categories,
        onFilterChanged: (filter) {
          setState(() => _currentFilter = filter);
          Navigator.pop(context);
        },
      ),
    );
  }
}
```

## 🃏 Composants Catégories

### CategoryCard Widget
```dart
class CategoryCard extends StatelessWidget {
  final ArticleCategory category;
  final VoidCallback onTap;
  final bool showProgress;
  final bool highlightProgress;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.onTap,
    this.showProgress = false,
    this.highlightProgress = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: highlightProgress ? 4 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                category.color.withOpacity(0.1),
                category.color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec icône et titre
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconData(category.iconName),
                      color: category.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${category.articleCount} articles',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (category.isFavorite)
                    Icon(
                      Icons.favorite,
                      color: Colors.red[400],
                      size: 20,
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                category.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (showProgress) ...[
                const SizedBox(height: 16),

                // Barre de progression
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progression',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${category.userReadCount}/${category.articleCount}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: category.userProgress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        highlightProgress ? Colors.green : category.color,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'sports':
        return Icons.sports;
      case 'psychology':
        return Icons.psychology;
      case 'restaurant':
        return Icons.restaurant;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'health_and_safety':
        return Icons.health_and_safety;
      default:
        return Icons.category;
    }
  }
}
```

## 🔍 Système de Filtres

### CategoryFilterSheet Widget
```dart
class CategoryFilterSheet extends StatefulWidget {
  final CategoryFilter currentFilter;
  final List<ArticleCategory> categories;
  final Function(CategoryFilter) onFilterChanged;

  const CategoryFilterSheet({
    Key? key,
    required this.currentFilter,
    required this.categories,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  _CategoryFilterSheetState createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<CategoryFilterSheet> {
  late CategoryFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Row(
            children: [
              const Text(
                'Filtres',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() => _filter = CategoryFilter());
                },
                child: const Text('Réinitialiser'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Catégorie
          const Text(
            'Catégorie',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            value: _filter.categoryId,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('Toutes les catégories'),
              ),
              ...widget.categories.map((category) => DropdownMenuItem(
                value: category.id,
                child: Text(category.name),
              )),
            ],
            onChanged: (value) {
              setState(() => _filter = _filter.copyWith(categoryId: value));
            },
          ),

          const SizedBox(height: 16),

          // Tri
          const Text(
            'Trier par',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<SortOrder>(
            value: _filter.sortOrder,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            items: SortOrder.values.map((order) => DropdownMenuItem(
              value: order,
              child: Text(_getSortOrderText(order)),
            )).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _filter = _filter.copyWith(sortOrder: value));
              }
            },
          ),

          const SizedBox(height: 16),

          // Filtres booléens
          SwitchListTile(
            title: const Text('Articles non lus uniquement'),
            value: _filter.onlyUnread,
            onChanged: (value) {
              setState(() => _filter = _filter.copyWith(onlyUnread: value));
            },
          ),

          SwitchListTile(
            title: const Text('Favoris uniquement'),
            value: _filter.onlyFavorites,
            onChanged: (value) {
              setState(() => _filter = _filter.copyWith(onlyFavorites: value));
            },
          ),

          const SizedBox(height: 24),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onFilterChanged(_filter),
                  child: const Text('Appliquer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSortOrderText(SortOrder order) {
    switch (order) {
      case SortOrder.newest:
        return 'Plus récent';
      case SortOrder.oldest:
        return 'Plus ancien';
      case SortOrder.mostRead:
        return 'Plus lu';
      case SortOrder.rating:
        return 'Meilleur note';
      case SortOrder.readTime:
        return 'Temps de lecture';
    }
  }
}
```

## 📱 Écran Articles par Catégorie

### Implémentation Détail Catégorie
```dart
class CategoryArticlesScreen extends StatefulWidget {
  final ArticleCategory category;
  final CategoryFilter filter;

  const CategoryArticlesScreen({
    Key? key,
    required this.category,
    required this.filter,
  }) : super(key: key);

  @override
  _CategoryArticlesScreenState createState() => _CategoryArticlesScreenState();
}

class _CategoryArticlesScreenState extends State<CategoryArticlesScreen> {
  List<Article> _articles = [];
  bool _isLoading = false;
  bool _hasMorePages = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles({bool loadMore = false}) async {
    if (_isLoading) return;

    setState(() {
      if (loadMore) {
        // Loading more
      } else {
        _isLoading = true;
        _currentPage = 1;
      }
    });

    try {
      final articlesProvider = context.read<ArticlesProvider>();
      final articles = await articlesProvider.getArticlesByCategory(
        categoryId: widget.category.id,
        filter: widget.filter,
        page: loadMore ? _currentPage + 1 : 1,
      );

      setState(() {
        if (loadMore) {
          _articles.addAll(articles);
          _currentPage++;
        } else {
          _articles = articles;
        }
        _hasMorePages = articles.length >= 20;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur chargement articles')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête catégorie
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: widget.category.color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _getIconData(widget.category.iconName),
                  size: 48,
                  color: widget.category.color,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.category.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.category.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                // Statistiques
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStat('${widget.category.articleCount}', 'Articles'),
                    const SizedBox(width: 24),
                    _buildStat(
                      '${widget.category.userReadCount}/${widget.category.articleCount}',
                      'Lus',
                    ),
                    const SizedBox(width: 24),
                    _buildStat(
                      '${(widget.category.userProgress * 100).round()}%',
                      'Progression',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Liste articles
          Expanded(
            child: _isLoading && _articles.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _articles.isEmpty
                    ? const Center(
                        child: Text('Aucun article dans cette catégorie'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _articles.length + (_hasMorePages ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _articles.length) {
                            return TextButton(
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

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
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

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => CategoryFilterSheet(
        currentFilter: widget.filter,
        categories: [], // Non utilisé ici
        onFilterChanged: (filter) {
          Navigator.pop(context);
          // Recharger avec nouveau filtre
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryArticlesScreen(
                category: widget.category,
                filter: filter,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _toggleFavorite(Article article) async {
    try {
      final articlesProvider = context.read<ArticlesProvider>();
      await articlesProvider.toggleFavorite(article.id);

      setState(() {
        article.isFavorite = !article.isFavorite;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur mise à jour favori')),
      );
    }
  }

  IconData _getIconData(String iconName) {
    // Même implémentation que CategoryCard
    return Icons.category; // Placeholder
  }
}
```

## 🔄 Provider Catégories

### CategoriesProvider
```dart
class CategoriesProvider extends ChangeNotifier {
  final CategoriesRepository _repository;
  final LocalStorageService _localStorage;

  List<ArticleCategory> _categories = [];
  bool _isLoading = false;

  CategoriesProvider(this._repository, this._localStorage);

  List<ArticleCategory> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<List<ArticleCategory>> getCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _repository.getCategories();

      // Enrichir avec données locales
      _categories = await _enrichCategoriesWithLocalData(_categories);

      return _categories;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ArticleCategory>> _enrichCategoriesWithLocalData(
    List<ArticleCategory> categories,
  ) async {
    final userStats = await _localStorage.getUserCategoryStats();

    return categories.map((category) {
      final stats = userStats[category.id];
      return category.copyWith(
        userReadCount: stats?['readCount'] ?? 0,
        userProgress: stats?['progress'] ?? 0.0,
        isFavorite: stats?['isFavorite'] ?? false,
      );
    }).toList();
  }

  Future<void> toggleCategoryFavorite(String categoryId) async {
    await _localStorage.toggleCategoryFavorite(categoryId);

    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index != -1) {
      final category = _categories[index];
      _categories[index] = category.copyWith(
        isFavorite: !category.isFavorite,
      );
      notifyListeners();
    }
  }

  Future<List<ArticleCategory>> getFavoriteCategories() async {
    return _categories.where((c) => c.isFavorite).toList();
  }

  Future<List<ArticleCategory>> getCategoriesByProgress() async {
    final sorted = List<ArticleCategory>.from(_categories)
      ..sort((a, b) => b.userProgress.compareTo(a.userProgress));

    return sorted.where((c) => c.userReadCount > 0).toList();
  }
}
```

## 🧪 Tests Catégories

### Tests Unitaires
```dart
void main() {
  group('CategoriesProvider', () {
    test('should load categories successfully', () async {
      final mockRepo = MockCategoriesRepository();
      final mockStorage = MockLocalStorageService();
      final provider = CategoriesProvider(mockRepo, mockStorage);

      when(mockRepo.getCategories()).thenAnswer((_) async => [mockCategory]);

      final categories = await provider.getCategories();

      expect(categories.length, 1);
      expect(categories.first.id, mockCategory.id);
    });

    test('should toggle favorite status', () async {
      final mockStorage = MockLocalStorageService();
      final provider = CategoriesProvider(mockRepo, mockStorage);

      await provider.toggleCategoryFavorite('category1');

      verify(mockStorage.toggleCategoryFavorite('category1')).called(1);
    });
  });
}
```

---

*Dernière mise à jour: 21 avril 2026*
