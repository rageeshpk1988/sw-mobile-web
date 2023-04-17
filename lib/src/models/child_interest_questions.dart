//OBSOLETE
// To parse this JSON data, do
//
//     final interestQuestions = interestQuestionsFromJson(jsonString);

import 'dart:convert';

InterestQuestions interestQuestionsFromJson(String str) =>
    InterestQuestions.fromJson(json.decode(str));

String interestQuestionsToJson(InterestQuestions data) =>
    json.encode(data.toJson());

class InterestQuestions {
  InterestQuestions({
    this.status,
    this.version,
    this.message,
    this.data,
    this.error,
  });

  int? status;
  String? version;
  String? message;
  Data? data;
  dynamic error;

  factory InterestQuestions.fromJson(Map<String, dynamic> json) =>
      InterestQuestions(
        status: json["status"] == null ? null : json["status"],
        version: json["version"] == null ? null : json["version"],
        message: json["message"] == null ? null : json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "version": version == null ? null : version,
        "message": message == null ? null : message,
        "data": data == null ? null : data!.toJson(),
        "error": error,
      };
}

class Data {
  Data({
    this.parentId,
    this.studentId,
    this.questionAnswers,
    this.moreRecords,
    this.choices,
  });

  int? parentId;
  int? studentId;
  List<QuestionAnswer>? questionAnswers;
  bool? moreRecords;
  List<Choice>? choices;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        parentId: json["parentId"] == null ? null : json["parentId"],
        studentId: json["studentId"] == null ? null : json["studentId"],
        questionAnswers: json["questionAnswers"] == null
            ? null
            : List<QuestionAnswer>.from(
                json["questionAnswers"].map((x) => QuestionAnswer.fromJson(x))),
        moreRecords: json["moreRecords"] == null ? null : json["moreRecords"],
        choices: json["choices"] == null
            ? null
            : List<Choice>.from(json["choices"].map((x) => Choice.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "parentId": parentId == null ? null : parentId,
        "studentId": studentId == null ? null : studentId,
        "questionAnswers": questionAnswers == null
            ? null
            : List<dynamic>.from(questionAnswers!.map((x) => x.toJson())),
        "moreRecords": moreRecords == null ? null : moreRecords,
        "choices": choices == null
            ? null
            : List<dynamic>.from(choices!.map((x) => x.toJson())),
      };
}

class Choice {
  Choice({
    this.choiceId,
    this.choice,
  });

  int? choiceId;
  String? choice;

  factory Choice.fromJson(Map<String, dynamic> json) => Choice(
        choiceId: json["choiceId"] == null ? null : json["choiceId"],
        choice: json["choice"] == null ? null : json["choice"],
      );

  Map<String, dynamic> toJson() => {
        "choiceId": choiceId == null ? null : choiceId,
        "choice": choice == null ? null : choice,
      };
}

class QuestionAnswer {
  QuestionAnswer({
    this.questionNo,
    this.questionId,
    this.answerId,
    this.question,
    this.answer,
  });

  int? questionNo;
  int? questionId;
  int? answerId;
  String? question;
  String? answer;

  factory QuestionAnswer.fromJson(Map<String, dynamic> json) => QuestionAnswer(
        questionNo: json["questionNo"] == null ? null : json["questionNo"],
        questionId: json["questionId"] == null ? null : json["questionId"],
        answerId: json["answerId"] == null ? null : json["answerId"],
        question: json["question"] == null ? null : json["question"],
        answer: json["answer"] == null ? null : json["answer"],
      );

  Map<String, dynamic> toJson() => {
        "questionNo": questionNo == null ? null : questionNo,
        "questionId": questionId == null ? null : questionId,
        "answerId": answerId == null ? null : answerId,
        "question": question == null ? null : question,
        "answer": answer == null ? null : answer,
      };
}
