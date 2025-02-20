import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? userProfile;
  String errorMessage = '';

  Future<void> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/profile'), // Assurez-vous que l'URL est correcte
        headers: <String, String>{
          'Authorization': 'Bearer ${await _getToken()}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userProfile = UserProfile.fromJson(jsonDecode(response.body));
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load profile';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch profile';
      });
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil')),
      body: errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : userProfile == null
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(userProfile!.avatarUrl),
                      ),
                      SizedBox(height: 20),
                      Text(
                        userProfile!.username,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        userProfile!.email,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Naviguer vers l'écran de modification du profil
                        },
                        child: Text('Modifier le profil'),
                      ),
                    ],
                  ),
                ),
    );
  }
}