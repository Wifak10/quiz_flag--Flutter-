import 'package:flutter/material.dart';
import 'package:quiz/screens/game_screen.dart';
import 'package:quiz/screens/home_screen.dart';
import 'package:quiz/screens/score_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String game = '/game';
  static const String score = '/score';

  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    game: (context) => const GameScreen(),
    score: (context) {
      // Nous devons obtenir le score de la page de jeu avant de l'envoyer à ScoreScreen
      final score = ModalRoute.of(context)?.settings.arguments as int? ?? 0;
      return ScoreScreen(score: score);  // Passage du score à la page de score
    },
  };
}
