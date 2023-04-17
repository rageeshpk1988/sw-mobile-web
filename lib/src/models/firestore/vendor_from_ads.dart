import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class AdVendorProfile with ChangeNotifier {
  final String? city;
  final int? userID;
  final DateTime? createdAt;
  final String? country;
  final String? userType;
  final String? state;
  final String? userName;
  final String? userImage;




  AdVendorProfile({
    this.city,
    this.userID,
    this.createdAt,
    this.country,
    this.userType,
    this.state,
    this.userName,
    this.userImage,
  });

  factory AdVendorProfile.fromJson(Map<String, dynamic> json) {
    return AdVendorProfile(
      city: json['city'],
      userID: json['userID'],
      createdAt: null,
      country: json['country'],
      userType: json['userType'],
      state: json['state'],
      userName: json['name'],
      userImage: json['store_logo'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'userID': userID,
      'createdAt': createdAt,
      'country': country,
      'userType': userType,
      'state': state,
      'userName': userName,
      'userImage': userImage,
    };
  }
  AdVendorProfile.fromSnapshot(DocumentSnapshot snapshot):

        city = snapshot['city'],
        userID = snapshot['userID'],
        createdAt = snapshot['createdAt'].toDate(),
        country = snapshot['country'],
        userType = snapshot['userType'],
        state = snapshot['state'],
        userName = snapshot['userName'],
        userImage = snapshot['userImage'];


}