// To parse this JSON data, do
//
//     final getQuestionResponse = getQuestionResponseFromJson(jsonString);

import 'dart:convert';

GetQuestionResponse getQuestionResponseFromJson(String str) => GetQuestionResponse.fromJson(json.decode(str));

String getQuestionResponseToJson(GetQuestionResponse data) => json.encode(data.toJson());

class GetQuestionResponse {
  GetQuestionResponse({
    required this.status,
    required this.questionId,
    this.question,
    this.choice,
    this.questionType,
    this.fileUrl,
    this.optionType,
    required this.modeId,
    required this.description,
    this.optionList,
    required this.questionCompletionStatus,
    required this.currentLeafId,
    required this.qnTimerStatus,
    required this.qnTimerValue,
    required this.attachTimerStatus,
    required this.attachTimerValue,
    this.voiceFileUrl,
    required this.viewagainStatus,
    required this.negativeMark,
    this.instructions,
  });

  String status;
  int questionId;
  dynamic question;
  dynamic choice;
  dynamic questionType;
  dynamic fileUrl;
  dynamic optionType;
  int modeId;
  String description;
  dynamic optionList;
  String questionCompletionStatus;
  int currentLeafId;
  bool qnTimerStatus;
  int qnTimerValue;
  bool attachTimerStatus;
  int attachTimerValue;
  dynamic voiceFileUrl;
  bool viewagainStatus;
  int negativeMark;
  dynamic instructions;

  factory GetQuestionResponse.fromJson(Map<String, dynamic> json) => GetQuestionResponse(
    status: json["status"],
    questionId: json["questionId"],
    question: json["question"],
    choice: json["choice"],
    questionType: json["questionType"],
    fileUrl: json["fileUrl"],
    optionType: json["optionType"],
    modeId: json["modeID"],
    description: json["description"],
    optionList: json["optionList"],
    questionCompletionStatus: json["questionCompletionStatus"],
    currentLeafId: json["currentLeafId"],
    qnTimerStatus: json["qnTimerStatus"],
    qnTimerValue: json["qnTimerValue"],
    attachTimerStatus: json["attachTimerStatus"],
    attachTimerValue: json["attachTimerValue"],
    voiceFileUrl: json["voiceFileUrl"],
    viewagainStatus: json["viewagainStatus"],
    negativeMark: json["negativeMark"],
    instructions: json["instructions"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "questionId": questionId,
    "question": question,
    "choice": choice,
    "questionType": questionType,
    "fileUrl": fileUrl,
    "optionType": optionType,
    "modeID": modeId,
    "description": description,
    "optionList": optionList,
    "questionCompletionStatus": questionCompletionStatus,
    "currentLeafId": currentLeafId,
    "qnTimerStatus": qnTimerStatus,
    "qnTimerValue": qnTimerValue,
    "attachTimerStatus": attachTimerStatus,
    "attachTimerValue": attachTimerValue,
    "voiceFileUrl": voiceFileUrl,
    "viewagainStatus": viewagainStatus,
    "negativeMark": negativeMark,
    "instructions": instructions,
  };
}
