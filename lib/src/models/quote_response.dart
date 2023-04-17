// To parse this JSON data, do
//
//     final quoteResponse = quoteResponseFromJson(jsonString);

import 'dart:convert';

QuoteResponse quoteResponseFromJson(String str) => QuoteResponse.fromJson(json.decode(str));

String quoteResponseToJson(QuoteResponse data) => json.encode(data.toJson());

class QuoteResponse {
  QuoteResponse({
    this.data,
    required this.error,
    required this.message,
    required this.status,
    required this.version,
  });

  Data? data;
  List<Error> error;
  String message;
  int status;
  String version;

  factory QuoteResponse.fromJson(Map<String, dynamic> json) => QuoteResponse(
    data: Data.fromJson(json["data"]),
    error: json["error"] != null ? List<Error>.from(json["error"].map((x) => Error.fromJson(x))):[],
    message: json["message"],
    status: json["status"],
    version: json["version"],
  );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "error": List<dynamic>.from(error.map((x) => x.toJson())),
    "message": message,
    "status": status,
    "version": version,
  };
}

class Data {
  Data({
    this.author,
    this.quote,
  });

  String? author;
  String? quote;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    author: json["author"],
    quote: json["quote"],
  );

  Map<String, dynamic> toJson() => {
    "author": author,
    "quote": quote,
  };
}

class Error {
  Error({
    this.fieldName,
    this.message,
  });

  String? fieldName;
  String? message;

  factory Error.fromJson(Map<String, dynamic> json) => Error(
    fieldName: json["fieldName"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "fieldName": fieldName,
    "message": message,
  };
}
