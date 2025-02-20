import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SubmitScoreScreen extends StatefulWidget {
  const SubmitScoreScreen({super.key});

  @override
  _SubmitScoreScreenState createState() => _SubmitScoreScreenState();
}

class _SubmitScoreScreenState extends State<SubmitScoreScreen> {
  final TextEditingController _scoreController = TextEditingController();

  Future<void> submitScore() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId'); // Assurez-vous que le userId est stocké dans les préférences partagées

    if (userId == null || token == null) {
      print('User ID or token not found');
      return;
    }
  print('score: ${_scoreController.text}');

    final response = await http.post(
      Uri.parse('http://localhost:5000/api/score'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'score': int.parse(_scoreController.text),
      }),
    );
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      print('Score enregistré avec succès');
    } else {
      print('Erreur lors de la soumission du score: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Soumettre un score')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _scoreController,
              decoration: InputDecoration(labelText: 'Score'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitScore,
              child: Text('Soumettre'),
            ),
          ],
        ),
      ),
    );
  }
}