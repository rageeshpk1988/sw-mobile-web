import 'package:flutter/material.dart';
import '/src/models/b2cparent.dart';

class LoginResponse with ChangeNotifier {
  final String userType;
  final String status;
  final String updateStatus;
  final latestVersion;
  final latestIOSVersion;
  final String updateIOSStatus;
  final String remarks;
  String currentPackageStatus;
  final String userMode;
  final String adStatus;
  final int customerId;
  final String
      mobileNumber; // this is additional value which is not coming from api response
  // final String
  //     countryCode; // this is additional value stored in shared pref, if successful login
  // final List<schoolLicenceModel>? schoolLicenceModels; this is not yet provided
  final B2CParent? b2cParent;
   String token;
   DateTime? tokenExpiry;
  LoginResponse({
    required this.userType,
    required this.status,
    required this.updateStatus,
    required this.latestVersion,
    required this.latestIOSVersion,
    required this.updateIOSStatus,
    required this.remarks,
    required this.currentPackageStatus,
    required this.userMode,
    required this.adStatus,
    required this.customerId,
    required this.mobileNumber,
    // required this.countryCode,
    this.b2cParent,
    required this.token,
    this.tokenExpiry,
  });

  factory LoginResponse.fromJson(
      Map<String, dynamic> json, String mobileNumber) {
    return LoginResponse(
        userType: json['userType'],
        status: json['status'],
        updateStatus: json['updateStatus'],
        latestVersion: json['latestVersion'],
        latestIOSVersion: json['latestIOSVersion'],
        updateIOSStatus: json['updateIOSStatus'],
        remarks: json['remarks'],
        currentPackageStatus: json['currentPackageStatus'],
        userMode: json['userMode'],
        adStatus: json['adStatus'],
        customerId: json['customerId'],
        b2cParent: parseB2CParent(json['b2cParentModel']),
        mobileNumber: mobileNumber == '' ? json['mobileNumber'] : mobileNumber,
        token: json['token'] == null ? ' ' : json['token'],
        tokenExpiry: json['tokenExpiry'] == null ? null :DateTime.parse(json['tokenExpiry']),
        //countryCode: countryCode == '' ? json['countryCode'] : countryCode,
        );
  }
  //Parse the inner json by calling the parent class of the object
  static B2CParent? parseB2CParent(json) {
    if (json == null) return null;
    B2CParent response = B2CParent.fromJson(json);
    return response;
  }

  Map<String, dynamic> toJson() {
    return {
      'userType': userType,
      'status': status,
      'updateStatus': updateStatus,
      'latestVersion': latestVersion,
      'latestIOSVersion': latestIOSVersion,
      'updateIOSStatus': updateIOSStatus,
      'remarks': remarks,
      'currentPackageStatus': currentPackageStatus,
      'userMode': userMode,
      'adStatus': adStatus,
      'customerId': customerId,
      'b2cParentModel': encodeB2CParent(b2cParent),
      'mobileNumber': mobileNumber,
      'token': token,
      'tokenExpiry': tokenExpiry?.toIso8601String()
      // 'countryCode': countryCode,
    };
  }

  static Map<String, dynamic> encodeB2CParent(b2cParent) {
    Map<String, dynamic> response = b2cParent.toJson();
    return response;
  }
}
