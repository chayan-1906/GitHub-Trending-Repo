import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  static const EXPANDED_CARD_VALUE = 'EXPANDED_CARD_VALUE';
  static const String TRENDING_REPO_LIST_KEY = 'TRENDING_REPO_LIST_KEY';
  static const String FAV_REPO_LIST_KEY = 'FAV_REPO_LIST_KEY';

  // static const Map<String, List<dynamic>> TRENDING_REPO_MAP = {};
  // static const List<dynamic> TRENDING_REPO_LIST = [];

  setHasExpandedCardValue({String username}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(EXPANDED_CARD_VALUE, username);
    print(sharedPreferences.getString(EXPANDED_CARD_VALUE));
  }

  Future<String> getHasExpandedCardValue() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(EXPANDED_CARD_VALUE) ?? 'null';
  }

  setTrendingRepoListValue({List fetchedRepos}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setStringList(TRENDING_REPO_LIST_KEY, fetchedRepos);
    // print(sharedPreferences.getStringList(TRENDING_REPO_LIST_KEY));
  }

  Future<List<dynamic>> getTrendingRepoListValue() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getStringList(TRENDING_REPO_LIST_KEY) ?? [];
  }

  setFavRepoListValue({List favRepos}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setStringList(FAV_REPO_LIST_KEY, favRepos);
    // print(sharedPreferences.getStringList(TRENDING_REPO_LIST_KEY));
  }

  Future<List<dynamic>> getFavRepoListValue() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getStringList(FAV_REPO_LIST_KEY) ?? [];
  }
}
