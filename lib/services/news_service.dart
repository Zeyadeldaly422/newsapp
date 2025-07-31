import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:news_app/models/article_model.dart';
import 'dart:convert';

class NewsService {
  final Dio _dio;
  final String apiKey;
  final SharedPreferences prefs;
  static const _baseUrl = 'https://newsapi.org/v2/';
  static const _cacheKey = 'news_cache';
  static const _cacheExpiry = 30 * 60 * 1000; // 30 minutes in milliseconds

  NewsService(this._dio, {required this.apiKey, required this.prefs}) {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(milliseconds: 30000),
      receiveTimeout: const Duration(milliseconds: 30000),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        return handler.next(options);
      },
      onError: (e, handler) {
        if (e.response?.statusCode == 429) {
          return handler.resolve(Response(
            data: {'message': 'Rate limit exceeded'},
            statusCode: 429,
            requestOptions: e.requestOptions,
          ));
        }
        return handler.next(e);
      },
    ));
  }

  Future<List<Article>> _fetchFromApi(String endpoint, Map<String, dynamic> params) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: params);
      if (response.statusCode == 200) {
        final data = response.data;
        final articles = (data['articles'] as List)
            .map((json) => Article.fromJson(json))
            .toList();
        _cacheResponse(endpoint, params, articles);
        return articles;
      }
      throw Exception('Failed to load data: ${response.statusCode}');
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  void _cacheResponse(String endpoint, Map<String, dynamic> params, List<Article> articles) {
    final cacheEntry = {
      'endpoint': endpoint,
      'params': params,
      'articles': articles.map((a) => a.toJson()).toList(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    final cacheList = prefs.getStringList(_cacheKey) ?? [];
    cacheList.add(jsonEncode(cacheEntry));
    prefs.setStringList(_cacheKey, cacheList);
  }

  List<Article> _getCachedResponse(String endpoint, Map<String, dynamic> params) {
    final cacheList = prefs.getStringList(_cacheKey) ?? [];
    final cached = cacheList
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .where((e) =>
            e['endpoint'] == endpoint &&
            Map<String, dynamic>.from(e['params']) == params &&
            DateTime.now().millisecondsSinceEpoch - e['timestamp'] < _cacheExpiry)
        .toList();
    if (cached.isNotEmpty) {
      return (cached.first['articles'] as List)
          .map((json) => Article.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<List<Article>> getTopHeadlines(String country, {int page = 1}) async {
    const endpoint = 'top-headlines';
    final params = {'country': country, 'page': page, 'pageSize': 10};
    final cached = _getCachedResponse(endpoint, params);
    if (cached.isNotEmpty) return cached;

    return await _fetchFromApi(endpoint, params).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception('Request timed out');
      },
    );
  }

  Future<List<Article>> getNewsByCategory(String category, {int page = 1}) async {
    const endpoint = 'top-headlines';
    final params = {'category': category, 'page': page, 'pageSize': 10};
    final cached = _getCachedResponse(endpoint, params);
    if (cached.isNotEmpty) return cached;

    return await _fetchFromApi(endpoint, params).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception('Request timed out');
      },
    );
  }

  Future<List<Article>> searchNews(String query, {int page = 1}) async {
    const endpoint = 'everything';
    final params = {'q': query, 'page': page, 'pageSize': 10};
    final cached = _getCachedResponse(endpoint, params);
    if (cached.isNotEmpty) return cached;

    return await _fetchFromApi(endpoint, params).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception('Request timed out');
      },
    );
  }

  Future<List<String>> getNewsSources() async {
    try {
      final response = await _dio.get('sources');
      if (response.statusCode == 200) {
        return (response.data['sources'] as List)
            .map((e) => e['name'] as String)
            .toList();
      }
      throw Exception('Failed to load sources');
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }
}