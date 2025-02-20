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
        Uri.parse('http://localhost:5000/api/leaderboard/leaderboard'),
      );

      if (response.statusCode == 200) {
        setState(() {
          leaderboard = jsonDecode(response.body);
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load leaderboard';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch leaderboard';
      });
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
      appBar: AppBar(
        title: Text('Classement'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: errorMessage.isNotEmpty
          ? Center(
              child: Text(
                errorMessage,
                style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.w600),
              ),
            )
          : leaderboard.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          'Utilisateur: ${leaderboard[index]['username']}',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Score: ${leaderboard[index]['score']}',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.star, color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}