import 'package:flutter/material.dart';

class ChildRecomendation with ChangeNotifier {
  final int parentId;
  final int studentId;
  final int ageGroupId;
  final List<ChildSuggestion>? suggestions;
  ChildRecomendation({
    required this.parentId,
    required this.studentId,
    required this.ageGroupId,
    this.suggestions,
  });

  factory ChildRecomendation.fromJson(Map<String, dynamic> json) {
    return ChildRecomendation(
      parentId: json['parentId'],
      studentId: json['studentId'],
      ageGroupId: json['ageGroupId'],
      suggestions: parseChildSuggestions(json['suggestions']),
    );
  }
  static List<ChildSuggestion> parseChildSuggestions(json) {
    final List<ChildSuggestion> suggestions = [];
    for (Map<String, dynamic> dt in json) {
      ChildSuggestion suggestion = ChildSuggestion.fromJson(dt);
      suggestions.add(suggestion);
    }
    return suggestions;
  }
}

class ChildSuggestion with ChangeNotifier {
  final int interestId;
  final String interestName;
  final double score;
  final List<ChildAssessment>? assessments;

  ChildSuggestion({
    required this.interestId,
    required this.interestName,
    required this.score,
    this.assessments,
  });

  factory ChildSuggestion.fromJson(Map<String, dynamic> json) {
    return ChildSuggestion(
      interestId: json['interestId'],
      interestName: json['interestName'],
      // score: json['score'],
      score: json['interestScore'],
      assessments: json['assessments'] == null
          ? null
          : parseChildAssessments(json['assessments']),
    );
  }
  static List<ChildAssessment> parseChildAssessments(json) {
    final List<ChildAssessment> assessments = [];
    for (Map<String, dynamic> dt in json) {
      ChildAssessment assessment = ChildAssessment.fromJson(dt);
      assessments.add(assessment);
    }
    return assessments;
  }
}

class ChildAssessment with ChangeNotifier {
  final int assessmentId;
  final String assessmentName;
  final bool takenStatus;

  ChildAssessment({
    required this.assessmentId,
    required this.assessmentName,
    required this.takenStatus,
  });

  factory ChildAssessment.fromJson(Map<String, dynamic> json) {
    return ChildAssessment(
      assessmentId: json['assessmentId'],
      assessmentName: json['assessmentName'],
      takenStatus: json['takenStatus'] ,
    );
  }
}
