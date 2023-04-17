// To parse this JSON data, do
//
//     final healthCheck = healthCheckFromJson(jsonString);

import 'dart:convert';

HealthCheck healthCheckFromJson(String str) => HealthCheck.fromJson(json.decode(str));

String healthCheckToJson(HealthCheck data) => json.encode(data.toJson());

class HealthCheck {
  HealthCheck({
    required this.code,
    required this.message,
    required this.responseData,
  });

  String code;
  String message;
  ResponseData responseData;

  factory HealthCheck.fromJson(Map<String, dynamic> json) => HealthCheck(
    code: json["code"],
    message: json["message"],
    responseData: ResponseData.fromJson(json["responseData"]),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "responseData": responseData.toJson(),
  };
}

class ResponseData {
  ResponseData({
    required this.successRate,
  });

  double successRate;

  factory ResponseData.fromJson(Map<String, dynamic> json) => ResponseData(
    successRate: json["successRate"],
  );

  Map<String, dynamic> toJson() => {
    "successRate": successRate,
  };
}
