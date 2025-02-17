import 'package:flutter/material.dart';

class ScorePage extends StatelessWidget {
  final int score;

  ScorePage({required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Score Final"),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "Votre score : $score",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
      ),
    );
  }
}
