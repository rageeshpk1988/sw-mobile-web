// To parse this JSON data, do
//
//     final fetchOfflineXml = fetchOfflineXmlFromJson(jsonString);

import 'dart:convert';

FetchOfflineXml fetchOfflineXmlFromJson(String str) => FetchOfflineXml.fromJson(json.decode(str));

String fetchOfflineXmlToJson(FetchOfflineXml data) => json.encode(data.toJson());

class FetchOfflineXml {
  FetchOfflineXml({
    this.responseData,
    this.responseStatus,
  });

  ResponseData? responseData;
  ResponseStatus? responseStatus;

  factory FetchOfflineXml.fromJson(Map<String, dynamic> json) => FetchOfflineXml(
    responseData: parseResponseData(json["response_data"]),
    responseStatus: parseResponseStatus(json["response_status"]),
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
    this.password,
    this.docContent,
  });

  var password;
  var docContent;

  factory ResponseData.fromJson(Map<String, dynamic> json) => ResponseData(
    password: json["password"],
    docContent: json["doc_content"],
  );

  Map<String, dynamic> toJson() => {
    "password": password,
    "doc_content": docContent,
  };
}

class ResponseStatus {
  ResponseStatus({
    this.code,
    this.message,
    this.status,
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
