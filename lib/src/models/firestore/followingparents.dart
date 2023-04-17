import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class FollowingParents with ChangeNotifier {
  final String? city;
  final int? userID;
  final DateTime? createdAt;
  final String? country;
  final String? userType;
  final String? state;
  final String? userName;
  final String? userImage;




  FollowingParents({
    this.city,
    this.userID,
    this.createdAt,
    this.country,
    this.userType,
    this.state,
    this.userName,
    this.userImage,
  });

  factory FollowingParents.fromJson(Map<String, dynamic> json) {
    return FollowingParents(
      city: json['city'],
      userID: json['userID'],
      createdAt: json['createdAt'].toDate(),
      country: json['country'],
      userType: json['userType'],
      state: json['state'],
      userName: json['userName'],
      userImage: json['userImage'],
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
  FollowingParents.fromSnapshot(DocumentSnapshot snapshot):

      city = snapshot['city'],
      userID = snapshot['userID'],
      createdAt = snapshot['createdAt'].toDate(),
      country = snapshot['country'],
      userType = snapshot['userType'],
      state = snapshot['state'],
      userName = snapshot['userName'],
      userImage = snapshot['userImage'];


}
//