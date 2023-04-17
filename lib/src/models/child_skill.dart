import 'package:flutter/material.dart';

class ChildSkill with ChangeNotifier {
  final int parentId;
  final int studentId;
  final int ageGroupId;
  final List<ChildSkillAssessment>? assessments;
  ChildSkill({
    required this.parentId,
    required this.studentId,
    required this.ageGroupId,
    this.assessments,
  });

  factory ChildSkill.fromJson(Map<String, dynamic> json) {
    return ChildSkill(
      parentId: json['parentId'],
      studentId: json['studentId'],
      ageGroupId: json['ageGroupId'],
      assessments: parseChildSkillAssessments(json['assessments']),
    );
  }
  static List<ChildSkillAssessment> parseChildSkillAssessments(json) {
    final List<ChildSkillAssessment> assessments = [];
    for (Map<String, dynamic> dt in json) {
      ChildSkillAssessment assessment = ChildSkillAssessment.fromJson(dt);
      assessments.add(assessment);
    }
    return assessments;
  }
}

class ChildSkillAssessment with ChangeNotifier {
  final int assessmentId;
  final String assessmentName;
  final List<ChildSkillProgram>? programs;

  ChildSkillAssessment({
    required this.assessmentId,
    required this.assessmentName,
    this.programs,
  });

  factory ChildSkillAssessment.fromJson(Map<String, dynamic> json) {
    return ChildSkillAssessment(
      assessmentId: json['assessmentId'],
      assessmentName: json['assessmentName'],
      programs: parseChildPrograms(json['programs']),
    );
  }

  static List<ChildSkillProgram> parseChildPrograms(json) {
    final List<ChildSkillProgram> programs = [];
    for (Map<String, dynamic> dt in json) {
      ChildSkillProgram program = ChildSkillProgram.fromJson(dt);
      programs.add(program);
    }
    return programs;
  }
}

class ChildSkillProgram with ChangeNotifier {
  final int programId;
  final String programName;
  final String? productHandle;
  final String? recommendedDate;
  final String? programImage;
  final String? purchasedOn;
  final String? productType;
  final List<ProductReview>? reviews;

  ChildSkillProgram({
    required this.programId,
    required this.programName,
    this.productHandle,
    this.recommendedDate,
    this.programImage,
    this.purchasedOn,
    this.productType,
    this.reviews,
  });

  factory ChildSkillProgram.fromJson(Map<String, dynamic> json) {
    return ChildSkillProgram(
      programId: json['programId'],
      programName: json['programName'],
      productHandle: json['productHandle'],
      recommendedDate: json['recommendedDate'],
      programImage: json['programImage'],
      purchasedOn: json['purchasedOn'],
      productType: json['productType'],
      reviews: parseProgramReviews(json['reviews']),
    );
  }
  static List<ProductReview> parseProgramReviews(json) {
    final List<ProductReview> reviews = [];
    for (Map<String, dynamic> dt in json) {
      ProductReview review = ProductReview.fromJson(dt);
      reviews.add(review);
    }
    return reviews;
  }
}

class ProductReview with ChangeNotifier {
  final String comment;
  var rating;
  int? productId;
  String? productName;
  String? programType;

  ProductReview({
    required this.comment,
    required this.rating,
    this.productId,
    this.productName,
    this.programType,
  });
  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      comment: json['comment'],
      rating: json['rating'],
    );
  }
}
