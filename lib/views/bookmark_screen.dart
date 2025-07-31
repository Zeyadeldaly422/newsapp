import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/cubits/news_cubit.dart';
import 'package:news_app/models/article_model.dart';

class BookmarkScreen extends StatelessWidget {
  final String userId;

  const BookmarkScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: FutureBuilder<List<Article>>(
        future: context.read<NewsCubit>().getBookmarks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load bookmarks'));
          }
          final bookmarks = snapshot.data ?? [];
          if (bookmarks.isEmpty) {
            return const Center(child: Text('No bookmarks yet'));
          }
          return ListView.builder(
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final article = bookmarks[index];
              return ArticleCard(
                key: ValueKey(article.id),
                article: article,
                userId: userId,
                heroTag: 'article_image_${article.id}',
              );
            },
          );
        },
      ),
    );
  }
  
  ArticleCard({required ValueKey<String?> key, required Article article, required String userId, required String heroTag}) {}
}