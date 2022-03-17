import 'developer_model.dart';

class GitRepoModel {
  int rank;
  String username;
  String repositoryName;
  String repositoryUrl;
  String description;
  String language;
  String languageColor;
  int totalStars;
  int forks;
  int starsSince;
  String since;
  List<dynamic> builtBy;

  GitRepoModel({
    this.rank,
    this.username,
    this.repositoryName,
    this.repositoryUrl,
    this.description,
    this.language,
    this.languageColor,
    this.totalStars,
    this.forks,
    this.starsSince,
    this.since,
    this.builtBy,
  });

  GitRepoModel.fromJson(Map<String, dynamic> json) {
    rank = json['rank'];
    username = json['username'];
    repositoryName = json['repositoryName'];
    repositoryUrl = json['url'];
    description = json['description'];
    language = json['language'];
    languageColor = json['languageColor'];
    totalStars = json['totalStars'];
    forks = json['forks'];
    starsSince = json['starsSince'];
    since = json['since'];
    // builtBy = json['builtBy'];
    builtBy = [];
    for(var builtByItem in json['builtBy']) {
      var builtByFromJson = DeveloperModel.fromJson(builtByItem);
      builtBy.add(builtByFromJson.toMap());
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'rank': rank,
      'username': username,
      'repositoryName': repositoryName,
      'url': repositoryUrl,
      'description': description,
      'language': language,
      'languageColor': languageColor,
      'totalStars': totalStars,
      'forks': forks,
      'starsSince': starsSince,
      'since': since,
      'builtBy': builtBy,
    };
  }
}
