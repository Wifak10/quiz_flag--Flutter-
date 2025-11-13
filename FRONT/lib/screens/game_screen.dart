import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flip_card/flip_card.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final String url = 'https://restcountries.com/v3.1/all?fields=name,flags,region,capital';
  List<dynamic> countries = [];
  Map<String, dynamic> currentCountry = {};
  List<String> options = [];
  List<Color> buttonColors = [];
  int score = 0;
  bool gameOver = false;
  bool answerRevealed = false;
  bool isLoading = true;

  late ConfettiController _confettiController;
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _scoreAnimationController, curve: Curves.elasticOut),
    );
    fetchCountries();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  Future<void> fetchCountries() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          countries = data;
          isLoading = false;
        });
        if (countries.isNotEmpty) {
          getNextQuestion();
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void getNextQuestion() {
    if (countries.isEmpty) return;

    Random random = Random();
    int attempts = 0;
    do {
      currentCountry = countries[random.nextInt(countries.length)];
      attempts++;
      if (attempts > 50) break;
    } while ((currentCountry['flags'] == null || 
              currentCountry['flags']['png'] == null ||
              currentCountry['name'] == null ||
              currentCountry['name']['common'] == null) && attempts <= 50);

    if (currentCountry['name'] == null || currentCountry['name']['common'] == null) {
      return;
    }

    String correctCountry = currentCountry['name']['common'];
    options = [correctCountry];

    while (options.length < 4) {
      var randomCountry = countries[random.nextInt(countries.length)];
      if (randomCountry['name'] != null && randomCountry['name']['common'] != null) {
        String countryName = randomCountry['name']['common'];
        if (!options.contains(countryName)) {
          options.add(countryName);
        }
      }
    }

    options.shuffle();
    setState(() {
      buttonColors = List.generate(4, (_) => const Color(0xFF26A69A));
      answerRevealed = false;
    });
  }

  void checkAnswer(String selectedCountry, int index) {
    if (selectedCountry == currentCountry['name']['common']) {
      setState(() {
        score++;
        buttonColors[index] = const Color(0xFF4CAF50);
        _confettiController.play();
        _scoreAnimationController.forward().then((_) {
          _scoreAnimationController.reverse();
        });
      });
    } else {
      setState(() {
        buttonColors[index] = const Color(0xFFE53935);
      });

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          int correctIndex = options.indexOf(currentCountry['name']['common']);
          buttonColors[correctIndex] = const Color(0xFF4CAF50);
        });
      });

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          answerRevealed = true;
        });
      });
    }

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header avec score
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
                    ),
                    AnimatedBuilder(
                      animation: _scoreAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scoreAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Score: $score',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // Contenu principal
              Expanded(
                child: isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Chargement des pays...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : gameOver
                    ? _buildGameOverScreen()
                    : _buildGameScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.flag,
              size: 80,
              color: Color(0xFF667eea),
            ),
            const SizedBox(height: 20),
            const Text(
              'Jeu terminé !',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Score final: $score',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF667eea),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        score = 0;
                        gameOver = false;
                        getNextQuestion();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26A69A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Rejouer',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Menu',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Carte du drapeau
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: currentCountry['flags'] != null && currentCountry['flags']['png'] != null
                          ? Image.network(
                              currentCountry['flags']['png'],
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.error,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.flag,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              
              // Options de réponse
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    for (int i = 0; i < options.length; i++)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 15),
                        child: ElevatedButton(
                          onPressed: answerRevealed ? null : () => checkAnswer(options[i], i),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColors[i],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            options[i],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],
          ),
        ),
      ],
    );
  }
}