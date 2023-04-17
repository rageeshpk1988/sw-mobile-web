import 'package:flutter/material.dart';

class ChildSkillSummaryGroup with ChangeNotifier {
  var latestVersion;
  var latestIOSVersion;
  final String updateIOSStatus;
  final double completePercentage;
  final int basicCount;
  final int advanceCount;
  final String status;
  final List<ChildSkillCategory>? categoryList;

  ChildSkillSummaryGroup({
    required this.latestVersion,
    required this.latestIOSVersion,
    required this.updateIOSStatus,
    required this.completePercentage,
    required this.basicCount,
    required this.advanceCount,
    required this.status,
    this.categoryList,
  });

  factory ChildSkillSummaryGroup.fromJson(Map<String, dynamic> json) {
    return ChildSkillSummaryGroup(
      latestVersion: json['latestVersion'],
      latestIOSVersion: json['latestIOSVersion'],
      updateIOSStatus: json['updateIOSStatus'],
      completePercentage: json['completePercentage'],
      basicCount: json['basicCount'],
      advanceCount: json['advanceCount'],
      status: json['status'],
      categoryList: parseChildSkillCategories(json['categoryList']),
    );
  }
  static List<ChildSkillCategory> parseChildSkillCategories(json) {
    final List<ChildSkillCategory> categories = [];
    for (Map<String, dynamic> dt in json) {
      ChildSkillCategory category = ChildSkillCategory.fromJson(dt);
      categories.add(category);
    }
    return categories;
  }
}

class ChildSkillCategory {
  final int catID;
  final String catName;
  final double percentage;
  final double weightage;
  final double price;
  final double score;
  final double maxScore;
  final String payment;
  final String skill;
  final bool active;
  final List<ChildSkillSubCategory>? subCategoryList;
  ChildSkillCategory({
    required this.catID,
    required this.catName,
    required this.percentage,
    required this.weightage,
    required this.price,
    required this.score,
    required this.maxScore,
    required this.payment,
    required this.skill,
    this.subCategoryList,
    required this.active,
  });
  factory ChildSkillCategory.fromJson(Map<String, dynamic> json) {
    return ChildSkillCategory(
      catID: json['catID'],
      catName: json['catName'],
      percentage: json['percentage'],
      weightage: json['weightage'],
      price: json['price'],
      score: json['score'],
      maxScore: json['maxScore'],
      payment: json['payment'],
      skill: json['skill'],
      subCategoryList: parseChildSkillSubCategories(json['subCategoryList']),
      active: json['active'],
    );
  }
  static List<ChildSkillSubCategory> parseChildSkillSubCategories(json) {
    final List<ChildSkillSubCategory> categories = [];
    for (Map<String, dynamic> dt in json) {
      ChildSkillSubCategory category = ChildSkillSubCategory.fromJson(dt);
      categories.add(category);
    }
    return categories;
  }
}

class ChildSkillSubCategory {
  final int catID;
  final String catName;
  final double percentage;
  final double weightage;
  final double price;
  final double score;
  final double maxScore;
  final String payment;
  final String skill;
  final bool active;
  final List<ChildSkillSubCategory>? subCategoryList;
  ChildSkillSubCategory({
    required this.catID,
    required this.catName,
    required this.percentage,
    required this.weightage,
    required this.price,
    required this.score,
    required this.maxScore,
    required this.payment,
    required this.skill,
    required this.active,
    this.subCategoryList,
  });
  factory ChildSkillSubCategory.fromJson(Map<String, dynamic> json) {
    return ChildSkillSubCategory(
      catID: json['catID'],
      catName: json['catName'],
      percentage: json['percentage'],
      weightage: json['weightage'],
      price: json['price'],
      score: json['score'],
      maxScore: json['maxScore'],
      payment: json['payment'],
      skill: json['skill'],
      active: json['active'],
      subCategoryList: parseChildSkillSubCategories(json['subCategoryList']),
    );
  }
  static List<ChildSkillSubCategory> parseChildSkillSubCategories(json) {
    final List<ChildSkillSubCategory> categories = [];
    for (Map<String, dynamic> dt in json) {
      ChildSkillSubCategory category = ChildSkillSubCategory.fromJson(dt);
      categories.add(category);
    }
    return categories;
  }
}

