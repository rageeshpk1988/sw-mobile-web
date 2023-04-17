import 'package:flutter/material.dart';

class FeedLike with ChangeNotifier {
  final String feedId;
  final DateTime? createdAt;
  final int userId;
  final String? userImage;
  final String? userName;

  FeedLike({
    required this.feedId,
    this.createdAt,
    required this.userId,
    this.userImage,
    this.userName,
  });

  factory FeedLike.fromJson(Map<String, dynamic> json, String feedId) {
    return FeedLike(
      feedId: feedId,
      createdAt: json['createdAt'].toDate(),
      userId: json['userId'],
      userImage: json['userImage'],
      userName: json['userName'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'userId': userId,
      'userImage': userImage,
      'userName': userName,
    };
  }
}
