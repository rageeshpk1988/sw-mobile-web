import 'package:flutter/material.dart';

class VendorImage with ChangeNotifier {
  final int? id;
  final String? img_url;
  final int? position;
  final int? product_id;

  VendorImage({
    this.id,
    this.img_url,
    this.position,
    this.product_id,
  });

  factory VendorImage.fromJson(Map<String, dynamic> json) {
    return VendorImage(
      id: json['id'],
      img_url: json['img_url'],
      position: json['position'],
      product_id: json['product_id'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'img_url': img_url,
      'position': position,
      'product_id': product_id,
    };
  }
}
