import 'package:news_app/models/article_model.dart';

abstract class NewsState {
  bool? get hasMore => null;

  get currentPage => null;
}

class NewsInitial extends NewsState {}
class NewsLoading extends NewsState {}
class NewsRefreshing extends NewsState {}
class NewsLoaded extends NewsState {
  final List<Article> articles;
  @override
  final bool hasMore;
  @override
  final int currentPage;

  NewsLoaded(this.articles, {required this.hasMore, required this.currentPage});
}
class NewsOffline extends NewsState {
  final List<Article> articles;

  NewsOffline(this.articles);
}
class NewsError extends NewsState {
  final String message;
  final bool canRetry;

  NewsError(this.message, {this.canRetry = false});
}
class NewsEmpty extends NewsState {
  final String message;

  NewsEmpty(this.message);
}