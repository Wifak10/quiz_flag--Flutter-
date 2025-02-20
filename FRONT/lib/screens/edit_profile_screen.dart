import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'user_profile.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfileScreen({required this.userProfile, super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _avatarUrlController;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.userProfile.username);
    _emailController = TextEditingController(text: widget.userProfile.email);
    _avatarUrlController = TextEditingController(text: widget.userProfile.avatarUrl);
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.put(
          Uri.parse('http://localhost:5000/api/profile'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${await _getToken()}',
          },
          body: jsonEncode(<String, String>{
            'username': _usernameController.text,
            'email': _emailController.text,
            'avatarUrl': _avatarUrlController.text,
          }),
        );

        if (response.statusCode == 200) {
          Navigator.pop(context, UserProfile.fromJson(jsonDecode(response.body)));
        } else {
          setState(() {
            errorMessage = 'Failed to update profile';
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Failed to update profile';
        });
      }
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modifier le profil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Nom d\'utilisateur'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom d\'utilisateur';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _avatarUrlController,
                decoration: InputDecoration(labelText: 'URL de l\'avatar'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une URL d\'avatar';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Enregistrer'),
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}