import 'package:flutter/material.dart';

class PackageSubCategory {
  final String name;
  final String applicableStatus;
  final int quantity;
  PackageSubCategory({
    required this.name,
    required this.applicableStatus,
    required this.quantity,
  });
  factory PackageSubCategory.fromJson(Map<String, dynamic> json) {
    return PackageSubCategory(
      name: json['name'],
      applicableStatus: json['applicableStatus'],
      quantity: int.parse(json['quantity']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'applicableStatus': applicableStatus,
      'quantity': quantity,
    };
  }
}

class SubscriptionPackage with ChangeNotifier {
  final String period;
  final String packageName;
  final int packageId;
  final price;
  final String colorCode;
  final packageRate;
  final description;
  final String? consumableId;
  //final String packageSubscribeStatus;
  final List<PackageSubCategory>? subcatergoryList;

  SubscriptionPackage({
    required this.period,
    required this.packageName,
    required this.packageId,
    required this.price,
    required this.colorCode,
    required this.packageRate,
    required this.description,
    //required this.packageSubscribeStatus,
    this.subcatergoryList,
    this.consumableId,
  });

  factory SubscriptionPackage.fromJson(Map<String, dynamic> json) {
    return SubscriptionPackage(
        period: json['period'],
        packageName: json['packageName'],
        packageId: json['packageId'],
        price: json['price'],
        colorCode: json['colorCode'],
        packageRate: json['packageRate'],
        description: json['description'],
        consumableId: json['consumableId'],
        // packageSubscribeStatus: json['packageSubscribeStatus'] == null
        //     ? null
        //     : json['packageSubscribeStatus'],
        subcatergoryList: parsePackageSubCategory(json['subcategoryList']));
  }
  static List<PackageSubCategory> parsePackageSubCategory(json) {
    final List<PackageSubCategory> categories = [];
    for (Map<String, dynamic> dt in json) {
      PackageSubCategory packageSubCategory = PackageSubCategory.fromJson(dt);
      categories.add(packageSubCategory);
    }
    return categories;
  }
}
