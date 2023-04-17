// To parse this JSON data, do
//
//     final fetchKycData = fetchKycDataFromJson(jsonString);

import 'dart:convert';

FetchKycData fetchKycDataFromJson(String str) => FetchKycData.fromJson(json.decode(str));

String fetchKycDataToJson(FetchKycData data) => json.encode(data.toJson());

class FetchKycData {
  FetchKycData({
    this.responseData,
    this.responseStatus,
  });

  ResponseData? responseData;
  ResponseStatus? responseStatus;

  factory FetchKycData.fromJson(Map<String, dynamic> json) => FetchKycData(
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
    this.address,
    this.gender,
    this.referenceId,
    this.docFace,
    this.docType,
    this.documentId,
    this.segAddress,
    this.verifiedBy,
    this.phone,
    this.dob,
    this.name,
    this.email,
    this.verifiedUsing,
  });

  var address;
  var gender;
  var referenceId;
  var docFace;
  var docType;
  var documentId;
  var segAddress;
  var verifiedBy;
  var phone;
  var dob;
  var name;
  var email;
  var verifiedUsing;

  factory ResponseData.fromJson(Map<String, dynamic> json) => ResponseData(
    address: json["address"],
    gender: json["gender"],
    referenceId: json["reference_id"],
    docFace: json["doc_face"],
    docType: json["doc_type"],
    documentId: json["document_id"],
    segAddress: json["seg_address"],
    verifiedBy: json["verified_by"],
    phone: json["phone"],
    dob: json["dob"],
    name: json["name"],
    email: json["email"],
    verifiedUsing: json["verified_using"],
  );

  Map<String, dynamic> toJson() => {
    "address": address,
    "gender": gender,
    "reference_id": referenceId,
    "doc_face": docFace,
    "doc_type": docType,
    "document_id": documentId,
    "seg_address": segAddress,
    "verified_by": verifiedBy,
    "phone": phone,
    "dob": dob,
    "name": name,
    "email": email,
    "verified_using": verifiedUsing,
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
