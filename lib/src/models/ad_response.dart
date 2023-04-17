import 'package:flutter/material.dart';

class ADResponse with ChangeNotifier {
  final String accessToken;
  final String refreshToken;
  final String idToken;
  final String tokenType;
  final expiresIn;
  final String status;

  ADResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.idToken,
    required this.tokenType,
    required this.expiresIn,
    required this.status,
  });

  factory ADResponse.fromJson(Map<String, dynamic> json) {
    return ADResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      idToken: json['id_token'],
      tokenType: json['token_type'],
      expiresIn: json['expires_in'],
      status: json['status'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'id_token': idToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'status': status,
    };
  }
}
