import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:trending_git_repo/screens/home_screen.dart';

import '../api_calls.dart';
import 'package:http/http.dart' as http;

import '../models/git_repo_model.dart';

class NetworkErrorScreen extends StatefulWidget {
  final Function() refresh;

  const NetworkErrorScreen({Key key, this.refresh}) : super(key: key);

  @override
  _NetworkErrorScreenState createState() => _NetworkErrorScreenState();
}

class _NetworkErrorScreenState extends State<NetworkErrorScreen> {
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
            const Text('Trending'),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: POPUP MENU FOR STARRED REPO
            },
            icon: Icon(Icons.more_vert_rounded),
          )
        ],
      ),
      body: Column(
        children: [
          /// error image
          Flexible(
            flex: 1,
            child: Image.asset(
              'assets/images/error_image.png',
              // height: height / 2,
              fit: BoxFit.fill,
            ),
          ),
          Flexible(
            flex: 1,
            child: Column(
              children: [
                /// something went wrong
                AutoSizeText(
                  'Something went wrong...',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8.0),

                /// an alien is probably blocking your signal.
                AutoSizeText(
                  'An alien is probably blocking your signal.',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                // Expanded(child: Container()),
                Spacer(),

                /// retry button
                GestureDetector(
                  onTap: () async {
                    // widget.refresh();
                    List<dynamic> trendingRepos = [];
                    http.Response response =
                        await Apis().trendingRepoApi(context: context);
                    if (response.statusCode == 200) {
                      print('Successful');
                      final repoListFromResponse = jsonDecode(response.body);
                      for (var repoInJson in repoListFromResponse) {
                        var repoFromJson = GitRepoModel.fromJson(repoInJson);
                        trendingRepos.add(repoFromJson);
                      }
                      print(trendingRepos.toList());
                      Navigator.pushReplacement(
                        context,
                        PageTransition(
                          child: HomeScreen(trendingRepos: trendingRepos),
                          type: PageTransitionType.rippleRightUp,
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: width,
                    margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.green, width: 3.0),
                    ),
                    child: Text(
                      'RETRY',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.0,
                        color: Colors.green,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.05),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
