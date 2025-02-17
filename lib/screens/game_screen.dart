import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

// Cette fonction prend deux entiers en entrée et retourne leur somme.
int additionner(int a, int b) {
  // La variable 'resultat' stocke la somme de 'a' et 'b'.
  int resultat = a + b;
  // La fonction retourne la valeur de 'resultat'.
  return resultat;
}

// Cette fonction prend une liste d'entiers en entrée et retourne la somme de tous les éléments de la liste.
int sommeListe(List<int> nombres) {
  // La variable 'somme' est initialisée à 0 et servira à accumuler la somme des éléments de la liste.
  int somme = 0;
  // La boucle 'for' parcourt chaque élément de la liste 'nombres'.
  for (int nombre in nombres) {
    // À chaque itération, la valeur de 'nombre' est ajoutée à 'somme'.
    somme += nombre;
  }
  // La fonction retourne la valeur de 'somme'.
  return somme;
}

// Cette fonction prend un entier en entrée et retourne 'true' si l'entier est pair, sinon 'false'.
bool estPair(int nombre) {
  // La condition vérifie si le reste de la division de 'nombre' par 2 est égal à 0.
  // Si c'est le cas, 'nombre' est pair et la fonction retourne 'true'.
  // Sinon, la fonction retourne 'false'.
  return nombre % 2 == 0;
}

// Cette fonction prend une liste d'entiers en entrée et retourne une nouvelle liste contenant uniquement les nombres pairs.
List<int> filtrerNombresPairs(List<int> nombres) {
  // La variable 'nombresPairs' est une liste vide qui stockera les nombres pairs.
  List<int> nombresPairs = [];
  // La boucle 'for' parcourt chaque élément de la liste 'nombres'.
  for (int nombre in nombres) {
    // Si 'nombre' est pair, il est ajouté à la liste 'nombresPairs'.
    if (estPair(nombre)) {
      nombresPairs.add(nombre);
    }
  }
  // La fonction retourne la liste 'nombresPairs'.
  return nombresPairs;
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // URL de l'API pour récupérer les informations sur les pays
  final String url = 'https://restcountries.com/v3.1/all';
  // Liste pour stocker les informations des pays
  List<dynamic> countries = [];
  // Dictionnaire pour stocker les informations du pays actuel
  Map<String, dynamic> currentCountry = {};
  // Liste pour stocker les options de réponse
  List<String> options = [];
  // Variable pour stocker le score du joueur
  int score = 0;
  // Variable pour indiquer si le jeu est terminé
  bool gameOver = false;

  // Fonction pour récupérer les informations des pays depuis l'API
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

  // Fonction pour vérifier la réponse sélectionnée par l'utilisateur
  void checkAnswer(String selectedCountry) {
    if (selectedCountry == currentCountry['name']['common']) {
      setState(() {
        score++;
      });
      getNextQuestion();
    } else {
      // Si l'utilisateur se trompe, on termine le jeu et on montre le score
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
                      // Recommencer le jeu
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
                      // Retourner à la page d'accueil
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
                  Image.network(
                    currentCountry['flags']['png'] ?? '',
                    height: 100,
                  ),
                  const Text(
                    "Qui suis-je ?",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  Column(
                    children: options.map((country) {
                      return Card(
                        elevation: 5, // Ombrage pour un effet de carte
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
