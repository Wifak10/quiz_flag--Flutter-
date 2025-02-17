import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flip_card/flip_card.dart';

// La fonction additionner, sommeListe, et estPair restent inchangées.

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
  int score = 0;
  bool gameOver = false;

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
  }

  void checkAnswer(String selectedCountry) {
    if (selectedCountry == currentCountry['name']['common']) {
      setState(() {
        score++;
      });
      getNextQuestion();
    } else {
      setState(() {
        gameOver = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCountries();
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Votre score final est : $score",
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        score = 0;
                        gameOver = false;
                      });
                      fetchCountries();
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.yellow[700],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/');
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.yellow[700],
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
                          height: 100,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Cliquez sur le drapeau pour avoir un indice',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    back: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[700],
                        borderRadius: BorderRadius.circular(12),
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: options.map((country) {
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ElevatedButton(
                          onPressed: () => checkAnswer(country),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 12),
                            child: Text(
                              country,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.teal[400], // Couleur de fond
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
    );
  }
}
