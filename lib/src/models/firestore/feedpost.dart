import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../src/models/firestore/productlist.dart';
import '../../../src/models/firestore/fileobj.dart';
import '../../../src/models/firestore/student.dart';

class FeedPost with ChangeNotifier {
  final String? documentId;
  String? achievement;
  String? categoryId;
  int? commentCount;
  DateTime? createdAt;
  String? description;
  var discount;
  bool? enquiryFlag;
  String? enquiryMessage;
  String? issuingAuthority;
  int? likeCount;
  bool? onlinePay;
  String? postType;
  String? postedBy;
  String? postedByUserCountry;
  String? postedByUserLocation;
  String? postedByUserState;
  int? postedUserID;
  String? postedUserName;
  String? productId;
  String? profileImage;
  bool? purchaseFlag;
  var rate;
  DateTime? scheduledDate;
  bool? team;
  String? title;
  DateTime? updatedAt;
  List<FileObj>? fileObjs;
  List<Student>? studentDetails;
  List<Product>? productList;

  FeedPost({
    this.documentId,
    this.achievement,
    this.categoryId,
    this.commentCount,
    this.createdAt,
    this.description,
    this.discount,
    this.enquiryFlag,
    this.enquiryMessage,
    this.issuingAuthority,
    this.likeCount,
    this.onlinePay,
    this.postType,
    this.postedBy,
    this.postedByUserCountry,
    this.postedByUserLocation,
    this.postedByUserState,
    this.postedUserID,
    this.postedUserName,
    this.productId,
    this.profileImage,
    this.purchaseFlag,
    this.rate,
    this.scheduledDate,
    this.team,
    this.title,
    this.updatedAt,
    this.fileObjs,
    this.studentDetails,
    this.productList,
  });

  factory FeedPost.fromJson(
    Map<String, dynamic> json,
    DocumentSnapshot? feed,
  ) {
    return FeedPost(
      documentId: feed!.id,
      achievement: json['achievement'],
      categoryId: json['categoryId'],
      commentCount: json['commentCount'],
      createdAt: json['createdAt'] == null ? null : json['createdAt'].toDate(),
      description: json['description'],
      discount: json['discount'],
      enquiryFlag: json['enquiryFlag'],
      enquiryMessage: json['enquiryMessage'],
      issuingAuthority: json['issuingAuthority'],
      likeCount: json['likeCount'],
      onlinePay: json['onlinePay'],
      postType: json['postType'],
      postedBy: json['postedBy'],
      postedByUserCountry: json['postedByUserCountry'],
      postedByUserLocation: json['postedByUserLocation'],
      postedByUserState: json['postedByUserState'],
      postedUserID: json['postedUserID'],
      postedUserName: json['postedUserName'],
      productId: json['productId'],
      profileImage: json['profileImage'],
      purchaseFlag: json['purchaseFlag'],
      rate: json['rate'],
      scheduledDate:
          json['scheduledDate'] == null ? null : json['scheduledDate'].toDate(),
      team: json['team'],
      title: json['title'],
      updatedAt: json['updatedAt'] == null ? null : json['updatedAt'].toDate(),
      fileObjs: parseFileObjs(json['fileObj']),
      studentDetails: json['studentDetails'] == null
          ? null
          : parseStudentDetails(json['studentDetails']),
      productList: json['productList'] == null
          ? null
          : parseProductList(json['productList']),
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

  static List<Student> parseStudentDetails(json) {
    final List<Student> students = [];
    for (Map<String, dynamic> dt in json) {
      Student student = Student.fromJson(dt);
      students.add(student);
    }
    return students;
  }

  static List<Product> parseProductList(json) {
    final List<Product> productLists = [];
    for (Map<String, dynamic> dt in json) {
      Product productList = Product.fromJson(dt);
      productLists.add(productList);
    }
    return productLists;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': documentId,
      'achievement': achievement,
      'categoryId': categoryId,
      'commentCount': commentCount,
      'createdAt': createdAt,
      'description': description,
      'discount': discount,
      'enquiryFlag': enquiryFlag,
      'enquiryMessage': enquiryMessage,
      'issuingAuthority': issuingAuthority,
      'likeCount': likeCount,
      'onlinePay': onlinePay,
      'postType': postType,
      'postedBy': postedBy,
      'postedByUserCountry': postedByUserCountry,
      'postedByUserLocation': postedByUserLocation,
      'postedByUserState': postedByUserState,
      'postedUserID': postedUserID,
      'postedUserName': postedUserName,
      'productId': productId,
      'profileImage': profileImage,
      'purchaseFlag': purchaseFlag,
      'rate': rate,
      'title': title,
      'updatedAt': updatedAt,
      'studentDetails': studentDetails!.length < 1
          ? []
          : studentDetails!.map((e) => e.toJson()).toList(),
      // 'productLists': productLists!.length < 1
      //     ? []
      //     : productLists!.map((e) => e.toJson()).toList(),
    };
  }

  // factory FeedPost.fromFirestore(DocumentSnapshot documentSnapshot) {
  //   FeedPost feedPost = FeedPost.fromJson(
  //       documentSnapshot.data() as Map<String, dynamic>, documentSnapshot);
  //   return feedPost;
  // }
}
