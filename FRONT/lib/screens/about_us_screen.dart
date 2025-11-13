import 'package:flutter/material.dart';
import 'dart:math';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> with TickerProviderStateMixin {
  Map<String, List<String>> countriesByContinent = {
    'Europe': ['France', 'Germany', 'Italy', 'Spain', 'United Kingdom', 'Netherlands', 'Belgium', 'Portugal'],
    'Asia': ['China', 'Japan', 'India', 'South Korea', 'Thailand', 'Vietnam', 'Indonesia', 'Malaysia'],
    'Africa': ['Nigeria', 'Egypt', 'South Africa', 'Kenya', 'Morocco', 'Ghana', 'Ethiopia', 'Algeria'],
    'Americas': ['United States', 'Canada', 'Brazil', 'Mexico', 'Argentina', 'Chile', 'Colombia', 'Peru'],
    'Oceania': ['Australia', 'New Zealand', 'Fiji', 'Papua New Guinea', 'Samoa', 'Tonga', 'Vanuatu', 'Palau']
  };
  
  String selectedContinent = '';
  List<String> selectedCountries = [];
  List<String> correctCountries = [];
  List<String> userAnswers = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    selectRandomContinent();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void selectRandomContinent() {
    List<String> continents = countriesByContinent.keys.toList();
    Random random = Random();
    selectedContinent = continents[random.nextInt(continents.length)];
    selectCountries();
  }

  void selectCountries() {
    List<String> continentCountries = countriesByContinent[selectedContinent]!;
    continentCountries.shuffle();
    correctCountries = continentCountries.take(3).toList();

    List<String> otherCountries = [];
    for (String continent in countriesByContinent.keys) {
      if (continent != selectedContinent) {
        otherCountries.addAll(countriesByContinent[continent]!);
      }
    }
    
    otherCountries.shuffle();
    selectedCountries = correctCountries + otherCountries.take(3).toList();
    selectedCountries.shuffle();
  }

  void checkAnswers() {
    int correctAnswersCount = userAnswers.where((country) => correctCountries.contains(country)).length;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: correctAnswersCount >= 2 
                  ? [const Color(0xFF4CAF50), const Color(0xFF45a049)]
                  : [const Color(0xFFFF6B6B), const Color(0xFFEE5A52)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  correctAnswersCount >= 2 ? Icons.celebration : Icons.sentiment_dissatisfied,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  correctAnswersCount >= 2 ? 'Félicitations !' : 'Dommage !',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '$correctAnswersCount/3 bonnes réponses',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    resetGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: correctAnswersCount >= 2 
                      ? const Color(0xFF4CAF50) 
                      : const Color(0xFFFF6B6B),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Nouvelle partie',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      userAnswers.clear();
    });
    selectRandomContinent();
    _animationController.reset();
    _animationController.forward();
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
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
                    ),
                    const Expanded(
                      child: Text(
                        'Quiz Géographique',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Pour équilibrer avec le bouton retour
                  ],
                ),
              ),

              // Contenu principal
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Titre de la question
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.public,
                                color: Colors.white,
                                size: 30,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Continent: $selectedContinent',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Glissez 3 pays de ce continent',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),

                        // Grille des pays
                        Expanded(
                          flex: 3,
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 2.2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: selectedCountries.length,
                            itemBuilder: (context, index) {
                              final country = selectedCountries[index];
                              final isUsed = userAnswers.contains(country);
                              
                              return Draggable<String>(
                                data: country,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    width: 120,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      country,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                childWhenDragging: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.grey[400]!),
                                  ),
                                  child: Text(
                                    country,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: isUsed 
                                      ? LinearGradient(colors: [Colors.grey[400]!, Colors.grey[500]!])
                                      : const LinearGradient(colors: [Color(0xFF26A69A), Color(0xFF00897B)]),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isUsed ? Colors.grey : const Color(0xFF26A69A)).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    country,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Zone de dépôt
                        Expanded(
                          flex: 2,
                          child: DragTarget<String>(
                            onAccept: (country) {
                              setState(() {
                                if (!userAnswers.contains(country) && userAnswers.length < 3) {
                                  userAnswers.add(country);
                                }
                              });
                            },
                            onWillAccept: (data) => userAnswers.length < 3,
                            builder: (context, candidateData, rejectedData) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF26A69A).withOpacity(0.1),
                                  border: Border.all(
                                    color: const Color(0xFF26A69A),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: userAnswers.isEmpty
                                    ? const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.touch_app,
                                            size: 50,
                                            color: Color(0xFF26A69A),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Glissez les pays ici',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Color(0xFF26A69A),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '(3 pays maximum)',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF26A69A),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          alignment: WrapAlignment.center,
                                          children: userAnswers.map((answer) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [Color(0xFF26A69A), Color(0xFF00897B)],
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFF26A69A).withOpacity(0.3),
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    answer,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        userAnswers.remove(answer);
                                                      });
                                                    },
                                                    child: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Bouton de vérification
                        ElevatedButton(
                          onPressed: userAnswers.isNotEmpty ? checkAnswers : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 8,
                            disabledBackgroundColor: Colors.grey[300],
                          ),
                          child: Text(
                            userAnswers.isEmpty 
                              ? 'Sélectionnez des pays' 
                              : 'Vérifier mes réponses (${userAnswers.length}/3)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}