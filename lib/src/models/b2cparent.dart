import 'package:flutter/material.dart';
import '../../src/models/child.dart';

class B2CParent with ChangeNotifier {
  final int parentID;
  final String name;
  final String emailID;
  final String? country;
  var countryID;
  final String? state;
  var stateID;
  final String? location;
  var locationID;
  final String? pinCode;
  final String? profileImage;
  final String? kycType;
  final String? docType;
  final String? docNumber;
  final String? docImage;
  final List<Child>? childDetails;

  B2CParent({
    required this.parentID,
    required this.name,
    required this.emailID,
    this.country,
    this.countryID,
    this.state,
    this.stateID,
    this.location,
    this.locationID,
    this.pinCode,
    this.profileImage,
    this.kycType,
    this.docType,
    this.docNumber,
    this.docImage,
    this.childDetails,
  });

  factory B2CParent.fromJson(Map<String, dynamic> json) {
    return B2CParent(
      parentID: json['parentID'],
      name: json['name'],
      emailID: json['emailID'],
      country: json['country'],
      countryID: json['countryID'],
      state: json['state'],
      stateID: json['stateID'],
      location: json['location'],
      locationID: json['locationID'],
      pinCode: json['pinCode'],
      profileImage: json['profileImage'],
      kycType: json['kycType'],
      docType: json['docType'],
      docNumber: json['docNumber'],
      docImage: json['docImage'],
      childDetails: parseChildDetails(json['childDetails']),
    );
  }
  static List<Child> parseChildDetails(json) {
    final List<Child> children = [];
    for (Map<String, dynamic> dt in json) {
      Child child = Child.fromJson(dt);
      children.add(child);
    }
    return children;
  }

  Map<String, dynamic> toJson() {
    return {
      'parentID': parentID,
      'name': name,
      'emailID': emailID,
      'country': country,
      'countryID': countryID,
      'state': state,
      'stateID': stateID,
      'location': location,
      'locationID': locationID,
      'pinCode': pinCode,
      'profileImage': profileImage,
      'kycType': kycType,
      'docType': docType,
      'docNumber': docNumber,
      'docImage': docImage,
      'childDetails': childDetails!.length < 1
          ? []
          : childDetails!.map((e) => e.toJson()).toList(),
    };
  }
}
