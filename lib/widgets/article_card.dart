import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app/models/article_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/cubits/news_cubit.dart';
import 'package:news_app/views/article_detail_screen.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final String userId;
  final String heroTag;

  const ArticleCard({super.key, required this.article, required this.userId, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: article.urlToImage != null
            ? Hero(
                tag: heroTag,
                child: CachedNetworkImage(
                  imageUrl: article.urlToImage!,
                  width: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                ),
              )
            : const Icon(Icons.image, size: 100),
        title: Text(article.title ?? 'No Title', maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text('${article.sourceName ?? 'Unknown'} - ${article.publishedAt?.toLocal().toString().split('.')[0] ?? ''}'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ArticleDetailScreen(article: article, heroTag: heroTag),
            ),
          );
        },
        trailing: IconButton(
          icon: const Icon(Icons.bookmark_add),
          onPressed: () {
            context.read<NewsCubit>().addBookmark(article);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Article bookmarked!')),
            );
          },
        ),
      ),
    );
  }
}

extension on String? {
  toLocal() {}
}


