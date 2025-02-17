import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
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
    }

    setState(() {
      getNextQuestion();
    });
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
      ),
      body: countries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    currentCountry['flags']['png'] ?? '',
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Quel est ce pays ?",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: options.map((country) {
                      return ElevatedButton(
                        onPressed: () => checkAnswer(country),
                        child: Text(
                          country,
                          style: const TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
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
            Navigator.pushNamed(context, '/score',
                arguments: score); // Passage du score à l'écran de score
          },
          child: const Text(
            "Voir le score",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
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
