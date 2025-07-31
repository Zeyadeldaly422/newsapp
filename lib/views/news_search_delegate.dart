import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/cubits/news_cubit.dart';
import 'package:news_app/cubits/news_state.dart';
import 'package:news_app/widgets/article_card.dart';

class NewsSearchDelegate extends SearchDelegate {
  final NewsCubit newsCubit;

  NewsSearchDelegate(this.newsCubit);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isNotEmpty) {
      newsCubit.searchNews(query);
    }
    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        if (state is NewsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is NewsLoaded) {
          return ListView.builder(
            itemCount: state.articles.length,
            itemBuilder: (context, index) => ArticleCard(
              key: ValueKey(state.articles[index].id),
              article: state.articles[index],
              userId: newsCubit.userId,
              heroTag: 'article_image_${state.articles[index].id}',
            ),
          );
        } else if (state is NewsError) {
          return Center(child: Text(state.message));
        } else if (state is NewsEmpty) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text('Search for news...'));
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: newsCubit.getNewsSources(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('No suggestions available'));
        }
        final sources = snapshot.data!;
        return ListView.builder(
          itemCount: sources.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(sources[index]),
              onTap: () {
                query = sources[index];
                newsCubit.searchNews(query);
                showResults(context);
              },
            );
          },
        );
      },
    );
  }
}