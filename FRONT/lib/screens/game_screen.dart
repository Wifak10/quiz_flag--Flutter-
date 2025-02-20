import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flip_card/flip_card.dart';
import 'package:confetti/confetti.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final String url = 'https://restcountries.com/v3.1/all';
  List<dynamic> countries = [];
  Map<String, dynamic> currentCountry = {};
  List<String> options = [];
  List<Color> buttonColors = []; // Liste pour stocker les couleurs des boutons
  int score = 0;
  bool gameOver = false;
  bool answerRevealed =
      false; // Indicateur pour savoir si la bonne réponse est révélée

  late ConfettiController _confettiController; // Confetti controller pour l'animation

  @override
  void initState() {
    super.initState();
    fetchCountries();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> fetchCountries() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        countries = jsonDecode(response.body);
      });
      getNextQuestion();
    } else {
      throw Exception('Failed to load countries');
    }
  }

  void getNextQuestion() {
    if (countries.isEmpty) return;

    Random random = Random();
    currentCountry = countries[random.nextInt(countries.length)];

    String correctCountry = currentCountry['name']['common'];
    options = [correctCountry];

    while (options.length < 4) {
      String randomCountry =
          countries[random.nextInt(countries.length)]['name']['common'];
      if (!options.contains(randomCountry)) {
        options.add(randomCountry);
      }
    }

    options.shuffle();
    buttonColors = List.generate(
        4, (_) => Colors.teal[400]!); // Réinitialisation des couleurs
    answerRevealed = false; // Reset de la révélation de la réponse
  }

  void checkAnswer(String selectedCountry, int index) {
    if (selectedCountry == currentCountry['name']['common']) {
      setState(() {
        score++;
        buttonColors[index] = Colors.blue; // Bonne réponse en bleu
        _confettiController.play(); // Jouer les confettis pour une bonne réponse
      });
    } else {
      setState(() {
        buttonColors[index] = Colors.red; // Mauvaise réponse en rouge
      });

      // Afficher la bonne réponse après un court délai
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          // Révéler la bonne réponse en bleu après un délai
          int correctIndex = options.indexOf(currentCountry['name']['common']);
          buttonColors[correctIndex] = Colors.blue; // Bonne réponse en bleu
        });
      });

      // Afficher le score après un délai
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          answerRevealed = true; // Afficher le score et la réponse correcte
        });
      });
    }

    // Attendre un peu avant de passer à la question suivante
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        if (selectedCountry != currentCountry['name']['common']) {
          gameOver = true;
        } else {
          getNextQuestion();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz des Pays'),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
      ),
      body: gameOver
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Vous avez perdu !",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Votre score final est : $score", // Affichage du score final
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        score = 0; // Réinitialiser le score
                        gameOver = false; // Réinitialiser l'état de fin de jeu
                      });
                      fetchCountries(); // Relancer la partie
                    },
                    child: const Text(
                      "Recommencer le jeu",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.yellow[700],
                      shadowColor: Colors.black.withOpacity(0.5),
                      elevation: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/'); // Retour à l'écran d'accueil
                    },
                    child: const Text(
                      "Retour à l'accueil",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.yellow[700],
                      shadowColor: Colors.black.withOpacity(0.5),
                      elevation: 12,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Affichage de l'image du drapeau avec l'effet FlipCard
                  FlipCard(
                    direction: FlipDirection.HORIZONTAL,
                    front: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          currentCountry['flags']['png'] ?? '',
                          height: 120,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Cliquez sur le drapeau pour avoir un indice',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Color.fromARGB(255, 236, 156, 8),
                          ),
                        ),
                      ],
                    ),
                    back: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[800]!, Colors.teal[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Indice :',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Capitale : ${currentCountry['capital']?.join(', ') ?? 'inconnue'}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Qui suis-je ?",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal),
                  ),
                  const SizedBox(height: 20),
                  // Disposition en grille des options avec GridView.count
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2, // Nombre de colonnes
                      crossAxisSpacing: 10, // Espacement horizontal
                      mainAxisSpacing: 10, // Espacement vertical
                      childAspectRatio: 3, // Ratio de la taille des éléments
                      children: List.generate(options.length, (index) {
                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: () => checkAnswer(options[index], index),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              child: Text(
                                options[index],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  buttonColors[index], // Couleur dynamique
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Confetti animation
                  if (!answerRevealed)
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirectionality: BlastDirectionality.explosive,
                        shouldLoop: false,
                        colors: const [
                          Colors.blue,
                          Colors.green,
                          Colors.yellow
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}