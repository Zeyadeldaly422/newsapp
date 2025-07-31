// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:news_app/cubits/auth_cubit.dart';
// import 'package:news_app/cubits/auth_state.dart';
// import 'package:news_app/cubits/news_cubit.dart';
// import 'package:news_app/cubits/news_state.dart';
// import 'package:news_app/models/user_model.dart';
// import 'package:news_app/views/login_screen.dart';
// import 'package:news_app/views/profile_screen.dart';
// import 'package:news_app/views/settings_screen.dart';
// import 'package:news_app/utils/app_colors.dart';
// import 'package:news_app/views/news_search_delegate.dart';
// import 'package:news_app/views/bookmark_screen.dart';
// import 'package:news_app/widgets/article_card.dart';

// class HomeScreen extends StatefulWidget {
//   final User user;
//   const HomeScreen({super.key, required this.user});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final ScrollController _scrollController = ScrollController();
//   final List<String> _categories = [
//     'business',
//     'entertainment',
//     'general',
//     'health',
//     'science',
//     'sports',
//     'technology'
//   ];
//   String _selectedCategory = 'general';

//   @override
//   void initState() {
//     super.initState();
//     context.read<NewsCubit>().fetchTopHeadlines('us');
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels >=
//           _scrollController.position.maxScrollExtent - 200) {
//         final state = context.read<NewsCubit>().state;
//         if (state is NewsLoaded && state.hasMore) {
//           context.read<NewsCubit>().fetchMoreHeadlines('us', state.currentPage + 1);
//         }
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   String _getGreeting() {
//     final hour = DateTime.now().hour;
//     if (hour < 12) return 'Good Morning';
//     if (hour < 17) return 'Good Afternoon';
//     return 'Good Evening';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${_getGreeting()}, ${widget.user.firstName}!'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               showSearch(context: context, delegate: NewsSearchDelegate(context.read<NewsCubit>()));
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.bookmark),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => BookmarkScreen(userId: widget.user.id),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(
//                 color: AppColors.primary,
//               ),
//               child: Text(
//                 '${widget.user.firstName} ${widget.user.lastName}',
//                 style: const TextStyle(color: Colors.white, fontSize: 24),
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: const Text('Profile'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => ProfileScreen(user: widget.user),
//                   ),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.settings),
//               title: const Text('Settings'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const SettingsScreen(),
//                   ),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: const Text('Logout'),
//               onTap: () {
//                 context.read<AuthCubit>().logout();
//               },
//             ),
//           ],
//         ),
//       ),
//       body: BlocListener<AuthCubit, AuthState>(
//         listener: (context, state) {
//           if (state is AuthLoggedOut) {
//             Navigator.of(context).pushAndRemoveUntil(
//               MaterialPageRoute(builder: (_) => const LoginScreen()),
//               (route) => false,
//             );
//           }
//         },
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: _categories
//                       .map((category) => Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                             child: ChoiceChip(
//                               label: Text(category[0].toUpperCase() + category.substring(1)),
//                               selected: _selectedCategory == category,
//                               onSelected: (selected) {
//                                 if (selected) {
//                                   setState(() {
//                                     _selectedCategory = category;
//                                   });
//                                   context.read<NewsCubit>().fetchNewsByCategory(category);
//                                 }
//                               },
//                             ),
//                           ))
//                       .toList(),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: RefreshIndicator(
//                 onRefresh: () => context.read<NewsCubit>().fetchTopHeadlines('us', isRefresh: true),
//                 child: BlocBuilder<NewsCubit, NewsState>(
//                   builder: (context, state) {
//                     if (state is NewsLoading || state is NewsRefreshing) {
//                       return const Center(child: CircularProgressIndicator());
//                     } else if (state is NewsLoaded || state is NewsOffline) {
//                       final articles = state is NewsLoaded ? state.articles : (state as NewsOffline).articles;
//                       final hasMore = state is NewsLoaded ? state.hasMore : false;
//                       return ListView.builder(
//                         controller: _scrollController,
//                         itemCount: articles.length + (hasMore ? 1 : 0),
//                         itemBuilder: (context, index) {
//                           if (index == articles.length && hasMore) {
//                             return const Center(child: CircularProgressIndicator());
//                           }
//                           return ArticleCard(
//                             key: ValueKey(articles[index].id),
//                             article: articles[index],
//                             userId: widget.user.id,
//                             heroTag: 'article_image_${articles[index].id}',
//                           );
//                         },
//                       );
//                     } else if (state is NewsError) {
//                       return Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(state.message, style: const TextStyle(color: AppColors.error)),
//                             if (state.canRetry)
//                               TextButton(
//                                 onPressed: () => context.read<NewsCubit>().fetchTopHeadlines('us'),
//                                 child: const Text('Retry'),
//                               ),
//                           ],
//                         ),
//                       );
//                     } else if (state is NewsEmpty) {
//                       return Center(child: Text(state.message));
//                     }
//                     return const Center(child: Text('Start browsing news!'));
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           showSearch(context: context, delegate: NewsSearchDelegate(context.read<NewsCubit>()));
//         },
//         backgroundColor: AppColors.primary,
//         child: const Icon(Icons.search),
//       ),
//     );
//   }
// }

// lib/views/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/cubits/auth_cubit.dart';
import 'package:news_app/cubits/auth_state.dart';
import 'package:news_app/cubits/news_cubit.dart';
import 'package:news_app/cubits/news_state.dart';
import 'package:news_app/models/user_model.dart';
import 'package:news_app/views/login_screen.dart';
import 'package:news_app/views/profile_screen.dart';
import 'package:news_app/views/settings_screen.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/views/news_search_delegate.dart';
import 'package:news_app/views/bookmark_screen.dart';
import 'package:news_app/widgets/article_card.dart';
import 'package:news_app/models/article_model.dart'; // لاستيراد نموذج Article

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _categories = [
    'business',
    'entertainment',
    'general',
    'health',
    'science',
    'sports',
    'technology'
  ];
  String _selectedCategory = 'general';

  // قائمة الأخبار الثابتة (Mock Data)
  final List<Article> _mockArticles = [
    Article(
      id: '1',
      title: 'تكنولوجيا جديدة تغير العالم',
      description: 'شركة تقنية تطلق منتجًا جديدًا يُحدث ثورة في السوق.',
      url: 'https://example.com/news1',
      urlToImage: 'https://example.com/images/news1.jpg',
      publishedAt: DateTime.now().toIso8601String(),
      sourceName: 'Tech News',
      author: 'محمد أحمد',
      content: 'محتوى تفصيلي عن المنتج الجديد وتأثيره على الصناعة...',
    ),
    Article(
      id: '2',
      title: 'اكتشاف علمي جديد في الفضاء',
      description: 'علماء يجدون دلائل على وجود حياة خارج كوكب الأرض.',
      url: 'https://example.com/news2',
      urlToImage: 'https://example.com/images/news2.jpg',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      sourceName: 'Space Today',
      author: 'سارة علي',
      content: 'تفاصيل الاكتشاف العلمي الجديد وتأثيره على العلم...',
    ),
    Article(
      id: '3',
      title: 'تحديثات اقتصادية عالمية',
      description: 'ارتفاع في أسعار الأسهم بعد قرارات البنك المركزي.',
      url: 'https://example.com/news3',
      urlToImage: 'https://example.com/images/news3.jpg',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      sourceName: 'Economy Times',
      author: 'خالد محمود',
      content: 'تحليل القرارات الاقتصادية وتأثيرها على الأسواق...',
    ),
  ];

  @override
  void initState() {
    super.initState();
    context.read<NewsCubit>().fetchTopHeadlines('us');
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final state = context.read<NewsCubit>().state;
        if (state is NewsLoaded && state.hasMore) {
          context.read<NewsCubit>().fetchMoreHeadlines('us', state.currentPage + 1);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_getGreeting()}, ${widget.user.firstName}!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: NewsSearchDelegate(context.read<NewsCubit>()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookmarkScreen(userId: widget.user.id),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Text(
                '${widget.user.firstName} ${widget.user.lastName}',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(user: widget.user),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                context.read<AuthCubit>().logout();
              },
            ),
          ],
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedOut) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories
                      .map((category) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ChoiceChip(
                              label: Text(category[0].toUpperCase() + category.substring(1)),
                              selected: _selectedCategory == category,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                  context.read<NewsCubit>().fetchNewsByCategory(category);
                                }
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<NewsCubit>().fetchTopHeadlines('us', isRefresh: true),
                child: BlocBuilder<NewsCubit, NewsState>(
                  builder: (context, state) {
                    if (state is NewsLoading || state is NewsRefreshing) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is NewsLoaded || state is NewsOffline) {
                      final articles = state is NewsLoaded ? state.articles : (state as NewsOffline).articles;
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: articles.length,
                        itemBuilder: (context, index) {
                          return ArticleCard(
                            key: ValueKey(articles[index].id),
                            article: articles[index],
                            userId: widget.user.id,
                            heroTag: 'article_image_${articles[index].id}',
                          );
                        },
                      );
                    } else if (state is NewsError || state is NewsEmpty) {

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: _mockArticles.length,
                        itemBuilder: (context, index) {
                          return ArticleCard(
                            key: ValueKey(_mockArticles[index].id),
                            article: _mockArticles[index],
                            userId: widget.user.id,
                            heroTag: 'article_image_${_mockArticles[index].id}',
                          );
                        },
                      );
                    }                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: _mockArticles.length,
                      itemBuilder: (context, index) {
                        return ArticleCard(
                          key: ValueKey(_mockArticles[index].id),
                          article: _mockArticles[index],
                          userId: widget.user.id,
                          heroTag: 'article_image_${_mockArticles[index].id}',
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showSearch(context: context, delegate: NewsSearchDelegate(context.read<NewsCubit>()));
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.search),
      ),
    );
  }
}