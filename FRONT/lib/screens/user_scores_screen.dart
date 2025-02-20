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
    final userId = prefs.getInt('userId');

    if (userId == null || token == null) {
      setState(() {
        errorMessage = 'User ID or token not found';
      });
      return;
    }

    final response = await http.get(
      Uri.parse('http://localhost:5000/api/score/user-scores/$userId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        userScores = jsonDecode(response.body);
        errorMessage = '';
      });
    } else {
      setState(() {
        errorMessage = 'Failed to load user scores';
      });
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
      appBar: AppBar(
        title: Text('Mes Scores'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 5,
      ),
      body: errorMessage.isNotEmpty
          ? Center(
              child: Text(
                errorMessage,
                style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.w600),
              ),
            )
          : userScores.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: userScores.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 8,
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          'Score: ${userScores[index]['score']}',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                        ),
                        subtitle: Text(
                          'Date: ${userScores[index]['game_date']}',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurpleAccent,
                          child: Icon(
                            Icons.score,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}