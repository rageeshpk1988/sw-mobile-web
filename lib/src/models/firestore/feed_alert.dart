import 'package:flutter/material.dart';

class FeedAlert with ChangeNotifier {
  final String? countryName;
  final DateTime? createdAt;
  final String? imageUrl;
  final String? locationName;
  final String? message;
  final String? name;
  final int? parentID;
  final bool? readStatus;
  final String? stateName;
  final int? type;

  FeedAlert({
    this.countryName,
    this.createdAt,
    this.imageUrl,
    this.locationName,
    this.message,
    this.name,
    this.parentID,
    this.readStatus,
    this.stateName,
    this.type,
  });

  factory FeedAlert.fromJson(Map<String, dynamic> json, String feedId) {
    return FeedAlert(
      countryName: json['countryName'],
      createdAt: json['createdAt'].toDate(),
      imageUrl: json['imageUrl'],
      locationName: json['locationName'],
      message: json['message'],
      name: json['name'],
      parentID: json['parentID'],
      readStatus: json['readStatus'],
      stateName: json['stateName'],
      type: json['type'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'countryName': countryName,
      'createdAt': createdAt,
      'imageUrl': imageUrl,
      'locationName': locationName,
      'message': message,
      'parentID': parentID,
      'readStatus': readStatus,
      'stateName': stateName,
      'type': type,
    };
  }
}
