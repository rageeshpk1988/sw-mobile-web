import 'package:flutter/material.dart';

class Product with ChangeNotifier {
  final String? productDesc;
  final String? productHandler;
  final String? productImage;
  final String? productName;

  Product({
    this.productDesc,
    this.productHandler,
    this.productImage,
    this.productName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productDesc: json['productDesc'],
      productHandler: json['productHandler'],
      productImage: json['productImage'],
      productName: json['productName'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'productDesc': productDesc,
      'productHandler': productHandler,
      'productImage': productImage,
      'productName': productName,
    };
  }

  Map<String, dynamic> toMap(Product product) {
    return {
      'productDesc': product.productDesc,
      'productHandler': product.productHandler,
      'productImage': product.productImage,
      'productName': product.productName,
    };
  }

  static List<Map> convertProductListsToMap(
      {required List<Product> productLists}) {
    List<Map> products = [];
    productLists.forEach((Product obj) {
      Map objMap = Product().toMap(obj);
      products.add(objMap);
    });
    return products;
  }
}
