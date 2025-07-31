import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/cubits/auth_cubit.dart';
import 'package:news_app/cubits/auth_state.dart';
import 'package:news_app/cubits/news_cubit.dart';
import 'package:news_app/views/home_screen.dart';
import 'package:news_app/views/login_screen.dart';
import 'package:news_app/services/local_auth_service.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/repositories/news_repository.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(LocalAuthService())..checkAuthStatus(),
        ),
        BlocProvider(
          create: (context) => NewsCubit(
            NewsRepository(
              NewsService(
                Dio(),
                apiKey: 'YOUR_API_KEY_HERE', // Replace with secure API key
                prefs: prefs,
              ),
              prefs: prefs,
            ),
          )..fetchTopHeadlines('us'),
        ),
      ],
      child: MaterialApp(
        title: 'News App',
        theme: ThemeData(
          primarySwatch: AppColors.primaryMaterialColor,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          primarySwatch: AppColors.primaryMaterialColor,
          brightness: Brightness.dark,
        ),
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              return HomeScreen(user: state.user);
            } else if (state is AuthLoggedOut) {
              return const LoginScreen();
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
