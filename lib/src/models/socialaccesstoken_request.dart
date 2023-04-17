import 'dart:convert';

SocialAdRequest socialAdRequestFromJson(String str) => SocialAdRequest.fromJson(json.decode(str));

String socialAdRequestToJson(SocialAdRequest data) => json.encode(data.toJson());

class SocialAdRequest {
  SocialAdRequest({
    required this.email,
    required this.name,
    required this.token,
  });

  final String? email;
  final String? name;
  final String token;

  factory SocialAdRequest.fromJson(Map<String, dynamic> json) => SocialAdRequest(
    email: json["email"],
    name: json["name"],
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "name": name,
    "token": token,
  };
}