import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import '../constants.dart';

const String baseUrl = 'https://localhost:5000/api'; // Define your base URL here

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<dynamic> leaderboard = [];

  Future<void> fetchLeaderboard() async {
    final response = await http.get(Uri.parse('$baseUrl/score/leaderboard'));

    if (response.statusCode == 200) {
      setState(() {
        leaderboard = jsonDecode(response.body);
      });
    } else {
      // Handle error
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
      appBar: AppBar(title: Text('Leaderboard')),
      body: ListView.builder(
        itemCount: leaderboard.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(leaderboard[index]['avatar']),
            ),
            title: Text(leaderboard[index]['username']),
            trailing: Text(leaderboard[index]['score'].toString()),
          );
        },
      ),
    );
  }
}