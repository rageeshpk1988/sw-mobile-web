import 'package:flutter/material.dart';

class TCMeeting {
  final String date;
  final String message;
  final String time;
  final List<TCQuestionAnswerList> questionAnswerList;
  //final List<TCQuestion> questionAnswerList;
  TCMeeting({
    required this.date,
    required this.message,
    required this.time,
    required this.questionAnswerList,
  });
  factory TCMeeting.fromJson(Map<String, dynamic> json) {
    return TCMeeting(
      date: json['date'],
      message: json['message'],
      time: json['time'],
      questionAnswerList: parseQuestionAnswerList(json['questionAnswerList']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'message': message,
      'time': time,
    };
  }

  // static List<TCQuestion> parseQuestionAnswerList(json) {
  //   final List<TCQuestion> qaList = [];
  //   for (Map<String, dynamic> dt in json) {
  //     TCQuestion qa = TCQuestion.fromJson(dt);
  //     qaList.add(qa);
  //   }
  //   return qaList;
  // }
  static List<TCQuestionAnswerList> parseQuestionAnswerList(json) {
    final List<TCQuestionAnswerList> qaList = [];
    for (Map<String, dynamic> dt in json) {
      TCQuestionAnswerList qa = TCQuestionAnswerList.fromJson(dt);
      qaList.add(qa);
    }
    return qaList;
  }
}

class TCQuestionAnswerList {
  final int question;
  final bool answer;
  TCQuestionAnswerList({
    required this.question,
    required this.answer,
  });
  factory TCQuestionAnswerList.fromJson(Map<String, dynamic> json) {
    return TCQuestionAnswerList(
      question: json['question'],
      answer: json['answer'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
    };
  }
}

class TCQuestion {
  int? questionId;
  String? question;
  bool? isChecked;

  TCQuestion({
    this.questionId,
    this.question,
    this.isChecked,
  });
  factory TCQuestion.fromJson(Map<String, dynamic> json) {
    return TCQuestion(
      questionId: json['questionId'],
      question: json['question'],
      isChecked: json['isChecked'],
    );
  }
  List<TCQuestion> getQuestions() {
    return <TCQuestion>[
      TCQuestion(
          questionId: 1,
          question: 'Know more about the interpretation of the assessment',
          isChecked: false),
      TCQuestion(
          questionId: 2,
          question: 'Guidance before taking next assessment',
          isChecked: false),
      TCQuestion(
          questionId: 3,
          question:
              'Know how to incorporate this knowledge in academics and planning learning methodology',
          isChecked: false),
      TCQuestion(
          questionId: 4,
          question:
              'Any developmental milestones and concerns that need to be addressed and requires a psonalized sessions',
          isChecked: false),
      TCQuestion(
          questionId: 5,
          question:
              'Know more about our personalized skill enhancements programs/products',
          isChecked: false),
      //TCQuestion(questionId: 6, question: 'Others'),
    ];
  }
}

List<DropdownMenuItem<String>> get tcTimings {
  List<DropdownMenuItem<String>> items = [
    DropdownMenuItem(
        child: const Text("9:00 AM to 9:30 AM"), value: "9:00 AM to 9:30 AM"),
    DropdownMenuItem(
        child: const Text("9:30 AM to 10:00 AM"), value: "9:30 AM to 10:00 AM"),
    DropdownMenuItem(
        child: const Text("10:00 AM to 10:30 AM"),
        value: "10:00 AM to 10:30 AM"),
    DropdownMenuItem(
        child: const Text("10:30 AM to 11:00 AM"),
        value: "10:30 AM to 11:00 AM"),
    DropdownMenuItem(
        child: const Text("11:00 AM to 11:30 AM"),
        value: "11:00 AM to 11:30 AM"),
    DropdownMenuItem(
        child: const Text("11:30 AM to 12:00 AM"),
        value: "11:30 AM to 12:00 AM"),
    DropdownMenuItem(
        child: const Text("12:00 AM to 12:30 PM"),
        value: "12:00 AM to 12:30 PM"),
    DropdownMenuItem(
        child: const Text("12:30 PM to 01:00 PM"),
        value: "12:30 PM to 01:00 PM"),
    DropdownMenuItem(
        child: const Text("02:00 PM to 02:30 PM"),
        value: "02:00 PM to 02:30 PM"),
    DropdownMenuItem(
        child: const Text("02:30 PM to 03:00 PM"),
        value: "02:30 PM to 03:00 PM"),
    DropdownMenuItem(
        child: const Text("03:00 PM to 03:30 PM"),
        value: "03:00 PM to 03:30 PM"),
    DropdownMenuItem(
        child: const Text("03:30 PM to 04:00 PM"),
        value: "03:30 PM to 04:00 PM"),
    DropdownMenuItem(
        child: const Text("04:00 PM to 04:30 PM"),
        value: "04:00 PM to 04:30 PM"),
    DropdownMenuItem(
        child: const Text("04:30 PM to 05:00 PM"),
        value: "04:30 PM to 05:00 PM"),
    DropdownMenuItem(
        child: const Text("05:00 PM to 05:30 PM"),
        value: "05:00 PM to 05:30 PM"),
    DropdownMenuItem(
        child: const Text("05:30 PM to 06:00 PM"),
        value: "05:30 PM to 06:00 PM"),
  ];
  return items;
}
