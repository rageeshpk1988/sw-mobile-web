// To parse this JSON data, do
//
//     final transactionResponse = transactionResponseFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

TransactionResponse transactionResponseFromJson(String str) => TransactionResponse.fromJson(json.decode(str));

String transactionResponseToJson(TransactionResponse data) => json.encode(data.toJson());

class TransactionResponse {
  TransactionResponse({
    required this.txnamount,
    required this.txndate,
    required this.banktxnid,
    required this.txnid,
    this.bankname,
    required this.gatewayname,
    required this.checksumhash,
    required this.status,
    required this.orderid,
    required this.mid,
    required this.paymentmode,
    required this.respcode,
    required this.currency,
    required this.respmsg,
  });

  String? txnamount;
  DateTime txndate;
  String? banktxnid;
  String? txnid;
  String? bankname;
  String? gatewayname;
  String? checksumhash;
  String? status;
  String? orderid;
  String? mid;
  String? paymentmode;
  String? respcode;
  String? currency;
  String? respmsg;

  factory TransactionResponse.fromJson(Map<dynamic, dynamic> json) => TransactionResponse(
    txnamount: json["TXNAMOUNT"],
    txndate: DateTime.parse(json["TXNDATE"]),
    banktxnid: json["BANKTXNID"],
    txnid: json["TXNID"],
    bankname: json["BANKNAME"],
    gatewayname: json["GATEWAYNAME"],
    checksumhash: json["CHECKSUMHASH"],
    status: json["STATUS"],
    orderid: json["ORDERID"],
    mid: json["MID"],
    paymentmode: json["PAYMENTMODE"],
    respcode: json["RESPCODE"],
    currency: json["CURRENCY"],
    respmsg: json["RESPMSG"],
  );

  Map<String, dynamic> toJson() => {
    "TXNAMOUNT": txnamount,
    "TXNDATE": txndate.toIso8601String(),
    "BANKTXNID": banktxnid,
    "TXNID": txnid,
    "BANKNAME": bankname,
    "GATEWAYNAME": gatewayname,
    "CHECKSUMHASH": checksumhash,
    "STATUS": status,
    "ORDERID": orderid,
    "MID": mid,
    "PAYMENTMODE": paymentmode,
    "RESPCODE": respcode,
    "CURRENCY": currency,
    "RESPMSG": respmsg,
  };
}

