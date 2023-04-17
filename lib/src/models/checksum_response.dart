// To parse this JSON data, do
//
//     final checksumResponse = checksumResponseFromJson(jsonString);

import 'dart:convert';

ChecksumResponse checksumResponseFromJson(String str) => ChecksumResponse.fromJson(json.decode(str));

String checksumResponseToJson(ChecksumResponse data) => json.encode(data.toJson());

class ChecksumResponse {
  ChecksumResponse({
    required this.txnToken,
    required this.custId,
    required this.orderId,

  });

  String txnToken;
  String custId;
  String orderId;


  factory ChecksumResponse.fromJson(Map<String, dynamic> json) => ChecksumResponse(
    txnToken: json["txnToken"],
    custId: json["custID"],
    orderId: json["orderID"],

  );

  Map<String, dynamic> toJson() => {
    "txnToken": txnToken,
    "custID": custId,
    "orderID": orderId,

  };
}
