import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:news_app/cubits/news_cubit.dart';
import 'package:news_app/models/article_model.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;
  final String heroTag;

  const ArticleDetailScreen({super.key, required this.article, required this.heroTag});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  double _textScale = 1.0;
  bool _isBookmarked = false;
  final ScrollController _scrollController = ScrollController();
  double _readingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
    _scrollController.addListener(_updateReadingProgress);
  }

  void _checkBookmarkStatus() async {
    final bookmarks = await context.read<NewsCubit>().getBookmarks();
    setState(() {
      _isBookmarked = bookmarks.any((a) => a.id == widget.article.id);
    });
  }

  void _updateReadingProgress() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      setState(() {
        _readingProgress = currentScroll / maxScroll;
        if (_readingProgress >= 0.9 && !_isBookmarked) {
          context.read<NewsCubit>().addBookmark(widget.article);
          setState(() => _isBookmarked = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Article auto-bookmarked!')),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _calculateReadingTime(String? content) {
    if (content == null) return 1;
    final words = content.split(' ').length;
    return (words / 200).ceil(); // Assuming 200 words per minute
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.sourceName ?? 'News'),
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
              if (_isBookmarked) {
                context.read<NewsCubit>().addBookmark(widget.article);
              } else {
                context.read<NewsCubit>().removeBookmark(widget.article.id!);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_isBookmarked ? 'Bookmarked!' : 'Bookmark removed')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              if (widget.article.url != null) {
                Share.share(widget.article.url!);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: widget.heroTag,
              child: widget.article.urlToImage != null
                  ? CachedNetworkImage(
                      imageUrl: widget.article.urlToImage!,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 100),
                    )
                  : const Icon(Icons.broken_image, size: 250),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.title ?? 'No Title',
                    style: TextStyle(
                      fontSize: 24 * _textScale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.article.sourceName ?? 'Unknown'} - ${widget.article.publishedAt?.toLocal().toString().split('.')[0] ?? ''}',
                    style: TextStyle(
                      fontSize: 16 * _textScale,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  if (widget.article.author != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'By ${widget.article.author}',
                      style: TextStyle(fontSize: 16 * _textScale, color: AppColors.secondaryText),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Reading time: ${_calculateReadingTime(widget.article.description)} min',
                    style: TextStyle(fontSize: 14 * _textScale, color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: _readingProgress),
                  const SizedBox(height: 16),
                  Text(
                    widget.article.description ?? 'No content available.',
                    style: TextStyle(fontSize: 16 * _textScale),
                  ),
                  const SizedBox(height: 16),
                  if (widget.article.url != null)
                    ElevatedButton(
                      onPressed: () async {
                        await launchUrl(Uri.parse(widget.article.url!));
                      },
                      child: const Text('Read Full Article'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.text_increase),
              onPressed: () => setState(() => _textScale = (_textScale + 0.2).clamp(0.8, 1.4)),
            ),
            IconButton(
              icon: const Icon(Icons.text_decrease),
              onPressed: () => setState(() => _textScale = (_textScale - 0.2).clamp(0.8, 1.4)),
            ),
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                // Toggle theme (requires settings cubit)
              },
            ),
          ],
        ),
      ),
    );
  }
}

extension on String? {
  toLocal() {}
}