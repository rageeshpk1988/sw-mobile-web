import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/src/models/firestore/vendor_image.dart';
import '/src/models/firestore/fileobj.dart';

class VendorProduct with ChangeNotifier {
  final String? documentId;
  final String? title;
  final String? description;
  final List<FileObj>? fileObjs;
  late final String? handle;
  final int? id;
  final List<VendorImage>? images;
  final String? postType;
  final int? quantity;
  var rate;
  final int? vendorID;
  final String? vendorName;
  final String? vendorProfileImage;

  VendorProduct({
    this.documentId,
    this.title,
    this.description,
    this.fileObjs,
    this.handle,
    this.id,
    this.images,
    this.postType,
    this.quantity,
    this.rate,
    this.vendorID,
    this.vendorName,
    this.vendorProfileImage,
  });

  factory VendorProduct.fromJson(
      Map<String, dynamic> json, DocumentSnapshot prod) {
    return VendorProduct(
      documentId: prod.id,
      title: json['title'],
      description: json['description'],
      fileObjs: json['fileObj'] == null ? null : parseFileObjs(json['fileObj']),
      handle: json['handle'],
      id: json['id'],
      images: json['images'] == null ? null : parseImages(json['images']),
      postType: json['posType'],
      quantity: json['quantity'],
      rate: json['rate'],
      vendorID: json['vendorID'],
      vendorName: json['vendorName'],
      vendorProfileImage: json['vendorProfileImage'],
    );
  }
  static List<FileObj> parseFileObjs(json) {
    final List<FileObj> files = [];
    for (Map<String, dynamic> dt in json) {
      FileObj file = FileObj.fromJson(dt);
      files.add(file);
    }
    return files;
  }

  static List<VendorImage> parseImages(json) {
    final List<VendorImage> images = [];
    for (Map<String, dynamic> dt in json) {
      VendorImage image = VendorImage.fromJson(dt);
      images.add(image);
    }
    return images;
  }

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'title': title,
      'description': description,
      'handle': handle,
      'id': id,
      'images': images,
      'postType': postType,
      'quantity': quantity,
      'rate': rate,
      'vendorID': vendorID,
      'vendorName': vendorName,
      'vendorProfileImage': vendorProfileImage,
    };
  }
}
