import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trending_git_repo/api_calls.dart';
import 'package:trending_git_repo/global_functions/check_invalid_string.dart';
import 'package:trending_git_repo/screens/fav_repo_screen.dart';
import 'package:trending_git_repo/screens/network_error_screen.dart';
import 'package:trending_git_repo/services/shared_preference_service.dart';
import 'package:trending_git_repo/widgets/expandable_container.dart';

import '../models/git_repo_model.dart';
import '../widgets/shimmer_widget.dart';
import 'offline_home_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<dynamic> trendingRepos;

  // final String isComingFrom;

  const HomeScreen({
    Key key,
    this.trendingRepos,
    // this.isComingFrom,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = false;
  List<dynamic> trendingRepos = [];
  bool isExpanded = false;
  String tapped = '';
  Map<String, List<dynamic>> selectedRepoLang = {};
  Map<String, List<dynamic>> favRepoLang = {};
  String encodedRepoFromJson = '';
  List<String> encodedTrendingRepos = [];
  String encodedFavRepoFromJson = '';
  List<dynamic> decodedFavRepos = [];
  List<String> encodedFavRepos = [];
  SharedPreferenceService sharedPreferenceService = SharedPreferenceService();
  String expandedCardValue;

  Future<http.Response> callTrendingRepoApi() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> storedSelectedRepoLang = sharedPreferences
            .getStringList(SharedPreferenceService.TRENDING_REPO_LIST_KEY) ??
        [];
    /*if (widget.isComingFrom == 'NetworkErrorScreen') {
      sharedPreferenceService.setTrendingRepoListValue(fetchedRepos: <String>[]);
    }*/
    // print('46: $storedSelectedRepoLang');
    if (storedSelectedRepoLang.isNotEmpty) {
      /// if sharedPreferences list is not empty
      trendingRepos.clear();
      for (var element in storedSelectedRepoLang) {
        trendingRepos.add(json.decode(element));
      }
      print('50: $trendingRepos');
      for (var trendingRepoItem in trendingRepos) {
        selectedRepoLang.addEntries([
          MapEntry(
            /// key
            trendingRepoItem['language'],

            /// value
            trendingRepos
                .where((trendingRepo) =>
                    trendingRepo['language'] == trendingRepoItem['language'])
                .toList(),
          ),
        ]);
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) {
          return OfflineHomeScreen(selectedRepoLang: selectedRepoLang);
        }),
      );
    } else {
      /// if sharedPreferences list is empty
      setState(() {
        loading = true;
      });
      http.Response response = await Apis().trendingRepoApi(context: context);
      if (response.statusCode == 200) {
        print('Successful');
        trendingRepos.clear();
        final repoListFromResponse = jsonDecode(response.body);
        for (var repoInJson in repoListFromResponse) {
          var repoFromJson = GitRepoModel.fromJson(repoInJson);
          encodedRepoFromJson = jsonEncode(repoFromJson.toMap());
          trendingRepos.add(repoFromJson);
          encodedTrendingRepos.add(encodedRepoFromJson);
        }

        print('87: $trendingRepos');

        /// store list in shared preferences
        sharedPreferenceService.setTrendingRepoListValue(
            fetchedRepos: encodedTrendingRepos);
        // print(expandedCardValue);
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
      // print(selectedRepoLang);
      return response;
    }
    return null;
  }

  refresh() async {
    await callTrendingRepoApi();
  }

  PopupMenuButton<String> showPopupMenu() {
    return PopupMenuButton(
        elevation: 8.0,
        color: Colors.white,
        padding: const EdgeInsets.all(0.0),
        onSelected: (value) {
          print(value);
          Navigator.push(
            context,
            PageTransition(
              child: const FavRepoScreen(),
              type: PageTransitionType.rippleRightUp,
            ),
          );
        },
        itemBuilder: (BuildContext context) {
          print('showPopupMenu');
          return [
            /// favourites
            PopupMenuItem(
              value: 'Favourites',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Icon(MaterialIcons.favorite, color: Colors.black),
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

  Future<void> getHasExpandedCardValue() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    expandedCardValue = sharedPreferences
            .getString(SharedPreferenceService.EXPANDED_CARD_VALUE) ??
        'null';
    // if (expandedCardValue != 'null') {}
    // expandedCardValue != 'null' ? isExpanded = true : isExpanded = false;
    print('123. expandedCardValue: $expandedCardValue');
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
    getHasExpandedCardValue();
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
          ? const ShimmerWidget()
          : RefreshIndicator(
              onRefresh: () => refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: selectedRepoLang.keys.length,
                itemBuilder: (BuildContext context, int languageIndex) {
                  // print(selectedRepoLang.keys.length);
                  List keyLanguages = selectedRepoLang.keys.toList();
                  List colors = [];
                  for (var element in selectedRepoLang.values) {
                    // print(element);
                    String formattedColor;
                    Color color;
                    if (element != null &&
                        element != 'null' &&
                        element.isNotEmpty) {
                      element.forEach((elementIterator) {
                        if (!isStringInvalid(
                            text: elementIterator.languageColor)) {
                          /// if color is not null
                          formattedColor =
                              "0xFF${elementIterator.languageColor.replaceAll('#', '')}";
                          color = Color(int.parse(formattedColor));
                        } else {
                          color = Color(0xFFFFFFFF);
                        }
                      });
                    }
                    colors.add(color);
                  }
                  return ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      /// language name
                      Container(
                        decoration: BoxDecoration(
                          color: colors[languageIndex].withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: colors[languageIndex],
                            width: 2.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 15.0,
                        ),
                        child: Text(
                          keyLanguages[languageIndex] ?? 'NULL LANGUAGE',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      /// repo list of specific language
                      repositoryList(languageIndex, width, colors),
                    ],
                  );
                },
              ),
            ),
    );
  }

  ListView repositoryList(
      int languageIndex, double width, List<dynamic> colors) {
    // print('repositoryIndex: $repositoryIndex');
    List keys = selectedRepoLang.keys.toList();
    List values = selectedRepoLang[keys[languageIndex]];
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: values.length,
      itemBuilder: (BuildContext context, int index) {
        print('253: $expandedCardValue');
        // List usernames = [];
        // print(values.map((name) {
        //   print(name.username);
        //   usernames.add(name.username);
        // }));
        // if (expandedCardValue != 'null') {
        //   if (usernames.contains(values[index].username)) {
        //     print('true');
        //     // setState(() {
        //     print('$languageIndex');
        //     print('$index');
        //     tapped = '$languageIndex$index';
        //     // isExpanded = true;
        //     print('261: $tapped');
        //     print('262: $isExpanded');
        //     // });
        //   }
        // } else {
        //   tapped = '';
        //   isExpanded = false;
        // }
        return GestureDetector(
          onTap: () async {
            sharedPreferenceService.setHasExpandedCardValue(
                username: values[index].username);
            setState(() {
              isExpanded = ((tapped == null) ||
                      (('$languageIndex$index' == tapped) || !isExpanded))
                  ? !isExpanded
                  : isExpanded;
              tapped = '$languageIndex$index';
            });
          },
          child: Slidable(
            actionPane: const SlidableStrechActionPane(),
            actionExtentRatio: 0.20,
            secondaryActions: [
              /// favourite
              IconSlideAction(
                caption: 'Favourite',
                icon: Icons.favorite,
                color: Colors.redAccent,
                onTap: () async {
                  /// fetch favRepo list from shared preferences key in decoded form
                  SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  List<String> storedFavRepos = sharedPreferences.getStringList(
                          SharedPreferenceService.FAV_REPO_LIST_KEY) ??
                      [];
                  decodedFavRepos = [];
                  List usernames = [];
                  for (var element in storedFavRepos) {
                    decodedFavRepos.add(json.decode(element));
                  }
                  print('364: $decodedFavRepos');
                  encodedFavRepos = [];
                  if (decodedFavRepos.isNotEmpty) {
                    for (var element in decodedFavRepos) {
                      /// check the username already exists in fav
                      // print("315: ${element['username']}");
                      usernames.add(element['username']);
                      if (usernames.contains(values[index].username)) {
                        print('return');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Repository already exists'),
                          ),
                        );
                        return;
                      }
                      encodedFavRepos.add(jsonEncode(element));
                    }
                  }
                  String encodedFavItem = '';
                  for (var element in values) {
                    if (element.username == values[index].username) {
                      encodedFavItem = jsonEncode(element.toMap());
                      encodedFavRepos.add(encodedFavItem);
                      // favRepos = [];
                    }
                  }
                  print('373 encodedFavRepos: $encodedFavRepos');

                  /// store fav items in shared preferences list in encoded form
                  sharedPreferenceService.setFavRepoListValue(
                      favRepos: encodedFavRepos);
                  // print(expandedCardValue);
                  // for (var favRepoItem in favRepos) {
                  //   favRepoLang.addEntries([
                  //     MapEntry(
                  //       /// key
                  //       favRepoItem.language,
                  //
                  //       /// value
                  //       trendingRepos
                  //           .where((favRepo) =>
                  //               favRepo.language == favRepoItem.language)
                  //           .toList(),
                  //     ),
                  //   ]);
                  // }
                },
              ),
            ],
            child: ExpandableContainer(
              expanded: '$languageIndex$index' == tapped ? isExpanded : false,
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
                          imageUrl: values[index].builtBy[0]['avatar'],
                          fit: BoxFit.cover,
                          height: 50.0,
                          width: 50.0,
                          placeholder: (context, url) => Image.asset(
                            'assets/images/profile_image.png',
                            width: MediaQuery.of(context).size.width * 0.60,
                            fit: BoxFit.contain,
                          ),
                          errorWidget: (context, url, error) => Image.network(
                            'https://www.gemkom.com.tr/wp-content/uploads/2020/02/NO_IMG_600x600-1.png',
                            fit: BoxFit.contain,
                            width: MediaQuery.of(context).size.width * 0.60,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20.0),

                    /// username & repo name
                    SizedBox(
                      width: width - 100.0,
                      // screenWidth - profileAvatarWidth - padding (approx.)
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// username
                          Text(
                            !isStringInvalid(text: values[index].username)
                                ? values[index].username
                                : 'N/A',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),

                          /// repo name
                          Text(
                            values[index].repositoryName,
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
                        imageUrl: values[index].builtBy[0]['avatar'],
                        fit: BoxFit.cover,
                        height: 50.0,
                        width: 50.0,
                        placeholder: (context, url) => Image.asset(
                          'assets/images/profile_image.png',
                          width: MediaQuery.of(context).size.width * 0.60,
                          fit: BoxFit.contain,
                        ),
                        errorWidget: (context, url, error) => Image.network(
                          'https://www.gemkom.com.tr/wp-content/uploads/2020/02/NO_IMG_600x600-1.png',
                          fit: BoxFit.contain,
                          width: MediaQuery.of(context).size.width * 0.60,
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
                        children: [
                          /// username
                          Text(
                            !isStringInvalid(text: values[index].username)
                                ? values[index].username
                                : 'N/A',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 10.0),

                          /// repo name
                          Text(
                            !isStringInvalid(text: values[index].repositoryName)
                                ? values[index].repositoryName
                                : '',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                            ),
                          ),
                          const SizedBox(height: 10.0),

                          /// description
                          !isStringInvalid(text: values[index].description)
                              ? Text(
                                  values[index].description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.black,
                                  ),
                                )
                              : Container(),
                          const SizedBox(height: 10.0),

                          /// language,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// language
                              !isStringInvalid(
                                      text: values[index].languageColor)
                                  ? Row(
                                      children: [
                                        /// language color
                                        CircleAvatar(
                                          radius: 5.0,
                                          backgroundColor:
                                              colors[languageIndex],
                                        ),
                                        const SizedBox(width: 4.0),

                                        /// language
                                        Text(
                                          values[index].language,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    )
                                  : Container(),

                              /// popularity
                              !isStringInvalid(
                                      text: values[index].totalStars.toString())
                                  ? Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 4.0),
                                        Text(
                                          '${values[index].totalStars}',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    )
                                  : Container(),

                              /// forks
                              !isStringInvalid(
                                      text: values[index].forks.toString())
                                  ? Row(
                                      children: [
                                        const Icon(
                                          Octicons.repo_forked,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(width: 4.0),
                                        Text(
                                          values[index].forks.toString(),
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
          ),
        );
      },
    );
  }
}
