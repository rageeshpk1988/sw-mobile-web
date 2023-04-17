// To parse this JSON data, do
//
//     final getQuestionReq = getQuestionReqFromJson(jsonString);

import 'dart:convert';

GetQuestionReq getQuestionReqFromJson(String str) => GetQuestionReq.fromJson(json.decode(str));

String getQuestionReqToJson(GetQuestionReq data) => json.encode(data.toJson());

class GetQuestionReq {
  GetQuestionReq({
    required this.age,
    required this.studentId,
    required this.hierarchyId,
    required this.currentLeafId,
    required this.countryCode,
    required this.hierarchyCount,
    required this.childName,
    required this.assessmentName
  });

  String age;
  String studentId;
  String hierarchyId;
  String currentLeafId;
  String countryCode;
  String hierarchyCount;
  String childName;
  String assessmentName;
  factory GetQuestionReq.fromJson(Map<String, dynamic> json) => GetQuestionReq(
    age: json["age"],
    studentId: json["studentId"],
    hierarchyId: json["hierarchyId"],
    currentLeafId: json["currentLeafId"],
    countryCode: json["countryCode"],
    hierarchyCount: json["hierarchyCount"],
    childName: '',
    assessmentName: '',
  );

  Map<String, dynamic> toJson() => {
    "age": age,
    "studentId": studentId,
    "hierarchyId": hierarchyId,
    "currentLeafId": currentLeafId,
    "countryCode": countryCode,
    "hierarchyCount": hierarchyCount,
  };
}
