import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:news_app/models/article_model.dart';
import 'package:news_app/services/news_service.dart';

class NewsRepository {
  final NewsService _service;
  final SharedPreferences prefs;
  static const _bookmarksKey = 'bookmarks_';

  NewsRepository(this._service, {required this.prefs});
  
  get country_ => null;
  
  get category_ => null;
  
  get query_ => null;

  Future<List<Article>> getTopHeadlines(String country, {int page = 1}) async {
    try {
      return await _service.getTopHeadlines(country, page: page);
    } catch (e) {
      final cached = _getCachedArticles('top_$country_$page');
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<List<Article>> getNewsByCategory(String category, {int page = 1}) async {
    try {
      return await _service.getNewsByCategory(category, page: page);
    } catch (e) {
      final cached = _getCachedArticles('category_$category_$page');
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<List<Article>> searchNews(String query, {int page = 1}) async {
    try {
      return await _service.searchNews(query, page: page);
    } catch (e) {
      final cached = _getCachedArticles('search_$query_$page');
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<List<String>> getNewsSources() async {
    try {
      return await _service.getNewsSources();
    } catch (e) {
      return [];
    }
  }

  List<Article> _getCachedArticles(String key) {
    final cachedJson = prefs.getString(key);
    if (cachedJson != null) {
      final list = jsonDecode(cachedJson) as List;
      return list.map((e) => Article.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> clearCache() async {
    await prefs.clear();
  }

  Future<List<Article>> getBookmarkArticles(String userId) async {
    final key = _bookmarksKey + userId;
    final bookmarksJson = prefs.getStringList(key) ?? [];
    return bookmarksJson
        .map((json) => Article.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> addBookmark(String userId, Article article) async {
    final key = _bookmarksKey + userId;
    final bookmarksJson = prefs.getStringList(key) ?? [];
    bookmarksJson.add(jsonEncode(article.toJson()));
    await prefs.setStringList(key, bookmarksJson);
  }

  Future<void> removeBookmark(String userId, String articleId) async {
    final key = _bookmarksKey + userId;
    final bookmarksJson = prefs.getStringList(key) ?? [];
    final updatedBookmarks = bookmarksJson
        .where((json) => jsonDecode(json)['id'] != articleId)
        .toList();
    await prefs.setStringList(key, updatedBookmarks);
  }
}