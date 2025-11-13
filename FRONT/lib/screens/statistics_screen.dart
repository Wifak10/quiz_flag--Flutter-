import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with TickerProviderStateMixin {
  Map<String, dynamic> stats = {};
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsData = prefs.getString('user_statistics');
      
      if (statsData != null) {
        setState(() {
          stats = jsonDecode(statsData);
          isLoading = false;
        });
      } else {
        setState(() {
          stats = _getDefaultStats();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        stats = _getDefaultStats();
        isLoading = false;
      });
    }
  }

  Map<String, dynamic> _getDefaultStats() {
    return {
      'totalGames': 0,
      'totalScore': 0,
      'bestScore': 0,
      'averageScore': 0.0,
      'flagQuizStats': {
        'played': 0,
        'bestScore': 0,
        'totalScore': 0,
      },
      'capitalQuizStats': {
        'played': 0,
        'bestScore': 0,
        'totalScore': 0,
      },
      'learningStats': {
        'countriesLearned': 0,
        'capitalsLearned': 0,
        'timeSpent': 0,
      },
      'achievements': [],
      'streaks': {
        'current': 0,
        'best': 0,
      },
    };
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
              _buildTabBar(),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(),
                          _buildDetailedStatsTab(),
                          _buildAchievementsTab(),
                        ],
                      ),
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
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
          ),
          const Expanded(
            child: Text(
              'Statistiques',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: _resetStats,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        tabs: const [
          Tab(text: 'Aperçu', icon: Icon(Icons.dashboard, size: 20)),
          Tab(text: 'Détails', icon: Icon(Icons.analytics, size: 20)),
          Tab(text: 'Succès', icon: Icon(Icons.emoji_events, size: 20)),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: AnimationLimiter(
        child: Column(
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              _buildStatCard(
                'Parties jouées',
                '${stats['totalGames'] ?? 0}',
                Icons.games,
                Colors.blue,
              ),
              const SizedBox(height: 15),
              _buildStatCard(
                'Meilleur score',
                '${stats['bestScore'] ?? 0}',
                Icons.star,
                Colors.amber,
              ),
              const SizedBox(height: 15),
              _buildStatCard(
                'Score moyen',
                '${(stats['averageScore'] ?? 0.0).toStringAsFixed(1)}',
                Icons.trending_up,
                Colors.green,
              ),
              const SizedBox(height: 15),
              _buildStatCard(
                'Série actuelle',
                '${stats['streaks']?['current'] ?? 0}',
                Icons.local_fire_department,
                Colors.orange,
              ),
              const SizedBox(height: 20),
              _buildProgressCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Quiz des Drapeaux'),
          _buildQuizStatsCard(stats['flagQuizStats'] ?? {}),
          const SizedBox(height: 20),
          _buildSectionTitle('Quiz des Capitales'),
          _buildQuizStatsCard(stats['capitalQuizStats'] ?? {}),
          const SizedBox(height: 20),
          _buildSectionTitle('Mode Apprentissage'),
          _buildLearningStatsCard(),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    final achievements = _getAllAchievements();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: AnimationLimiter(
        child: Column(
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: achievements.map((achievement) => 
              _buildAchievementCard(achievement)
            ).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final totalGames = stats['totalGames'] ?? 0;
    final progress = (totalGames / 100).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progression vers Expert',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            minHeight: 8,
          ),
          const SizedBox(height: 10),
          Text(
            '$totalGames / 100 parties',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildQuizStatsCard(Map<String, dynamic> quizStats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuizStatItem('Parties', '${quizStats['played'] ?? 0}'),
              _buildQuizStatItem('Meilleur', '${quizStats['bestScore'] ?? 0}'),
              _buildQuizStatItem('Total', '${quizStats['totalScore'] ?? 0}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLearningStatsCard() {
    final learningStats = stats['learningStats'] ?? {};
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLearningStatItem(
                'Pays appris',
                '${learningStats['countriesLearned'] ?? 0}',
                Icons.flag,
              ),
              _buildLearningStatItem(
                'Capitales',
                '${learningStats['capitalsLearned'] ?? 0}',
                Icons.location_city,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLearningStatItem(
                'Temps passé',
                '${learningStats['timeSpent'] ?? 0}min',
                Icons.access_time,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLearningStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF667eea), size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final isUnlocked = achievement['unlocked'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isUnlocked 
                  ? Colors.amber.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              achievement['icon'],
              color: isUnlocked ? Colors.amber : Colors.grey,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.black87 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  achievement['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isUnlocked ? Colors.grey[600] : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            const Icon(Icons.check_circle, color: Colors.green, size: 24),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAllAchievements() {
    return [
      {
        'title': 'Premier pas',
        'description': 'Jouer votre première partie',
        'icon': Icons.play_arrow,
        'unlocked': (stats['totalGames'] ?? 0) >= 1,
      },
      {
        'title': 'Débutant',
        'description': 'Jouer 10 parties',
        'icon': Icons.sports_esports,
        'unlocked': (stats['totalGames'] ?? 0) >= 10,
      },
      {
        'title': 'Passionné',
        'description': 'Jouer 50 parties',
        'icon': Icons.favorite,
        'unlocked': (stats['totalGames'] ?? 0) >= 50,
      },
      {
        'title': 'Expert',
        'description': 'Jouer 100 parties',
        'icon': Icons.emoji_events,
        'unlocked': (stats['totalGames'] ?? 0) >= 100,
      },
      {
        'title': 'Score parfait',
        'description': 'Obtenir un score de 20',
        'icon': Icons.star,
        'unlocked': (stats['bestScore'] ?? 0) >= 20,
      },
      {
        'title': 'Série de feu',
        'description': 'Série de 10 bonnes réponses',
        'icon': Icons.local_fire_department,
        'unlocked': (stats['streaks']?['best'] ?? 0) >= 10,
      },
    ];
  }

  void _resetStats() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser les statistiques'),
        content: const Text('Êtes-vous sûr de vouloir effacer toutes vos statistiques ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('user_statistics');
              setState(() {
                stats = _getDefaultStats();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Réinitialiser', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}