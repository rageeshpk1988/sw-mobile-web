import 'package:flutter/material.dart';

class InterestQA with ChangeNotifier {
  final int? parentId;
  final int? studentId;
  final List<QuestionAnswer>? questionAnswers;
  final List<Choice>? choices;
  final bool moreRecords;

  InterestQA({
    this.parentId,
    this.studentId,
    this.questionAnswers,
    this.choices,
    required this.moreRecords,
  });

  factory InterestQA.fromJson(Map<String, dynamic> json) {
    return InterestQA(
      parentId: json['parentId'],
      studentId: json['studentId'],
      questionAnswers: parseQuestionAnswers(json['questionAnswers']),
      choices: parseChoices(json['choices']),
      moreRecords: json['moreRecords'],
    );
  }

  static List<QuestionAnswer> parseQuestionAnswers(json) {
    final List<QuestionAnswer> questions = [];
    for (Map<String, dynamic> dt in json) {
      QuestionAnswer question = QuestionAnswer.fromJson(dt);
      questions.add(question);
    }
    return questions;
  }

  static List<Choice> parseChoices(json) {
    final List<Choice> choices = [];
    for (Map<String, dynamic> dt in json) {
      Choice choice = Choice.fromJson(dt);
      choices.add(choice);
    }
    return choices;
  }
}

class QuestionAnswer with ChangeNotifier {
  int questionNo;
  int questionId;
  String? question;
  int? answerId;
  String? answer;
  QuestionAnswer({
    required this.questionNo,
    required this.questionId,
    this.answerId,
    this.question,
    this.answer,
  });
  factory QuestionAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionAnswer(
      questionNo: json['questionNo'],
      questionId: json['questionId'],
      question: json['question'],
      answerId: json['answerId'],
      answer: json['answer'],
    );
  }
}

class Choice {
  int choiceId;
  String? choice;
  Choice({
    required this.choiceId,
    this.choice,
  });
  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      choiceId: json['choiceId'],
      choice: json['choice'],
    );
  }
}

class InterestStatus {
  int attendedCount;
  int totalCount;
  bool submittedAny;
  int numberOfInterestFound;
  int numberOfSkillsAssessed;
  int numberOfProgramsCompleted;
  int totalNumberOfSkills;
  InterestStatus({
    required this.attendedCount,
    required this.totalCount,
    required this.submittedAny,
    required this.numberOfInterestFound,
    required this.numberOfSkillsAssessed,
    required this.numberOfProgramsCompleted,
    required this.totalNumberOfSkills,
  });
  factory InterestStatus.fromJson(Map<String, dynamic> json) {
    return InterestStatus(
      attendedCount: json['attendedCount'],
      totalCount: json['totalCount'],
      submittedAny: json['submittedAny'],
      numberOfInterestFound: json['numberOfInterestFound'] == null
          ? 0
          : json['numberOfInterestFound'],
      numberOfSkillsAssessed: json['numberOfSkillsAssessed'] == null
          ? 0
          : json['numberOfSkillsAssessed'],
      numberOfProgramsCompleted: json['numberOfProgramsCompleted'] == null
          ? 0
          : json['numberOfProgramsCompleted'],
      totalNumberOfSkills:
          json['totalNumberOfSkills'] == null ? 0 : json['totalNumberOfSkills'],
    );
  }
}
