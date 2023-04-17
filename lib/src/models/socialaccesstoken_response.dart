import 'dart:convert';

SocialAdResponse socialAdResponseFromJson(String str) => SocialAdResponse.fromJson(json.decode(str));

String socialAdResponseToJson(SocialAdResponse data) => json.encode(data.toJson());

class SocialAdResponse {
  SocialAdResponse({
    required this.status,
    required this.token,
  });

 final String status;
 final String token;

  factory SocialAdResponse.fromJson(Map<String, dynamic> json) => SocialAdResponse(
    status: json["status"],
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "token": token,
  };
}