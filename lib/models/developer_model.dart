class DeveloperModel {
  String username;
  String githubUrl;
  String avatarUrl;

  DeveloperModel({
    this.username,
    this.githubUrl,
    this.avatarUrl,
  });

  DeveloperModel.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    githubUrl = json['url'];
    avatarUrl = json['avatar'];
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'url': githubUrl,
      'avatar': avatarUrl,
    };
  }
}
