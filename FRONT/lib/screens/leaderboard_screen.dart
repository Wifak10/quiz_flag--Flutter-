import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<dynamic> leaderboard = [];
  String errorMessage = '';

  Future<void> fetchLeaderboard() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/leaderboard/leaderboard'), // Utiliser http au lieu de https
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          leaderboard = jsonDecode(response.body);
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load leaderboard';
        });
        print('Failed to load leaderboard: ${response.body}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch leaderboard';
      });
      print('Failed to fetch leaderboard: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Classement')),
      body: errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : leaderboard.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Utilisateur: ${leaderboard[index]['username']}'),
                      subtitle: Text('Score: ${leaderboard[index]['score']}'),
                    );
                  },
                ),
    );
  }
}