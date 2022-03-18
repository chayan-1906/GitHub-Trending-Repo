import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global_functions/check_invalid_string.dart';
import '../services/shared_preference_service.dart';

class FavRepoScreen extends StatefulWidget {
  const FavRepoScreen({Key key}) : super(key: key);

  @override
  _FavRepoScreenState createState() => _FavRepoScreenState();
}

class _FavRepoScreenState extends State<FavRepoScreen> {
  List decodedFavRepos = [];

  Future<void> fetchFavRepos() async {
    /// fetch favRepo list from shared preferences key in decoded form
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> storedFavRepos = sharedPreferences
            .getStringList(SharedPreferenceService.FAV_REPO_LIST_KEY) ??
        [];
    // SharedPreferenceService sharedPreferenceService = SharedPreferenceService();
    // sharedPreferenceService.setFavRepoListValue(favRepos: <String>[]);
    for (var element in storedFavRepos) {
      setState(() {
        decodedFavRepos.add(json.decode(element));
      });
    }
    print('30. decodedFavRepos: $decodedFavRepos');
    print('31. decodedFavReposLength: ${decodedFavRepos.length}');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchFavRepos();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Favourites'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_rounded),
        ),
      ),
      body: decodedFavRepos.isEmpty
          ? const Center(
              child: Text(
                'No Favorites Repository added yet',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ListView.separated(
              itemCount: decodedFavRepos.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  margin: const EdgeInsets.all(20.0),
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: Row(
                    children: [
                      /// profile avatar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                        child: CachedNetworkImage(
                          // TODO: Whose avatar url???
                          imageUrl: decodedFavRepos[index]['builtBy'][0]
                              ['avatar'],
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
                        width: width * 0.68,
                        // color: Colors.orange,
                        child: ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            /// username
                            Text(
                              !isStringInvalid(
                                      text: decodedFavRepos[index]['username'])
                                  ? decodedFavRepos[index]['username']
                                  : 'N/A',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 10.0),

                            /// repo name
                            Text(
                              !isStringInvalid(
                                      text: decodedFavRepos[index]
                                          ['repositoryName'])
                                  ? decodedFavRepos[index]['repositoryName']
                                  : '',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                              ),
                            ),
                            const SizedBox(height: 10.0),

                            /// description
                            !isStringInvalid(
                                    text: decodedFavRepos[index]['description'])
                                ? Text(
                                    decodedFavRepos[index]['description'],
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
                                        text: decodedFavRepos[index]
                                            ['languageColor'])
                                    ? Row(
                                        children: [
                                          /// language color
                                          // CircleAvatar(
                                          //   radius: 5.0,
                                          //   backgroundColor: colors[languageIndex],
                                          // ),
                                          // const SizedBox(width: 4.0),

                                          /// language
                                          Text(
                                            decodedFavRepos[index]['language'],
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ],
                                      )
                                    : Container(),

                                /// popularity
                                !isStringInvalid(
                                        text: decodedFavRepos[index]
                                                ['totalStars']
                                            .toString())
                                    ? Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 4.0),
                                          Text(
                                            '${decodedFavRepos[index]['totalStars']}',
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ],
                                      )
                                    : Container(),

                                /// forks
                                !isStringInvalid(
                                        text: decodedFavRepos[index]['forks']
                                            .toString())
                                    ? Row(
                                        children: [
                                          const Icon(
                                            Octicons.repo_forked,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(width: 4.0),
                                          Text(
                                            decodedFavRepos[index]['forks']
                                                .toString(),
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
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  color: Colors.grey,
                  height: 2.0,
                  indent: 20.0,
                  endIndent: 20.0,
                );
              },
            ),
    );
  }
}
