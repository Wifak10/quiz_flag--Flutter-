import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Bienvenue au quiz des pays 😍'),
          centerTitle: true,
        ),
        body: Center(
            child: ElevatedButton(
          onPressed: () {
            onPressed:
            () {
              Navigator.pushNamed(context,
                  '/game_screen'); // Navigate to the game screen when the button is pressed);
            };
          },
          child: Text('Commencer le jeu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.yellow[700]),
        )));
  }

  Widget game_screen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jeu des pays'),
        centerTitle: true,
      ),
      body: Center(
        child: Text('Game Screen'),
      ),
    );
  }
}
