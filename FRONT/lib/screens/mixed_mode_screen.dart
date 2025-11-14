import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flip_card/flip_card.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/responsive_theme.dart';
import '../widgets/common/animated_widgets.dart';

enum QuizType { flag, capital, region, currency }

class MixedModeScreen extends StatefulWidget {
  const MixedModeScreen({super.key});

  @override
  State<MixedModeScreen> createState() => _MixedModeScreenState();
}

class _MixedModeScreenState extends State<MixedModeScreen> with TickerProviderStateMixin {
  final String url = 'https://restcountries.com/v3.1/all?fields=name,flags,region,capital,currencies';
  List<dynamic> countries = [];
  Map<String, dynamic> currentCountry = {};
  List<String> options = [];
  List<Color> buttonColors = [];
  int score = 0;
  int streak = 0;
  int maxStreak = 0;
  bool gameOver = false;
  bool answerRevealed = false;
  bool isLoading = true;
  QuizType currentQuizType = QuizType.flag;
  int questionsAnswered = 0;
  int correctAnswers = 0;

  late ConfettiController _confettiController;
  late AnimationController _scoreAnimationController;
  late AnimationController _streakAnimationController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _streakAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _streakAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _scoreAnimationController, curve: Curves.elasticOut),
    );
    _streakAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _streakAnimationController, curve: Curves.bounceOut),
    );
    fetchCountries();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scoreAnimationController.dispose();
    _streakAnimationController.dispose();
    super.dispose();
  }

  Future<void> fetchCountries() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          countries = data.where((country) => 
            country['flags'] != null && 
            country['flags']['png'] != null &&
            country['name'] != null &&
            country['name']['common'] != null
          ).toList();
          isLoading = false;
        });
        if (countries.isNotEmpty) {
          getNextQuestion();
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void getNextQuestion() {
    if (countries.isEmpty) return;

    // Changer le type de quiz de manière aléatoire
    final random = Random();
    currentQuizType = QuizType.values[random.nextInt(QuizType.values.length)];
    
    currentCountry = countries[random.nextInt(countries.length)];
    
    String correctAnswer = '';
    switch (currentQuizType) {
      case QuizType.flag:
        correctAnswer = currentCountry['name']['common'];
        break;
      case QuizType.capital:
        correctAnswer = currentCountry['capital']?.isNotEmpty == true 
            ? currentCountry['capital'][0] 
            : 'N/A';
        break;
      case QuizType.region:
        correctAnswer = currentCountry['region'] ?? 'N/A';
        break;
      case QuizType.currency:
        if (currentCountry['currencies'] != null) {
          final currencies = currentCountry['currencies'] as Map<String, dynamic>;
          correctAnswer = currencies.values.first['name'] ?? 'N/A';
        } else {
          correctAnswer = 'N/A';
        }
        break;
    }

    if (correctAnswer == 'N/A') {
      getNextQuestion();
      return;
    }

    options = [correctAnswer];
    
    // Générer les mauvaises réponses selon le type de quiz
    while (options.length < 4) {
      var randomCountry = countries[random.nextInt(countries.length)];
      String wrongAnswer = '';
      
      switch (currentQuizType) {
        case QuizType.flag:
          wrongAnswer = randomCountry['name']['common'];
          break;
        case QuizType.capital:
          wrongAnswer = randomCountry['capital']?.isNotEmpty == true 
              ? randomCountry['capital'][0] 
              : '';
          break;
        case QuizType.region:
          wrongAnswer = randomCountry['region'] ?? '';
          break;
        case QuizType.currency:
          if (randomCountry['currencies'] != null) {
            final currencies = randomCountry['currencies'] as Map<String, dynamic>;
            wrongAnswer = currencies.values.first['name'] ?? '';
          }
          break;
      }
      
      if (wrongAnswer.isNotEmpty && !options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }

    options.shuffle();
    setState(() {
      buttonColors = List.generate(4, (_) => const Color(0xFF26A69A));
      answerRevealed = false;
    });
  }

  void checkAnswer(String selectedAnswer, int index) {
    questionsAnswered++;
    String correctAnswer = '';
    
    switch (currentQuizType) {
      case QuizType.flag:
        correctAnswer = currentCountry['name']['common'];
        break;
      case QuizType.capital:
        correctAnswer = currentCountry['capital']?.isNotEmpty == true 
            ? currentCountry['capital'][0] 
            : 'N/A';
        break;
      case QuizType.region:
        correctAnswer = currentCountry['region'] ?? 'N/A';
        break;
      case QuizType.currency:
        if (currentCountry['currencies'] != null) {
          final currencies = currentCountry['currencies'] as Map<String, dynamic>;
          correctAnswer = currencies.values.first['name'] ?? 'N/A';
        }
        break;
    }

    if (selectedAnswer == correctAnswer) {
      setState(() {
        score += (10 + streak * 2); // Bonus pour les séries
        streak++;
        correctAnswers++;
        if (streak > maxStreak) maxStreak = streak;
        buttonColors[index] = const Color(0xFF4CAF50);
        _confettiController.play();
        _scoreAnimationController.forward().then((_) {
          _scoreAnimationController.reverse();
        });
        if (streak > 1) {
          _streakAnimationController.forward().then((_) {
            _streakAnimationController.reverse();
          });
        }
      });
    } else {
      setState(() {
        streak = 0;
        buttonColors[index] = const Color(0xFFE53935);
      });

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          int correctIndex = options.indexOf(correctAnswer);
          if (correctIndex != -1) {
            buttonColors[correctIndex] = const Color(0xFF4CAF50);
          }
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
        if (selectedAnswer != correctAnswer) {
          gameOver = true;
        } else {
          getNextQuestion();
        }
      });
    });
  }

  String getQuestionText() {
    switch (currentQuizType) {
      case QuizType.flag:
        return 'Quel est ce pays ?';
      case QuizType.capital:
        return 'Quelle est la capitale de ${currentCountry['name']['common']} ?';
      case QuizType.region:
        return 'Dans quelle région se trouve ${currentCountry['name']['common']} ?';
      case QuizType.currency:
        return 'Quelle est la monnaie de ${currentCountry['name']['common']} ?';
    }
  }

  Widget getQuestionWidget() {
    switch (currentQuizType) {
      case QuizType.flag:
        return ClipRRect(
          borderRadius: BorderRadius.circular(15.r),
          child: Image.network(
            currentCountry['flags']['png'],
            height: 200.h,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: const Icon(Icons.flag, size: 50),
              );
            },
          ),
        );
      default:
        return Container(
          height: 120.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getQuizIcon(),
                size: 40.sp,
                color: Colors.white,
              ),
              SizedBox(height: 8.h),
              Text(
                currentCountry['name']['common'],
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
    }
  }

  IconData _getQuizIcon() {
    switch (currentQuizType) {
      case QuizType.capital:
        return Icons.location_city;
      case QuizType.region:
        return Icons.public;
      case QuizType.currency:
        return Icons.monetization_on;
      default:
        return Icons.flag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: ResponsiveTheme.flagsBackgroundDecoration,
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
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 28.sp),
              ),
              Text(
                'Mode Mixte',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 48.w),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('Score', score.toString(), _scoreAnimation),
              _buildStatCard('Série', streak.toString(), _streakAnimation),
              _buildStatCard('Record', maxStreak.toString(), null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Animation<double>? animation) {
    Widget content = Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );

    if (animation != null) {
      return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.scale(
            scale: animation.value,
            child: content,
          );
        },
      );
    }

    return content;
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3.w,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Préparation du quiz mixte...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // Type de question
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getQuizIcon(), color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  _getQuizTypeLabel(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // Question
          AnimatedCard(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Text(
                    getQuestionText(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  getQuestionWidget(),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 30.h),
          
          // Options de réponse
          ...List.generate(options.length, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 15.h),
              child: AnimatedCard(
                delay: Duration(milliseconds: 200 * index),
                onTap: answerRevealed ? null : () => checkAnswer(options[index], index),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: buttonColors[index],
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Text(
                    options[index],
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getQuizTypeLabel() {
    switch (currentQuizType) {
      case QuizType.flag:
        return 'Drapeau';
      case QuizType.capital:
        return 'Capitale';
      case QuizType.region:
        return 'Région';
      case QuizType.currency:
        return 'Monnaie';
    }
  }

  Widget _buildGameOverScreen() {
    double accuracy = questionsAnswered > 0 ? (correctAnswers / questionsAnswered) * 100 : 0;
    
    return Center(
      child: Container(
        margin: EdgeInsets.all(20.w),
        padding: EdgeInsets.all(30.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.r),
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
            Icon(
              Icons.emoji_events,
              size: 60.sp,
              color: Colors.amber,
            ),
            SizedBox(height: 20.h),
            Text(
              'Partie terminée !',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20.h),
            _buildResultRow('Score final', score.toString()),
            _buildResultRow('Questions', questionsAnswered.toString()),
            _buildResultRow('Bonnes réponses', correctAnswers.toString()),
            _buildResultRow('Précision', '${accuracy.toStringAsFixed(1)}%'),
            _buildResultRow('Meilleure série', maxStreak.toString()),
            SizedBox(height: 30.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Retour',
                      style: TextStyle(fontSize: 16.sp, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        score = 0;
                        streak = 0;
                        maxStreak = 0;
                        questionsAnswered = 0;
                        correctAnswers = 0;
                        gameOver = false;
                        getNextQuestion();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Rejouer',
                      style: TextStyle(fontSize: 16.sp, color: Colors.white),
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

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}