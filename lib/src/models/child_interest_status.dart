//OBSOLETE
// To parse this JSON data, do
//
//     final interestStatus = interestStatusFromJson(jsonString);

import 'dart:convert';

InterestStatus interestStatusFromJson(String str) =>
    InterestStatus.fromJson(json.decode(str));

String interestStatusToJson(InterestStatus data) => json.encode(data.toJson());

class InterestStatus {
  InterestStatus({
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

  factory InterestStatus.fromJson(Map<String, dynamic> json) => InterestStatus(
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
    this.attendedCount,
    this.totalCount,
    this.submittedAny,
  });

  int? attendedCount;
  int? totalCount;
  bool? submittedAny;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        attendedCount:
            json["attendedCount"] == null ? null : json["attendedCount"],
        totalCount: json["totalCount"] == null ? null : json["totalCount"],
        submittedAny:
            json["submittedAny"] == null ? null : json["submittedAny"],
      );

  Map<String, dynamic> toJson() => {
        "attendedCount": attendedCount == null ? null : attendedCount,
        "totalCount": totalCount == null ? null : totalCount,
        "submittedAny": submittedAny == null ? null : submittedAny,
      };
}
