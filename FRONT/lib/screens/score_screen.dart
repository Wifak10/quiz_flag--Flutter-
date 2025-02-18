import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

class ScoreScreen extends StatefulWidget {
  final int score;

  const ScoreScreen({super.key, required this.score});

  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Animation pour faire augmenter le score
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // L'animation du score qui s'incrémente jusqu'à la valeur finale
    _animation = Tween<double>(begin: 0, end: widget.score.toDouble()).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Lancer l'animation dès l'initialisation
    _controller.forward();
  }

  @override
  void dispose() {
    // Nettoyage du contrôleur d'animation
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dégradé de fond
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animation de texte pour l'affichage du score
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Text(
                    'Votre score est : ${_animation.value.toInt()}',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Roboto',
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Animation supplémentaire : Un joli bouton pour revenir à l'accueil
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Retour à l'écran précédent
                },
                child: const Text(
                  'Retour à l\'accueil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.yellow[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
