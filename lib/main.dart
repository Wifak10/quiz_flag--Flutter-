import 'package:flutter/material.dart';
import 'package:quiz/routes/app_routes.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeu des Pays',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    
    );
  }
}
