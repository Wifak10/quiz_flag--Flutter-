import 'package:flutter/material.dart';
import 'package:quiz/screens/game_screen.dart';
import 'package:quiz/screens/home_screen.dart';
import 'package:quiz/screens/score_screen.dart';
import 'package:quiz/screens/register_screen.dart';
import 'package:quiz/screens/login_screen.dart';
// import 'package:quiz/screens/profile_screen.dart';
// import 'package:quiz/screens/leaderboard_screen.dart';
// import 'package:quiz/screens/user_scores_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String game = '/game';
  static const String score = '/score';
  static const String register = '/register';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String leaderboard = '/leaderboard';
  static const String userScores = '/user-scores';

  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    game: (context) => const GameScreen(),
    score: (context) {
      final score = ModalRoute.of(context)?.settings.arguments as int? ?? 0;
      return ScoreScreen(score: score);
    },
    register: (context) => RegisterScreen(),
    login: (context) =>  LoginScreen(),
    // profile: (context) => const ProfileScreen(),
    // leaderboard: (context) => const LeaderboardScreen(),
    // userScores: (context) => const UserScoresScreen(),
  };
}