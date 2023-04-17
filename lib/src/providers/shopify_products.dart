import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../src/models/api_response.dart';
import '../../helpers/global_variables.dart';
import '/helpers/custom_exceptions.dart';
import 'auth.dart';

class ShopifyProduct with ChangeNotifier {
  final int id;
  final String? title;
  final String? handle;
  final String? vendor;
  final String? image;

  ShopifyProduct({
    required this.id,
    this.title,
    this.handle,
    this.vendor,
    this.image,
  });

  factory ShopifyProduct.fromJson(Map<String, dynamic> json) {
    return ShopifyProduct(
      id: json['id'],
      title: json['title'],
      handle: json['handle'],
      vendor: json['vendor'],
      image: json['image'] != null ? json['image']['src'] : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'handle': handle,
      'vendor': vendor,
      'image': image,
    };
  }
}

class ShopifyProducts with ChangeNotifier {
  List<ShopifyProduct> _shopifyProducts = [];
  String? authToken;

  void update(String? token, List<ShopifyProduct> items) {
    authToken = token;
    _shopifyProducts = items;
  }

  //Getters
  List<ShopifyProduct> get shopifyProducts {
    return [..._shopifyProducts];
  }
  //Getters

  //Other Methods

  //Other Methods

  Future<void> fetchAndSetShopifyProducts() async {
    String authToken = await  Auth().interceptor();
    final url = '${GlobalVariables.apiEndPointProductService}/new-arrivals';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode >= 400) {
        notifyListeners();
        throw HttpException('Error in connecting to Service');
      }

      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        throw HttpException('Error in getting data from server');
      }
      if (extractedData['status'] < 200 || extractedData['status'] > 299) {
        //throw HttpException('Invalid login credentials');
        notifyListeners();
        return;
      }
      APIResponse apiResponse = APIResponse.fromJson(extractedData);

      final List<ShopifyProduct> loadedProducts = [];

      //Iterate the response and build the list
      for (Map<String, dynamic> dt in apiResponse.data!) {
        ShopifyProduct vendorProduct = ShopifyProduct.fromJson(dt);
        loadedProducts.add(vendorProduct);
      }

      _shopifyProducts = loadedProducts;
      notifyListeners();
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }
}
