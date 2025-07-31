import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/models/article_model.dart';
import 'package:news_app/repositories/news_repository.dart';
import 'package:news_app/cubits/news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsRepository _repository;
  String userId;

  NewsCubit(this._repository, {this.userId = ''}) : super(NewsInitial());

  Future<void> fetchTopHeadlines(String country, {bool isRefresh = false}) async {
    if (state is NewsLoading && !isRefresh) return;
    if (isRefresh) emit(NewsRefreshing());
    try {
      final articles = await _repository.getTopHeadlines(country);
      emit(NewsLoaded(articles, hasMore: articles.length >= 10, currentPage: 1));
    } catch (e) {
      emit(NewsError(e.toString(), canRetry: true));
    }
  }

  Future<void> fetchMoreHeadlines(String country, int page) async {
    if (state is! NewsLoaded) return;
    final currentState = state as NewsLoaded;
    if (!currentState.hasMore) return;
    emit(NewsLoading());
    try {
      final newArticles = await _repository.getTopHeadlines(country, page: page);
      final updatedArticles = [...currentState.articles, ...newArticles];
      emit(NewsLoaded(updatedArticles, hasMore: newArticles.length >= 10, currentPage: page));
    } catch (e) {
      emit(NewsError(e.toString(), canRetry: true));
    }
  }

  Future<void> fetchNewsByCategory(String category) async {
    emit(NewsLoading());
    try {
      final articles = await _repository.getNewsByCategory(category);
      emit(NewsLoaded(articles, hasMore: articles.length >= 10, currentPage: 1));
    } catch (e) {
      emit(NewsError(e.toString(), canRetry: true));
    }
  }

  Future<void> searchNews(String query) async {
    emit(NewsLoading());
    try {
      final articles = await _repository.searchNews(query);
      if (articles.isEmpty) {
        emit(NewsEmpty('No results found'));
      } else {
        emit(NewsLoaded(articles, hasMore: false, currentPage: 1));
      }
    } catch (e) {
      emit(NewsError(e.toString(), canRetry: true));
    }
  }

  Future<List<String>> getNewsSources() async {
    try {
      return await _repository.getNewsSources();
    } catch (e) {
      emit(NewsError(e.toString(), canRetry: true));
      return [];
    }
  }

  Future<List<Article>> getBookmarks() async {
    if (userId.isEmpty) {
      emit(NewsError('User ID is not set', canRetry: false));
      return [];
    }
    try {
      return await _repository.getBookmarkArticles(userId);
    } catch (e) {
      emit(NewsError(e.toString(), canRetry: true));
      return [];
    }
  }

  Future<void> addBookmark(Article article) async {
    if (userId.isEmpty) {
      emit(NewsError('User ID is not set', canRetry: false));
      return;
    }
    await _repository.addBookmark(userId, article);
  }

  Future<void> removeBookmark(String articleId) async {
    if (userId.isEmpty) {
      emit(NewsError('User ID is not set', canRetry: false));
      return;
    }
    await _repository.removeBookmark(userId, articleId);
  }
}

