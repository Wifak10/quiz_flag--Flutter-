import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:confetti/confetti.dart';
import '../services/data_service.dart';

class CapitalQuizScreen extends StatefulWidget {
  const CapitalQuizScreen({super.key});

  @override
  State<CapitalQuizScreen> createState() => _CapitalQuizScreenState();
}

class _CapitalQuizScreenState extends State<CapitalQuizScreen> with TickerProviderStateMixin {
  List<dynamic> countries = [];
  Map<String, dynamic> currentCountry = {};
  List<String> options = [];
  List<Color> buttonColors = [];
  int score = 0;
  int questionNumber = 1;
  bool gameOver = false;
  bool answerRevealed = false;
  bool isLoading = true;
  String? selectedAnswer;

  late ConfettiController _confettiController;
  late AnimationController _scoreAnimationController;
  late AnimationController _questionAnimationController;
  late Animation<double> _scoreAnimation;
  late Animation<Offset> _questionSlideAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _questionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scoreAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _scoreAnimationController, curve: Curves.elasticOut),
    );
    
    _questionSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _questionAnimationController, curve: Curves.easeOutCubic));
    
    fetchCountries();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scoreAnimationController.dispose();
    _questionAnimationController.dispose();
    super.dispose();
  }

  Future<void> fetchCountries() async {
    try {
      final data = await DataService.fetchCountries();
      setState(() {
        countries = data.where((country) => 
          country['capital'] != null && 
          country['capital'].isNotEmpty &&
          country['name'] != null &&
          country['name']['common'] != null
        ).toList();
        isLoading = false;
      });
      if (countries.isNotEmpty) {
        getNextQuestion();
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
    currentCountry = countries[random.nextInt(countries.length)];
    
    String correctCapital = currentCountry['capital'][0];
    options = [correctCapital];

    // Générer 3 autres capitales aléatoirement
    while (options.length < 4) {
      var randomCountry = countries[random.nextInt(countries.length)];
      if (randomCountry['capital'] != null && randomCountry['capital'].isNotEmpty) {
        String capital = randomCountry['capital'][0];
        if (!options.contains(capital)) {
          options.add(capital);
        }
      }
    }

    options.shuffle();
    setState(() {
      buttonColors = List.generate(4, (_) => const Color(0xFF26A69A));
      answerRevealed = false;
      selectedAnswer = null;
    });

    _questionAnimationController.reset();
    _questionAnimationController.forward();
  }

  void checkAnswer(String selectedCapital, int index) {
    if (answerRevealed) return;

    setState(() {
      selectedAnswer = selectedCapital;
      answerRevealed = true;
    });

    String correctCapital = currentCountry['capital'][0];
    
    if (selectedCapital == correctCapital) {
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

      // Montrer la bonne réponse
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          int correctIndex = options.indexOf(correctCapital);
          if (correctIndex != -1) {
            buttonColors[correctIndex] = const Color(0xFF4CAF50);
          }
        });
      });
    }

    // Passer à la question suivante ou terminer le jeu
    Future.delayed(const Duration(seconds: 2), () {
      if (selectedCapital != correctCapital) {
        setState(() {
          gameOver = true;
        });
      } else {
        setState(() {
          questionNumber++;
        });
        getNextQuestion();
      }
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
              _buildHeader(),
              Expanded(
                child: isLoading
                    ? _buildLoadingScreen()
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
          ),
          Column(
            children: [
              Text(
                'Question $questionNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              AnimatedBuilder(
                animation: _scoreAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scoreAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Score: $score',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
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
          IconButton(
            onPressed: () => _showHint(),
            icon: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
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
            'Chargement des capitales...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
              Icons.location_city,
              size: 80,
              color: Color(0xFF667eea),
            ),
            const SizedBox(height: 20),
            const Text(
              'Quiz terminé !',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Score final: $score/${questionNumber - 1}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF667eea),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _getScoreMessage(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        score = 0;
                        questionNumber = 1;
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
        SlideTransition(
          position: _questionSlideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Question
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_city,
                          size: 60,
                          color: Color(0xFF667eea),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Quelle est la capitale de :',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          currentCountry['name']?['common'] ?? '',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        if (currentCountry['region'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              currentCountry['region'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF667eea),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Options de réponse
                Expanded(
                  flex: 3,
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
                              elevation: answerRevealed && selectedAnswer == options[i] ? 8 : 3,
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

  String _getScoreMessage() {
    double percentage = (score / (questionNumber - 1)) * 100;
    if (percentage >= 80) {
      return 'Excellent ! Vous maîtrisez bien les capitales !';
    } else if (percentage >= 60) {
      return 'Bien joué ! Continuez à apprendre !';
    } else if (percentage >= 40) {
      return 'Pas mal ! Il y a encore du progrès à faire.';
    } else {
      return 'Continuez à étudier, vous allez y arriver !';
    }
  }

  void _showHint() {
    if (currentCountry.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.amber),
            SizedBox(width: 10),
            Text('Indice'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Région: ${currentCountry['region'] ?? 'N/A'}'),
            if (currentCountry['population'] != null)
              Text('Population du pays: ${_formatNumber(currentCountry['population'])}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  String _formatNumber(dynamic number) {
    if (number == null) return 'N/A';
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }
}