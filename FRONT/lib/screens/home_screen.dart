import 'package:flutter/material.dart';
import 'game_screen.dart'; // Assurez-vous d'importer le fichier `game_screen.dart`
import 'dart:ui'; // Import the dart:ui package for ImageFilter
import '../routes/app_routes.dart'; // Import the routes

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz des Pays',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image d'arrière-plan avec flou
          Positioned.fill(
            child: Image.asset(
              'assets/flagsCollage.jpg', // Chemin relatif vers votre image dans le dossier assets
              fit: BoxFit.cover, // L'image va couvrir toute la taille de l'écran
            ),
          ),
          // Appliquer un flou à l'image en arrière-plan
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Flou léger
              child: Container(
                color: Colors.black.withOpacity(0.3), // Ajout d'un filtre sombre pour la lisibilité
              ),
            ),
          ),
          // Contenu principal
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Texte d'introduction animé
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(seconds: 2),
                    child: Text(
                      'Bienvenue au Quiz des Pays 😍',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                        color: Colors.white,
                        letterSpacing: 1.5, // Espacement entre les lettres
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black.withOpacity(0.7),
                            offset: Offset(3, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Sous-texte captivant
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Text(
                      'Testez vos connaissances sur les pays du monde en jouant à notre quiz amusant !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Bouton stylisé pour démarrer le jeu
                  ElevatedButton(
                    onPressed: () {
                      _showGameOptionsDialog(context);
                    },
                    child: const Text(
                      'Commencer le jeu',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.yellow[800], // Couleur du bouton
                      shadowColor: Colors.black.withOpacity(0.6),
                      elevation: 10,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Boutons supplémentaires pour naviguer vers les autres pages
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.profile);
                    },
                    child: const Text(
                      'Profil',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: const Color.fromARGB(255, 165, 165, 166), // Couleur du bouton
                      shadowColor: Colors.black.withOpacity(0.6),
                      elevation: 10,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.leaderboard);
                    },
                    child: const Text(
                      'Classements',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: const Color.fromARGB(255, 158, 189, 159), // Couleur du bouton
                      shadowColor: Colors.black.withOpacity(0.6),
                      elevation: 10,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.userScores);
                    },
                    child: const Text(
                      'Mes Scores',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: const Color.fromARGB(255, 231, 175, 175), // Couleur du bouton
                      shadowColor: Colors.black.withOpacity(0.6),
                      elevation: 10,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Texte d'invite à explorer
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Avez-vous besoin d\'aide ? Cliquez ici pour plus d\'infos.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGameOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choisissez une option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.game);
                },
                child: Text('Jouer le jeu des pays'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.aboutUs);
                },
                child: Text('Qui Sommes Nous ?'),
              ),
            ],
          ),
        );
      },
    );
  }
}