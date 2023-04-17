import 'package:flutter/material.dart';

class AdObj with ChangeNotifier {
  final int? addId;
  final String? imageUrl;
  final String? pageType;
  final String? url;
  final String? productHandle;
  final String? inAppPage;
  final int? vendorId;

  AdObj({
    this.addId,
    this.pageType,
    this.imageUrl,
    this.url,
    this.productHandle,
    this.inAppPage,
    this.vendorId,
  });

  factory AdObj.fromJson(Map<String, dynamic> json) {
    return AdObj(
      addId: json['adId'],
      imageUrl: json['imageUrl'],
      pageType: json['redirectionType'],
      url: json['redirectUrl'],
      productHandle: json['productHandle'],
      inAppPage: json['inAppPage'],
      vendorId: json['vendorId'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'adId': addId,
      'imageUrl': imageUrl,
      'redirectUrl': url,
      'redirectionType':pageType,
      'productHandle':productHandle,
      'inAppPage':inAppPage,
      'vendorId':vendorId,
    };
  }

  Map<String, dynamic> toMap(AdObj file) {
    return {
      'adId': file.addId,
      'imageUrl': file.imageUrl,
      'redirectUrl': file.url,
      'redirectionType': file.pageType,
      'productHandle':file.productHandle,
      'inAppPage':file.inAppPage,
      'vendorId':file.vendorId,

    };
  }

  static List<Map> convertFileObjsToMap({required List<AdObj> adObjs}) {
    List<Map> ads = [];
    adObjs.forEach((AdObj obj) {
      Map objMap = AdObj().toMap(obj);
      ads.add(objMap);
    });
    return ads;
  }
}