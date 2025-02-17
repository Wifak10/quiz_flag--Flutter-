import 'package:flutter/material.dart';
import 'package:quiz/screens/game_screen.dart';
import 'package:quiz/screens/home_screen.dart';
import 'package:quiz/screens/score_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String game = '/game';
  static const String score = '/score';

  static final Map<String, WidgetBuilder> routes = {
    home: (context) => HomeScreen(),
    game: (context) => GameScreen(),
    score: (context) => ScoreScreen(score: 0), // Replace 0 with the appropriate score value
  };
}
