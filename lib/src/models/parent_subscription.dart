// To parse this JSON data, do
//
//     final parentSubscriptions = parentSubscriptionsFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ParentSubscription parentSubscriptionsFromJson(String str) =>
    ParentSubscription.fromJson(json.decode(str));

String parentSubscriptionsToJson(ParentSubscription data) =>
    json.encode(data.toJson());

class ParentSubscription {
  String colorCode;
  String description;
  DateTime? createdDate;
  DateTime? endingDate;
  int packageId;
  String packageName;
  int parentId;
  int period;
  var price;
  String remainingDays;
  String? consumableId;
  DateTime? startingDate;
  List<SubCategoryList> subCategoryList;
  ParentSubscription({
    required this.colorCode,
    required this.description,
    required this.createdDate,
    required this.endingDate,
    required this.packageId,
    required this.packageName,
    required this.parentId,
    required this.period,
    required this.price,
    required this.remainingDays,
    required this.startingDate,
    this.consumableId,
    required this.subCategoryList,
  });

  factory ParentSubscription.fromJson(Map<String, dynamic> json) =>
      ParentSubscription(
        colorCode: json["colorCode"],
        description: json["description"],
        createdDate: json['createdDate'] != null
            ? DateTime.parse(json['createdDate'])
            : json['createdDate'],
        endingDate: json['endingDate'] != null
            ? DateTime.parse(json['endingDate'])
            : json['endingDate'],
        packageId: json["packageId"],
        packageName: json["packageName"],
        consumableId: json["consumableId"],
        parentId: json["parentId"],
        period: json["period"],
        price: json["price"],
        remainingDays: json["remainingDays"],
        startingDate: json['startingDate'] != null
            ? DateTime.parse(json['startingDate'])
            : json['startingDate'],
        subCategoryList: List<SubCategoryList>.from(
            json["subCategoryList"].map((x) => SubCategoryList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "colorCode": colorCode,
        "description": description,
        "createdDate": createdDate,
        "endingDate": endingDate,
        "packageId": packageId,
        "packageName": packageName,
        "parentId": parentId,
        "period": period,
        "price": price,
        "remainingDays": remainingDays,
        "startingDate": startingDate,
        "subCategoryList":
            List<dynamic>.from(subCategoryList.map((x) => x.toJson())),
      };
}

class SubCategoryList {
  String categoryName;
  int categoryId;
  int count;
  String couponCode;
  String? handlerName;
  int unusedPlan;

  SubCategoryList({
    required this.categoryName,
    required this.categoryId,
    required this.count,
    required this.couponCode,
    this.handlerName,
    required this.unusedPlan,
  });

  factory SubCategoryList.fromJson(Map<String, dynamic> json) =>
      SubCategoryList(
        categoryName: json["categoryName"],
        categoryId: json["categoryId"],
        count: json["count"],
        couponCode: json["couponCode"],
        handlerName: json["handlerName"] ?? json["handlerName"],
        unusedPlan: json["unusedPlan"],
      );

  Map<String, dynamic> toJson() => {
        "categoryName": categoryName,
        "categoryId": categoryId,
        "count": count,
        "couponCode": couponCode,
        "handlerName": handlerName,
        "unusedPlan": unusedPlan,
      };
}

class ParentSubscriptionGroup {
  ParentSubscription currentPlan;
  List<ParentSubscription>? futurePlan;
  ParentSubscriptionGroup({
    required this.currentPlan,
    this.futurePlan,
  });
  factory ParentSubscriptionGroup.fromJson(Map<String, dynamic> json) =>
      ParentSubscriptionGroup(
        currentPlan: parseCurrentSubscription(json['currentPlan']),
        futurePlan: json['futurePlan'] == null
            ? null
            : parseFutureSubscriptions(json['futurePlan']),
      );

  static ParentSubscription parseCurrentSubscription(json) {
    ParentSubscription response = ParentSubscription.fromJson(json);
    return response;
  }

  static List<ParentSubscription> parseFutureSubscriptions(json) {
    final List<ParentSubscription> subs = [];
    for (Map<String, dynamic> dt in json) {
      ParentSubscription sub = ParentSubscription.fromJson(dt);
      subs.add(sub);
    }
    return subs;
  }

  Map<String, dynamic> toJson() => {
        "currentPlan": currentPlan,
        "futurePlan": futurePlan,
      };
}
