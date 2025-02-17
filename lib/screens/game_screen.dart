import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  // Fonction pour récupérer tous les pays
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

  // Fonction pour générer la prochaine question
  void getNextQuestion() {
    if (countries.isEmpty) return;

    Random random = Random();
    currentCountry = countries[random.nextInt(countries.length)];

    // Sélectionner le pays correct
    String correctCountry = currentCountry['name']['common'];

    // Ajouter le pays correct aux options
    options = [correctCountry];

    // Ajouter 3 autres pays au hasard pour les options
    while (options.length < 4) {
      String randomCountry = countries[random.nextInt(countries.length)]['name']['common'];
      if (!options.contains(randomCountry)) {
        options.add(randomCountry);
      }
    }

    options.shuffle(); // Mélanger les options
  }

  // Vérifier la réponse
  void checkAnswer(String selectedCountry) {
    if (selectedCountry == currentCountry['name']['common']) {
      setState(() {
        score++;
      });
    }

    // Passer à la question suivante
    setState(() {
      getNextQuestion();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCountries(); // Charger les pays lors de l'initialisation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz des Pays"),
        centerTitle: true,
      ),
      body: countries.isEmpty
          ? Center(child: CircularProgressIndicator()) // Attendre le chargement des pays
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Affichage du drapeau du pays
                  Image.network(
                    currentCountry['flags']['png'] ?? '',
                    height: 100,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Quel est ce pays ?",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  // Affichage des options
                  Column(
                    children: options.map((country) {
                      return ElevatedButton(
                        onPressed: () => checkAnswer(country),
                        child: Text(
                          country,
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.teal,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Rediriger vers la page de score avec le score actuel
            Navigator.pop(context, score); // Revenir à la page précédente et envoyer le score
          },
          child: Text(
            "Voir le score",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.yellow[700],
          ),
        ),
      ),
    );
  }
}
