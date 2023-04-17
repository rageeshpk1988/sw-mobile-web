import 'package:flutter/material.dart';

class FeedComment with ChangeNotifier {
  final String feedId;
  final String? comments;
  final DateTime? createdAt;
  var userId;
  final String? userImage;
  final String? userName;

  FeedComment({
    required this.feedId,
    this.comments,
    this.createdAt,
    this.userId,
    this.userImage,
    this.userName,
  });

  factory FeedComment.fromJson(Map<String, dynamic> json, String feedId) {
    return FeedComment(
      feedId: feedId,
      comments: json['comments'],
      createdAt: json['createdAt'].toDate(),
      userId: json['userId'],
      userImage: json['userImage'],
      userName: json['userName'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'comments': comments,
      'createdAt': createdAt,
      'userId': userId,
      'userImage': userImage,
      'userName': userName,
    };
  }
}
