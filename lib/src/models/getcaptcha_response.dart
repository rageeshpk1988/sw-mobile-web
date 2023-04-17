// To parse this JSON data, do
//
//     final kycApprove = kycApproveFromJson(jsonString);

import 'dart:convert';

GetCaptcha kycApproveFromJson(String str) => GetCaptcha.fromJson(json.decode(str));

String kycApproveToJson(GetCaptcha data) => json.encode(data.toJson());

class GetCaptcha {
  GetCaptcha({
     this.responseData,
     this.responseStatus,
  });

  ResponseData? responseData;
  ResponseStatus? responseStatus;

  factory GetCaptcha.fromJson(Map<String, dynamic> json) => GetCaptcha(
    responseData: parseResponseData(json["response_data"]),
    responseStatus:  parseResponseStatus(json["response_status"]),
  );

  //Parse the inner json by calling the parent class of the object
  static ResponseData? parseResponseData(json) {
    if (json == null) return null;
    ResponseData response = ResponseData.fromJson(json);
    return response;
  }
  static ResponseStatus? parseResponseStatus(json) {
    if (json == null) return null;
    ResponseStatus response = ResponseStatus.fromJson(json);
    return response;
  }

  Map<String, dynamic> toJson() => {
    "response_data": encodeResponseData(responseData),
    "response_status": encodeResponseStatus(responseStatus),
  };
  static Map<String, dynamic> encodeResponseData(responseData) {
    Map<String, dynamic> response = responseData.toJson();
    return response;
  }
  static Map<String, dynamic> encodeResponseStatus(responseStatus) {
    Map<String, dynamic> response = responseStatus.toJson();
    return response;
  }
}


class ResponseData {
  ResponseData({
    required this.captcha,
    required this.uuid,
  });

  var captcha;
  var uuid;

  factory ResponseData.fromJson(Map<String, dynamic> json) => ResponseData(
    captcha: json["captcha"],
    uuid: json["uuid"],
  );

  Map<String, dynamic> toJson() => {
    "captcha": captcha,
    "uuid": uuid,
  };
}

class ResponseStatus {
  ResponseStatus({
    required this.code,
    required this.message,
    required this.status,
  });

  var code;
  var message;
  var status;

  factory ResponseStatus.fromJson(Map<String, dynamic> json) => ResponseStatus(
    code: json["code"],
    message: json["message"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "status": status,
  };
}
