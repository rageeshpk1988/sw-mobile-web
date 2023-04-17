class AchievementCategory {
  var achievementCategoryId;
  final String achievementCategory;

  AchievementCategory({
    required this.achievementCategoryId,
    required this.achievementCategory,
  });

  factory AchievementCategory.fromJson(Map<String, dynamic> json) {
    return AchievementCategory(
      achievementCategoryId: json['achievementCategoryId'],
      achievementCategory: json['achievementCategory'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'achievementCategoryId': achievementCategoryId,
      'achievementCategory': achievementCategory,
    };
  }

  // static List<AchievementCategory> fromJsonList(List list) {
  //   return list.map((item) => AchievementCategory.fromJson(item)).toList();
  // }
}
