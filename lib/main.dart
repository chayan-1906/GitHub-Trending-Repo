import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trending_git_repo/splash_screen.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Github Trending Repo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        appBarTheme:
            AppBarTheme(color: Colors.white, centerTitle: true, elevation: 0.0),
      ),
      home: const SplashScreen(),
    );
  }
}
