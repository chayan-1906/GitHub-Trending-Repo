import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:http/http.dart' as http;
import 'package:trending_git_repo/api_calls.dart';
import 'package:trending_git_repo/global_functions/check_invalid_string.dart';
import 'package:trending_git_repo/screens/network_error_screen.dart';
import 'package:trending_git_repo/widgets/expandable_container.dart';

import '../models/git_repo_model.dart';
import '../widgets/shimmer_widget.dart';

class HomeScreen extends StatefulWidget {
  final List<dynamic> trendingRepos;

  const HomeScreen({Key key, this.trendingRepos}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = false;
  bool customTileExpanded = false;
  List<dynamic> trendingRepos = [];
  bool isExpanded = false;
  int tapped;
  Map<String, List<dynamic>> selectedRepoLang = {};

  Future<http.Response> callTrendingRepoApi() async {
    setState(() {
      loading = true;
    });
    http.Response response = await Apis().trendingRepoApi(context: context);
    if (response.statusCode == 200) {
      print('Successful');
      final repoListFromResponse = jsonDecode(response.body);
      for (var repoInJson in repoListFromResponse) {
        var repoFromJson = GitRepoModel.fromJson(repoInJson);
        trendingRepos.add(repoFromJson);
      }
      // print(trendingRepos.toList());
      for (var trendingRepoItem in trendingRepos) {
        selectedRepoLang.addEntries([
          MapEntry(
            /// key
            trendingRepoItem.language,

            /// value
            trendingRepos
                .where((trendingRepo) =>
                    trendingRepo.language == trendingRepoItem.language)
                .toList(),
          ),
        ]);
      }
    } else {
      print('Error');
      Navigator.pushReplacement(
        context,
        PageTransition(
          child: NetworkErrorScreen(refresh: refresh),
          type: PageTransitionType.rippleRightUp,
        ),
      );
    }
    setState(() {
      loading = false;
    });
    print(selectedRepoLang);
    return response;
  }

  refresh() async {
    await callTrendingRepoApi();
  }

  PopupMenuButton<String> showPopupMenu() {
    return PopupMenuButton(
        elevation: 8.0,
        color: Colors.white,
        padding: EdgeInsets.all(0.0),
        onSelected: (value) {
          print(value);
          // TODO: Navigate to favourites screen
        },
        itemBuilder: (BuildContext context) {
          print('showPopupMenu');
          return [
            /// favourites
            PopupMenuItem(
              value: 'Favourites',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    MaterialIcons.favorite,
                    color: Colors.black,
                  ),
                  SizedBox(width: 15.0),
                  Text(
                    'Favourites',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ];
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refresh();
    if (widget.trendingRepos != null) {
      trendingRepos.clear();
      trendingRepos = widget.trendingRepos;
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
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
          showPopupMenu(),
        ],
      ),
      body: loading
          ? ShimmerWidget()
          : RefreshIndicator(
              onRefresh: () => refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: trendingRepos.length,
                itemBuilder: (BuildContext context, int index) {
                  final githubRepoItem = trendingRepos[index];
                  String formattedColor;
                  if (!isStringInvalid(text: githubRepoItem.languageColor)) {
                    formattedColor =
                        "0xFF${githubRepoItem.languageColor.replaceAll('#', '')}";
                  } else {
                    formattedColor = '0xFFFFFFFF';
                  }
                  Color color =
                      !isStringInvalid(text: githubRepoItem.languageColor)
                          ? Color(int.parse(formattedColor))
                          : const Color(0xFFFFFFFF);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanded = ((tapped == null) ||
                                ((index == tapped) || !isExpanded))
                            ? !isExpanded
                            : isExpanded;
                        tapped = index;
                      });
                    },
                    child: ExpandableContainer(
                      expanded: index == tapped ? isExpanded : false,
                      collapsedChild: Container(
                        decoration: BoxDecoration(
                          // color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          children: [
                            /// profile avatar
                            SizedBox(
                              width: 50.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: CachedNetworkImage(
                                  // TODO: Whose avatar url???
                                  imageUrl: githubRepoItem.builtBy[0]['avatar'],
                                  fit: BoxFit.cover,
                                  height: 50.0,
                                  width: 50.0,
                                  placeholder: (context, url) => Image.asset(
                                    'assets/images/profile_image.png',
                                    width: MediaQuery.of(context).size.width *
                                        0.60,
                                    fit: BoxFit.contain,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Image.network(
                                    'https://www.gemkom.com.tr/wp-content/uploads/2020/02/NO_IMG_600x600-1.png',
                                    fit: BoxFit.contain,
                                    width: MediaQuery.of(context).size.width *
                                        0.60,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20.0),

                            /// username & repo name
                            SizedBox(
                              width: width -
                                  100.0, // screenWidth - profileAvatarWidth - padding (approx.)
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// username
                                  Text(
                                    githubRepoItem.username,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),

                                  /// repo name
                                  Text(
                                    githubRepoItem.repositoryName,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      expandedChild: Container(
                        decoration: BoxDecoration(
                          // color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          children: [
                            /// profile avatar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: CachedNetworkImage(
                                // TODO: Whose avatar url???
                                imageUrl: githubRepoItem.builtBy[0]['avatar'],
                                fit: BoxFit.cover,
                                height: 50.0,
                                width: 50.0,
                                placeholder: (context, url) => Image.asset(
                                  'assets/images/profile_image.png',
                                  width:
                                      MediaQuery.of(context).size.width * 0.60,
                                  fit: BoxFit.contain,
                                ),
                                errorWidget: (context, url, error) =>
                                    Image.network(
                                  'https://www.gemkom.com.tr/wp-content/uploads/2020/02/NO_IMG_600x600-1.png',
                                  fit: BoxFit.contain,
                                  width:
                                      MediaQuery.of(context).size.width * 0.60,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20.0),

                            /// username & repo name
                            Container(
                              width: width * 0.70,
                              child: ListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisAlignment:
                                //     MainAxisAlignment.spaceBetween,
                                children: [
                                  /// username
                                  Text(
                                    !isStringInvalid(
                                            text: githubRepoItem.username)
                                        ? githubRepoItem.username
                                        : 'N/A',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),

                                  /// repo name
                                  Text(
                                    githubRepoItem.repositoryName,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),

                                  /// description
                                  !isStringInvalid(
                                          text: githubRepoItem.description)
                                      ? Text(
                                          githubRepoItem.description,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.black,
                                          ),
                                        )
                                      : Container(),
                                  const SizedBox(height: 10.0),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      /// language
                                      !isStringInvalid(
                                              text:
                                                  githubRepoItem.languageColor)
                                          ? Row(
                                              children: [
                                                /// language color
                                                CircleAvatar(
                                                  radius: 5.0,
                                                  backgroundColor: color,
                                                ),
                                                const SizedBox(width: 4.0),

                                                /// language
                                                Text(
                                                  githubRepoItem.language,
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ],
                                            )
                                          : Container(),

                                      /// popularity
                                      !isStringInvalid(
                                              text: githubRepoItem.totalStars
                                                  .toString())
                                          ? Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                const SizedBox(width: 4.0),
                                                Text(
                                                  '${githubRepoItem.totalStars}',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ],
                                            )
                                          : Container(),

                                      /// forks
                                      !isStringInvalid(
                                              text: githubRepoItem.forks
                                                  .toString())
                                          ? Row(
                                              children: [
                                                const Icon(
                                                  Octicons.repo_forked,
                                                  color: Colors.black,
                                                ),
                                                const SizedBox(width: 4.0),
                                                Text(
                                                  '${githubRepoItem.forks}',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
