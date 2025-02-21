import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  final String url = 'https://restcountries.com/v3.1/all';
  List<dynamic> countries = [];
  String selectedContinent = '';
  List<String> selectedCountries = [];
  List<String> correctCountries = [];
  bool isLoading = true;
  List<String> userAnswers = [];

  @override
  void initState() {
    super.initState();
    fetchCountries();
  }

  Future<void> fetchCountries() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        countries = jsonDecode(response.body);
        selectRandomContinent();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load countries');
    }
  }

  void selectRandomContinent() {
    List<String> continents = ['Africa', 'Asia', 'Europe', 'Americas', 'Oceania'];
    Random random = Random();
    selectedContinent = continents[random.nextInt(continents.length)];
    selectCountries();
  }

  void selectCountries() {
    List<String> continentCountries = countries
        .where((country) => country['region'] == selectedContinent)
        .map<String>((country) => country['name']['common'])
        .toList();

    continentCountries.shuffle();
    correctCountries = continentCountries.take(3).toList();

    List<String> otherCountries = countries
        .where((country) => country['region'] != selectedContinent)
        .map<String>((country) => country['name']['common'])
        .toList();

    otherCountries.shuffle();
    selectedCountries = correctCountries + otherCountries.take(3).toList();
    selectedCountries.shuffle();
  }

  void checkAnswers() {
    int correctAnswersCount = userAnswers.where((country) => correctCountries.contains(country)).length;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Résultat', style: TextStyle(color: Colors.indigo)),
          content: Text('Vous avez $correctAnswersCount bonnes réponses!', style: TextStyle(fontSize: 18)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                resetGame();
              },
              child: Text('OK', style: TextStyle(color: Colors.indigo)),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      userAnswers.clear();
      isLoading = true;
    });
    fetchCountries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Qui Sommes Nous', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Sélectionnez les pays appartenant au continent: $selectedContinent',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 3 / 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: selectedCountries.length,
                      itemBuilder: (context, index) {
                        final country = selectedCountries[index];
                        return Draggable<String>(
                          data: country,
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              padding: EdgeInsets.all(8), // Réduction du padding
                              decoration: BoxDecoration(
                                color: Colors.lightBlueAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                country,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                          feedback: Material(
                            color: Colors.transparent,
                            child: Container(
                              padding: EdgeInsets.all(8), // Réduction du padding
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                country,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                          childWhenDragging: Container(
                            padding: EdgeInsets.all(8), // Réduction du padding
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              country,
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  DragTarget<String>(
                    onAccept: (country) {
                      setState(() {
                        if (!userAnswers.contains(country) && userAnswers.length < 3) {
                          userAnswers.add(country);
                        }
                      });
                    },
                    onWillAccept: (data) {
                      return true; // Allows the dragged item to be accepted
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        height: 120, // Augmentation de la hauteur
                        decoration: BoxDecoration(
                          color: Colors.teal[50],
                          border: Border.all(color: Colors.teal),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: userAnswers.isEmpty
                              ? Text(
                                  'Glissez les pays ici',
                                  style: TextStyle(fontSize: 18, color: Colors.teal[400]),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: userAnswers.map((answer) => Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Chip(
                                          label: Text(answer, style: TextStyle(color: Colors.white)),
                                          backgroundColor: Colors.teal[300],
                                          deleteIcon: Icon(Icons.close, color: Colors.white),
                                          onDeleted: () {
                                            setState(() {
                                              userAnswers.remove(answer);
                                            });
                                          },
                                        ),
                                      )).toList(),
                                ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: checkAnswers,
                    child: Text('Vérifier mes réponses'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 199, 204, 234)),
                  ),
                ],
              ),
            ),
    );
  }
}