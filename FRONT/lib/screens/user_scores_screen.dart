import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserScoresScreen extends StatefulWidget {
  const UserScoresScreen({super.key});

  @override
  _UserScoresScreenState createState() => _UserScoresScreenState();
}

class _UserScoresScreenState extends State<UserScoresScreen> {
  List<dynamic> userScores = [];
  String errorMessage = '';

  Future<void> fetchUserScores() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId'); // Assurez-vous que le userId est stocké dans les préférences partagées

    if (userId == null || token == null) {
      setState(() {
        errorMessage = 'User ID or token not found';
      });
      print('User ID or token not found');
      return;
    }

    print('Token récupéré: $token');
    print('User ID récupéré: $userId');

    final response = await http.get(
      Uri.parse('http://localhost:5000/api/score/user-scores/$userId'), // Utiliser le userId dans l'URL
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      setState(() {
        userScores = jsonDecode(response.body);
        errorMessage = '';
      });
    } else {
      // Handle error
      setState(() {
        errorMessage = 'Failed to load user scores';
      });
      print('Failed to load user scores: ${response.body}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserScores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mes Scores')),
      body: errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : userScores.isEmpty
              ? Center(child: CircularProgressIndicator())  // Ajout d'un loading indicator
              : ListView.builder(
                  itemCount: userScores.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Score: ${userScores[index]['score']}'),
                      subtitle: Text('Date: ${userScores[index]['game_date']}'), // Assurez-vous que le champ est correct
                    );
                  },
                ),
    );
  }
}