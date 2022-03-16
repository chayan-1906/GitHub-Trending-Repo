import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Github Trending Repo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        appBarTheme: AppBarTheme(
          color: Colors.grey.shade700,
          centerTitle: true,
          elevation: 0.0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
