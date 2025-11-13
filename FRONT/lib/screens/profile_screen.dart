import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../routes/app_routes.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  Map<String, dynamic> userProfile = {};
  Map<String, dynamic> userStats = {};
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Charger le profil utilisateur
      final profileData = prefs.getString('user_profile');
      if (profileData != null) {
        userProfile = jsonDecode(profileData);
      } else {
        userProfile = {
          'username': 'Joueur',
          'email': 'joueur@example.com',
          'avatar': '🌍',
          'level': 1,
          'experience': 0,
          'joinDate': DateTime.now().toIso8601String(),
        };
        await prefs.setString('user_profile', jsonEncode(userProfile));
      }
      
      // Charger les statistiques
      final statsData = prefs.getString('user_statistics');
      if (statsData != null) {
        userStats = jsonDecode(statsData);
      } else {
        userStats = {
          'totalGames': 0,
          'bestScore': 0,
          'totalScore': 0,
          'averageScore': 0.0,
        };
      }
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadUserData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildProfileCard(),
                        _buildStatsSection(),
                        _buildMenuSection(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
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
              'Mon Profil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
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
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Text(
                userProfile['avatar'] ?? '🌍',
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            userProfile['username'] ?? 'Joueur',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userProfile['email'] ?? 'joueur@example.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProfileStat('Niveau', '${userProfile['level'] ?? 1}'),
              _buildProfileStat('Expérience', '${userProfile['experience'] ?? 0}'),
              _buildProfileStat('Rang', _getUserRank()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF667eea),
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

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques rapides',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  'Parties jouées',
                  '${userStats['totalGames'] ?? 0}',
                  Icons.games,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildQuickStat(
                  'Meilleur score',
                  '${userStats['bestScore'] ?? 0}',
                  Icons.star,
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    final menuItems = [
      {
        'title': 'Statistiques détaillées',
        'subtitle': 'Voir toutes vos performances',
        'icon': Icons.analytics,
        'color': Colors.blue,
        'onTap': () => Navigator.pushNamed(context, AppRoutes.statistics),
      },
      {
        'title': 'Mes scores',
        'subtitle': 'Historique de vos parties',
        'icon': Icons.history,
        'color': Colors.green,
        'onTap': () => Navigator.pushNamed(context, AppRoutes.userScores),
      },
      {
        'title': 'Paramètres',
        'subtitle': 'Personnaliser l\'application',
        'icon': Icons.settings,
        'color': Colors.orange,
        'onTap': _showSettings,
      },
      {
        'title': 'À propos',
        'subtitle': 'Informations sur l\'app',
        'icon': Icons.info,
        'color': Colors.purple,
        'onTap': () => Navigator.pushNamed(context, AppRoutes.aboutUs),
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimationLimiter(
        child: Column(
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: menuItems.map((item) => _buildMenuItem(item)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: item['onTap'],
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item['icon'],
                    color: item['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['subtitle'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getUserRank() {
    final totalGames = userStats['totalGames'] ?? 0;
    if (totalGames >= 100) return 'Expert';
    if (totalGames >= 50) return 'Avancé';
    if (totalGames >= 20) return 'Intermédiaire';
    if (totalGames >= 5) return 'Débutant';
    return 'Novice';
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Modifier le profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nom d\'utilisateur',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: userProfile['username']),
              onChanged: (value) => userProfile['username'] = value,
            ),
            const SizedBox(height: 15),
            const Text('Choisir un avatar:'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: ['🌍', '🏆', '🚀', '⭐', '🎆', '🌈']
                  .map((emoji) => GestureDetector(
                        onTap: () => setState(() => userProfile['avatar'] = emoji),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: userProfile['avatar'] == emoji
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_profile', jsonEncode(userProfile));
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Paramètres',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              leading: const Icon(Icons.volume_up),
              title: const Text('Sons'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Mode sombre'),
              trailing: Switch(
                value: false,
                onChanged: (value) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}