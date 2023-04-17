import 'dart:convert';

Referral referralFromJson(String str) => Referral.fromJson(json.decode(str));

String referralToJson(Referral data) => json.encode(data.toJson());

class Referral {
  Referral({
    this.count,
    this.referralCode,
    this.referralDetailDto,
    this.subscribedCount,
  });

  int? count;
  String? referralCode;
  List<ReferralDetailDto>? referralDetailDto;
  int? subscribedCount;

  factory Referral.fromJson(Map<String, dynamic> json) => Referral(
    count: json["count"] == null ? null : json["count"],
    referralCode: json["referralCode"] == null ? null : json["referralCode"],
    referralDetailDto: json["referralDetailDto"] == null ? null : List<ReferralDetailDto>.from(json["referralDetailDto"].map((x) => ReferralDetailDto.fromJson(x))),
    subscribedCount: json["subscribedCount"] == null ? null : json["subscribedCount"],
  );

  Map<String, dynamic> toJson() => {
    "count": count == null ? null : count,
    "referralCode": referralCode == null ? null : referralCode,
    "referralDetailDto": referralDetailDto == null ? null : List<dynamic>.from(referralDetailDto!.map((x) => x.toJson())),
    "subscribedCount": subscribedCount == null ? null : subscribedCount,
  };
}

class ReferralDetailDto {
  ReferralDetailDto({
    this.dateOfJoining,
    this.parentId,
    this.parentName,
    this.rewardedStatus,
  });

  DateTime? dateOfJoining;
  int? parentId;
  String? parentName;
  String? rewardedStatus;

  factory ReferralDetailDto.fromJson(Map<String, dynamic> json) => ReferralDetailDto(
    dateOfJoining: json["dateOfJoining"] == null ? null : DateTime.parse(json["dateOfJoining"]),
    parentId: json["parentId"] == null ? null : json["parentId"],
    parentName: json["parentName"] == null ? null : json["parentName"],
    rewardedStatus: json["rewardedStatus"] == null ? null : json["rewardedStatus"],
  );

  Map<String, dynamic> toJson() => {
    "dateOfJoining": dateOfJoining == null ? null : dateOfJoining!.toIso8601String(),
    "parentId": parentId == null ? null : parentId,
    "parentName": parentName == null ? null : parentName,
    "rewardedStatus": rewardedStatus == null ? null : rewardedStatus,
  };
}