class ChildSkillReport {
  var completedOn;
  final List<ChildReportInterpretation>? interpretationList;
  final List<ChildReportRecommendation>? recommendationList;
  final List<ChildReportProgram>? programs;
  var timeTaken;
  ChildSkillReport({
    this.completedOn,
    this.interpretationList,
    this.programs,
    this.recommendationList,
    this.timeTaken,
  });
  factory ChildSkillReport.fromJson(Map<String, dynamic> json) {
    return ChildSkillReport(
      completedOn: json['completedOn'],
      interpretationList:
          parseChildReportInterpretations(json['interpretationList']),
      recommendationList:
          parseChildReportRecommendations(json['recommendationList']),
      timeTaken: json['timeTaken'],
      programs: parseChildReportPrograms(json['programs']),
    );
  }
  static List<ChildReportInterpretation> parseChildReportInterpretations(json) {
    final List<ChildReportInterpretation> interpretations = [];
    for (Map<String, dynamic> dt in json) {
      ChildReportInterpretation interpretation =
          ChildReportInterpretation.fromJson(dt);
      interpretations.add(interpretation);
    }
    return interpretations;
  }

  static List<ChildReportRecommendation> parseChildReportRecommendations(json) {
    final List<ChildReportRecommendation> recommendations = [];
    for (Map<String, dynamic> dt in json) {
      ChildReportRecommendation recommendation =
          ChildReportRecommendation.fromJson(dt);
      recommendations.add(recommendation);
    }
    return recommendations;
  }

  static List<ChildReportProgram> parseChildReportPrograms(json) {
    final List<ChildReportProgram> programs = [];
    for (Map<String, dynamic> dt in json) {
      ChildReportProgram program = ChildReportProgram.fromJson(dt);
      programs.add(program);
    }
    return programs;
  }
}

class ChildReportInterpretation {
  int? rowID;
  String? interpretation;

  ChildReportInterpretation({
    this.rowID,
    this.interpretation,
  });
  factory ChildReportInterpretation.fromJson(Map<String, dynamic> json) {
    return ChildReportInterpretation(
      rowID: json['rowID'],
      interpretation: json['interpretation'],
    );
  }
}

class ChildReportRecommendation {
  int? rowID;
  String? recommendation;

  ChildReportRecommendation({
    this.rowID,
    this.recommendation,
  });
  factory ChildReportRecommendation.fromJson(Map<String, dynamic> json) {
    return ChildReportRecommendation(
      rowID: json['rowID'],
      recommendation: json['recommendation'],
    );
  }
}

class ChildReportProgram {
  final String? productType;
  var programId;
  final String? programImage;
  final String? programName;
  var purchasedOn;
  var recommendedDate;
  List<ChildReportReview>? reviews;
  final List<ChildReportCredential>? credentials;
  ChildReportProgram({
    this.productType,
    this.programId,
    this.programImage,
    this.programName,
    this.purchasedOn,
    this.recommendedDate,
    this.reviews,
    this.credentials,
  });
  factory ChildReportProgram.fromJson(Map<String, dynamic> json) {
    return ChildReportProgram(
      productType: json['productType'],
      programId: json['programId'],
      programImage: json['programImage'],
      programName: json['programName'],
      purchasedOn: json['purchasedOn'],
      recommendedDate: json['recommendedDate'],
      reviews: parseChildReportReviews(json['reviews']),
      credentials: parseChildReportCredentials(json['credentials']),
    );
  }
  static List<ChildReportCredential> parseChildReportCredentials(json) {
    final List<ChildReportCredential> credentials = [];
    for (Map<String, dynamic> dt in json) {
      ChildReportCredential credential = ChildReportCredential.fromJson(dt);
      credentials.add(credential);
    }
    return credentials;
  }

  static List<ChildReportReview> parseChildReportReviews(json) {
    final List<ChildReportReview> reviews = [];
    for (Map<String, dynamic> dt in json) {
      ChildReportReview review = ChildReportReview.fromJson(dt);
      reviews.add(review);
    }
    return reviews;
  }
}

class ChildReportCredential {
  var credentialsKey;
  var credentialsValue;

  ChildReportCredential({
    this.credentialsKey,
    this.credentialsValue,
  });
  factory ChildReportCredential.fromJson(Map<String, dynamic> json) {
    return ChildReportCredential(
      credentialsKey: json['credentialsKey'],
      credentialsValue: json['credentialsValue'],
    );
  }
}

class ChildReportReview {
  String? comment;
  double? rating;
  ChildReportReview({
    this.comment,
    this.rating,
  });
  factory ChildReportReview.fromJson(Map<String, dynamic> json) {
    return ChildReportReview(
      comment: json['comment'],
      rating: json['rating'],
    );
  }
}
