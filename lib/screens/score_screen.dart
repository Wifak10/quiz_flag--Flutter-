import 'package:flutter/material.dart';

class ScoreScreen extends StatelessWidget {
  final int score;
  
  const ScoreScreen({super.key, required this.score});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Score'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Votre score est : $score',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
