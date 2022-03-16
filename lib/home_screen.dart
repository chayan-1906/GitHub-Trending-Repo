import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(MaterialCommunityIcons.github_face, size: width * 0.07),
            Flexible(child: SizedBox(width: width * 0.05)),
            const Text('Github Trending Repo'),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
    );
  }
}
