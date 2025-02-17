import 'package:flutter/material.dart';
import 'game_screen.dart'; // Assurez-vous d'importer le fichier `game_screen.dart`

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
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/game': (context) => const GameScreen(),
      },
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
          // Image d'arrière-plan
          Positioned.fill(
            child: Image.asset(
              'assets/flags collage.jpg', // Remplacez ceci par le chemin vers votre image dans les assets
              fit: BoxFit
                  .cover, // Pour ajuster l'image pour qu'elle couvre tout l'écran
              color: Colors.black.withOpacity(
                  0.4), // Optionnel, applique un filtre semi-transparent sur l'image
              colorBlendMode: BlendMode
                  .darken, // Optionnel, pour adoucir l'image et faire ressortir le contenu par-dessus
            ),
          ),
          // Contenu principal
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[800]!, Colors.purple[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
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
                        Navigator.pushNamed(context, '/game');
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
                        backgroundColor:
                            Colors.yellow[800], // Couleur du bouton
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
          ),
        ],
      ),
    );
  }
}
