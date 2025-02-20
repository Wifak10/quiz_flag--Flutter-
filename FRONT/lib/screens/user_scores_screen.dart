import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'https://localhost:5000/api'; // Replace with your actual base URL
// import '../constants.dart';

class UserScoresScreen extends StatefulWidget {
  const UserScoresScreen({super.key});

  @override
  _UserScoresScreenState createState() => _UserScoresScreenState();
}

class _UserScoresScreenState extends State<UserScoresScreen> {
  List<dynamic> userScores = [];

  Future<void> fetchUserScores() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/score/user-scores'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        userScores = jsonDecode(response.body);
      });
    } else {
      // Handle error
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
      appBar: AppBar(title: Text('My Scores')),
      body: ListView.builder(
        itemCount: userScores.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Score: ${userScores[index]['score']}'),
            subtitle: Text('Date: ${userScores[index]['created_at']}'),
          );
        },
      ),
    );
  }
}