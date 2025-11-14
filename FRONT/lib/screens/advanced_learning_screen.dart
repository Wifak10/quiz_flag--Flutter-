import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/data_service.dart';
import '../theme/responsive_theme.dart';
import '../widgets/common/animated_widgets.dart';

class AdvancedLearningScreen extends StatefulWidget {
  const AdvancedLearningScreen({super.key});

  @override
  State<AdvancedLearningScreen> createState() => _AdvancedLearningScreenState();
}

class _AdvancedLearningScreenState extends State<AdvancedLearningScreen> 
    with TickerProviderStateMixin {
  List<dynamic> countries = [];
  List<dynamic> filteredCountries = [];
  String selectedRegion = 'Tous';
  String selectedDifficulty = 'Tous';
  bool isLoading = true;
  String searchQuery = '';
  late TabController _tabController;
  late AnimationController _filterAnimationController;

  final List<String> regions = [
    'Tous', 'Europe', 'Asia', 'Africa', 'Americas', 'Oceania', 'Antarctic'
  ];
  
  final List<String> difficulties = [
    'Tous', 'Facile', 'Moyen', 'Difficile'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadCountries();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    try {
      final data = await DataService.fetchCountries();
      setState(() {
        countries = data;
        filteredCountries = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterCountries() {
    setState(() {
      filteredCountries = countries.where((country) {
        final matchesRegion = selectedRegion == 'Tous' || 
            country['region'] == selectedRegion;
        final matchesSearch = searchQuery.isEmpty || 
            country['name']['common'].toLowerCase().contains(searchQuery.toLowerCase());
        final matchesDifficulty = selectedDifficulty == 'Tous' || 
            _getDifficulty(country) == selectedDifficulty;
        return matchesRegion && matchesSearch && matchesDifficulty;
      }).toList();
    });
  }

  String _getDifficulty(Map<String, dynamic> country) {
    final population = country['population'] ?? 0;
    if (population > 50000000) return 'Facile';
    if (population > 10000000) return 'Moyen';
    return 'Difficile';
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
              _buildSearchAndFilters(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCountriesView(),
                    _buildGeographyView(),
                    _buildCultureView(),
                    _buildStatisticsView(),
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
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 24.sp),
          ),
          Expanded(
            child: Text(
              'Apprentissage Avancé',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () => _showFilterDialog(),
            icon: Icon(Icons.tune, color: Colors.white, size: 24.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          // Barre de recherche
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: TextField(
              onChanged: (value) {
                searchQuery = value;
                _filterCountries();
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un pays...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            searchQuery = '';
                            _filterCountries();
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(15.w),
              ),
            ),
          ),
          SizedBox(height: 15.h),
          
          // Filtres rapides
          Row(
            children: [
              Expanded(
                child: _buildQuickFilter('Région', selectedRegion, regions, (value) {
                  setState(() {
                    selectedRegion = value;
                    _filterCountries();
                  });
                }),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildQuickFilter('Difficulté', selectedDifficulty, difficulties, (value) {
                  setState(() {
                    selectedDifficulty = value;
                    _filterCountries();
                  });
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilter(String label, String selected, List<String> options, Function(String) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isExpanded: true,
          dropdownColor: const Color(0xFF667eea),
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(fontSize: 14.sp)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15.r),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp),
        tabs: [
          Tab(text: 'Pays', icon: Icon(Icons.flag, size: 18.sp)),
          Tab(text: 'Géographie', icon: Icon(Icons.terrain, size: 18.sp)),
          Tab(text: 'Culture', icon: Icon(Icons.palette, size: 18.sp)),
          Tab(text: 'Stats', icon: Icon(Icons.analytics, size: 18.sp)),
        ],
      ),
    );
  }

  Widget _buildCountriesView() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return AnimationLimiter(
      child: GridView.builder(
        padding: EdgeInsets.all(20.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveTheme.getGridCrossAxisCount(context),
          childAspectRatio: 0.75,
          crossAxisSpacing: 15.w,
          mainAxisSpacing: 15.h,
        ),
        itemCount: filteredCountries.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: ResponsiveTheme.getGridCrossAxisCount(context),
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _buildAdvancedCountryCard(filteredCountries[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdvancedCountryCard(Map<String, dynamic> country) {
    return AnimatedCard(
      onTap: () => _showAdvancedCountryDetails(country),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drapeau avec overlay de difficulté
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                  child: CachedNetworkImage(
                    imageUrl: country['flags']?['png'] ?? '',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.flag, size: 40.sp),
                    ),
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(_getDifficulty(country)),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      _getDifficulty(country)[0],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Informations du pays
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country['name']?['common'] ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.location_city, size: 12.sp, color: Colors.grey[600]),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          country['capital']?.isNotEmpty == true 
                              ? country['capital'][0] 
                              : 'N/A',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.people, size: 12.sp, color: Colors.grey[600]),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          _formatPopulation(country['population']),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Facile':
        return Colors.green;
      case 'Moyen':
        return Colors.orange;
      case 'Difficile':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatPopulation(dynamic population) {
    if (population == null) return 'N/A';
    if (population >= 1000000) {
      return '${(population / 1000000).toStringAsFixed(1)}M';
    } else if (population >= 1000) {
      return '${(population / 1000).toStringAsFixed(0)}K';
    }
    return population.toString();
  }

  Widget _buildGeographyView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _buildInfoCard(
            'Continents et Régions',
            'Explorez les différentes régions du monde',
            Icons.public,
            Colors.blue,
            () => _showRegionsInfo(),
          ),
          SizedBox(height: 15.h),
          _buildInfoCard(
            'Océans et Mers',
            'Découvrez les étendues d\'eau du globe',
            Icons.water,
            Colors.cyan,
            () => _showOceansInfo(),
          ),
          SizedBox(height: 15.h),
          _buildInfoCard(
            'Montagnes et Reliefs',
            'Les plus hauts sommets du monde',
            Icons.terrain,
            Colors.brown,
            () => _showMountainsInfo(),
          ),
          SizedBox(height: 15.h),
          _buildInfoCard(
            'Climat et Zones',
            'Les différents climats terrestres',
            Icons.wb_sunny,
            Colors.orange,
            () => _showClimateInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildCultureView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _buildInfoCard(
            'Langues du Monde',
            'Découvrez la diversité linguistique',
            Icons.language,
            Colors.purple,
            () => _showLanguagesInfo(),
          ),
          SizedBox(height: 15.h),
          _buildInfoCard(
            'Monnaies',
            'Les devises utilisées dans le monde',
            Icons.monetization_on,
            Colors.green,
            () => _showCurrenciesInfo(),
          ),
          SizedBox(height: 15.h),
          _buildInfoCard(
            'Traditions',
            'Coutumes et traditions culturelles',
            Icons.festival,
            Colors.pink,
            () => _showTraditionsInfo(),
          ),
          SizedBox(height: 15.h),
          _buildInfoCard(
            'Patrimoine UNESCO',
            'Sites du patrimoine mondial',
            Icons.account_balance,
            Colors.indigo,
            () => _showUNESCOInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsView() {
    final regionStats = <String, int>{};
    final populationStats = <String, int>{};
    
    for (var country in countries) {
      final region = country['region'] ?? 'Autre';
      regionStats[region] = (regionStats[region] ?? 0) + 1;
      
      final population = country['population'] ?? 0;
      if (population > 100000000) {
        populationStats['Plus de 100M'] = (populationStats['Plus de 100M'] ?? 0) + 1;
      } else if (population > 50000000) {
        populationStats['50M - 100M'] = (populationStats['50M - 100M'] ?? 0) + 1;
      } else if (population > 10000000) {
        populationStats['10M - 50M'] = (populationStats['10M - 50M'] ?? 0) + 1;
      } else {
        populationStats['Moins de 10M'] = (populationStats['Moins de 10M'] ?? 0) + 1;
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques Mondiales',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),
          
          _buildStatsSection('Répartition par Région', regionStats),
          SizedBox(height: 20.h),
          _buildStatsSection('Répartition par Population', populationStats),
          SizedBox(height: 20.h),
          
          _buildGlobalStats(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return AnimatedCard(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(String title, Map<String, int> stats) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
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
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15.h),
          ...stats.entries.map((entry) => Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: TextStyle(fontSize: 14.sp)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    entry.value.toString(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildGlobalStats() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
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
          Text(
            'Statistiques Globales',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15.h),
          _buildStatRow('Nombre total de pays', countries.length.toString()),
          _buildStatRow('Continents', '7'),
          _buildStatRow('Océans principaux', '5'),
          _buildStatRow('Langues officielles', '200+'),
          _buildStatRow('Monnaies différentes', '180+'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtres Avancés'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Fonctionnalité à venir dans la prochaine mise à jour !'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAdvancedCountryDetails(Map<String, dynamic> country) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  
                  // Drapeau et nom
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.r),
                    child: CachedNetworkImage(
                      imageUrl: country['flags']?['png'] ?? '',
                      width: double.infinity,
                      height: 200.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  
                  Text(
                    country['name']?['common'] ?? '',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  
                  // Informations détaillées
                  _buildDetailSection('Informations Générales', [
                    _buildDetailRow('Nom officiel', country['name']?['official'] ?? 'N/A'),
                    _buildDetailRow('Capitale', country['capital']?.isNotEmpty == true ? country['capital'][0] : 'N/A'),
                    _buildDetailRow('Région', country['region'] ?? 'N/A'),
                    _buildDetailRow('Sous-région', country['subregion'] ?? 'N/A'),
                  ]),
                  
                  _buildDetailSection('Démographie', [
                    _buildDetailRow('Population', _formatNumber(country['population'])),
                    _buildDetailRow('Superficie', '${_formatNumber(country['area'])} km²'),
                    _buildDetailRow('Densité', _calculateDensity(country)),
                  ]),
                  
                  if (country['currencies'] != null)
                    _buildDetailSection('Économie', [
                      _buildDetailRow('Monnaie', _getCurrencyInfo(country['currencies'])),
                    ]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 10.h),
        ...children,
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(dynamic number) {
    if (number == null) return 'N/A';
    if (number is int) {
      return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]} ',
      );
    }
    return number.toString();
  }

  String _calculateDensity(Map<String, dynamic> country) {
    final population = country['population'];
    final area = country['area'];
    if (population != null && area != null && area > 0) {
      final density = population / area;
      return '${density.toStringAsFixed(1)} hab/km²';
    }
    return 'N/A';
  }

  String _getCurrencyInfo(Map<String, dynamic> currencies) {
    if (currencies.isEmpty) return 'N/A';
    final currency = currencies.values.first;
    final name = currency['name'] ?? '';
    final symbol = currency['symbol'] ?? '';
    return symbol.isNotEmpty ? '$name ($symbol)' : name;
  }

  // Méthodes pour afficher les informations détaillées
  void _showRegionsInfo() => _showInfoDialog('Continents et Régions', 'Information détaillée sur les régions du monde...');
  void _showOceansInfo() => _showInfoDialog('Océans et Mers', 'Information détaillée sur les océans...');
  void _showMountainsInfo() => _showInfoDialog('Montagnes et Reliefs', 'Information détaillée sur les montagnes...');
  void _showClimateInfo() => _showInfoDialog('Climat et Zones', 'Information détaillée sur les climats...');
  void _showLanguagesInfo() => _showInfoDialog('Langues du Monde', 'Information détaillée sur les langues...');
  void _showCurrenciesInfo() => _showInfoDialog('Monnaies', 'Information détaillée sur les monnaies...');
  void _showTraditionsInfo() => _showInfoDialog('Traditions', 'Information détaillée sur les traditions...');
  void _showUNESCOInfo() => _showInfoDialog('Patrimoine UNESCO', 'Information détaillée sur les sites UNESCO...');

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}