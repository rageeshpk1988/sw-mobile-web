import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import '/src/models/api_response.dart';
import '../../helpers/app_info.dart';
import '../../helpers/global_variables.dart';
import '../../src/models/achievement_category.dart';
import '../../src/models/child.dart';
import '../../src/models/firestore/student.dart';

import 'package:flutter_share_me/flutter_share_me.dart';
import '/helpers/custom_exceptions.dart';
import '/src/models/firestore/feedpost.dart';
import '/src/models/firestore/fileobj.dart';
import '/src/models/firestore/productlist.dart';
import '/src/models/firestore/vendor_product.dart';
import '/src/providers/firestore_services.dart';
import 'auth.dart';

enum FeedPostType { GENERAL, ACTIVITY, ACHIEVEMENT }

class FeedPosts with ChangeNotifier {
//Class variables

//Class variables

//Getters

//Getters

//Private methods

//Private methods
//Public methods
  Future<bool> addNewPost(
    FeedPostType postType,
    FeedPost feedPost,
    String? appVersion,
    List<File> imageFiles,
    List<File> videoFiles,
    List<File>? allFiles,
    List<VendorProduct>? vendorProducts,
    List<Child>? children,
    bool facebook,
  ) async {
    String authToken = await Auth().interceptor();
    var url = '';
    String requestData = '';
    String childIDForAPI = '';
    //as per the API request send the first child id to the API
    if (children != null) {
      if (children.isNotEmpty) {
        childIDForAPI = children[0].childID.toString();
      }
    }
    if (postType == FeedPostType.GENERAL) {
      //url = '${GlobalVariables.apiBaseUrl}/login/android/postcategory/post';
      url = '${GlobalVariables.apiEndPointLegacyService}/post-category';
      requestData =
          '{"appVersion":"$appVersion","details":"${feedPost.description}", "parentId":${feedPost.postedUserID},'
          '"title":"${feedPost.title}"}';
    } else if (postType == FeedPostType.ACTIVITY) {
      // url =
      //     '${GlobalVariables.apiBaseUrl}/login/android/b2c/parentActivity/post';
      url = '${GlobalVariables.apiEndPointLegacyService}/parent-activity';
      requestData =
          '{"appVersion":"$appVersion","description":"${feedPost.description}", "parentID":${feedPost.postedUserID},'
          '"title":"${feedPost.title}","studentID":"$childIDForAPI"}';
    } else {
      // url = '${GlobalVariables.apiBaseUrl}/login/android/b2c/achievement/post';
      url = '${GlobalVariables.apiEndPointLegacyService}/achievement';
      String teamType = feedPost.team == true ? 'Team' : '';
      requestData =
          '{"achievement":"${feedPost.achievement}","categoryId":"${feedPost.categoryId}",'
          '"description":"${feedPost.description}","issuingAuthority":"${feedPost.issuingAuthority}",'
          '"parentId":${feedPost.postedUserID}, "teamType":"$teamType",'
          '"title":"${feedPost.title}","studentID":"$childIDForAPI"}';
    }

    bool returnValue = false;
    try {
      var request = http.MultipartRequest("POST", Uri.parse(url));
      request.headers['authorization'] = 'Bearer ${authToken}';
      request.fields['data'] = requestData;

      // if (imageFiles.isNotEmpty) {
      //   for (File file in imageFiles) {
      //     request.files
      //         .add(await http.MultipartFile.fromPath('attachments', file.path));
      //   }
      // }
      // if (videoFiles.isNotEmpty) {
      //   for (File file in videoFiles) {
      //     request.files
      //         .add(await http.MultipartFile.fromPath('attachments', file.path));
      //   }
      // }
      if (allFiles!.isNotEmpty) {
        for (File file in allFiles) {
          request.files
              .add(await http.MultipartFile.fromPath('attachments', file.path));
        }
      }

      final response = await request.send();

      final extractedResult = await response.stream.bytesToString();
      final extractedData = json.decode(extractedResult);

      if (response.statusCode >= 400) {
        notifyListeners();
        returnValue = false;
        throw HttpException(
            'Error in connecting to the service ${response.statusCode} ');
      }

      APIResponseMap apiResponse = APIResponseMap.fromJson(extractedData);

      if (apiResponse.data!['status'].toString().trim() == '00') {
        //update the firestore collection

        //Add media files
        feedPost.fileObjs = [];
        for (Map<String, dynamic> dt in apiResponse.data!['fileUrls']) {
          FileObj fileObj = FileObj.fromJson(dt);
          feedPost.fileObjs!.add(fileObj);
        }

        //Add tagged products
        if (postType == FeedPostType.GENERAL) {
          feedPost.productList = [];
          for (VendorProduct prd in vendorProducts!) {
            Product product = Product(
              productDesc: prd.description,
              productHandler: prd.handle,
              productImage: prd.images![0].img_url,
              productName: prd.title,
            );
            feedPost.productList!.add(product);
          }
        }
        if (postType == FeedPostType.ACTIVITY ||
            postType == FeedPostType.ACHIEVEMENT) {
          feedPost.studentDetails = [];
          for (Child child in children!) {
            Student student = Student(
              studentID: child.childID.toString(),
              studentName: child.name,
              studentImage: child.imageUrl,
            );
            feedPost.studentDetails!.add(student);
          }
        }
        //Add remaining properties to feedPost
        feedPost.commentCount = 0;
        feedPost.createdAt = DateTime.now();
        feedPost.discount = 0;
        feedPost.enquiryFlag = false;
        feedPost.enquiryMessage = '';
        feedPost.likeCount = 0;
        feedPost.onlinePay = false;
        feedPost.postType = postType == FeedPostType.GENERAL
            ? 'General'
            : postType == FeedPostType.ACTIVITY
                ? 'Activity'
                : 'Achievement';

        feedPost.postedBy = 'Parent';
        feedPost.rate = 0;
        feedPost.scheduledDate = DateTime.now();
        feedPost.updatedAt = DateTime.now();
        if (facebook == true) {
          final FlutterShareMe flutterShareMe = FlutterShareMe();
          final urlShare = Uri.encodeComponent(
              '${GlobalVariables.apiBaseUrl}/login/${feedPost.fileObjs!.first.url}');
          String shareUrl =
              '${GlobalVariables.apiBaseUrl}/login/${feedPost.fileObjs!.first.url}';
          // final quote= Uri.encodeComponent(feedPost.title!);
          final text = '${feedPost.title}\n\n${feedPost.description}';
          final quote = Uri.encodeComponent(text);
          final url =
              'https://www.facebook.com/sharer/sharer.php?&u=$urlShare&quote=$quote';
          //  print(url);
          await flutterShareMe.shareToFacebook(url: shareUrl, msg: text);
        }

        FirestoreServices.addNewPost(feedPost);

        returnValue = true;
        //update the firestore collection
      } else if (apiResponse.data!['status'].toString().trim() == '01') {
        notifyListeners();
        returnValue = false;
        throw HttpException('Data updation failed');
      } else if (apiResponse.data!['status'].toString().trim() == '02') {
        returnValue = false;
        throw HttpException('Invalid User');
      }
      notifyListeners();
      return returnValue;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException('Error: $e');
    }
  }

  Future<List<AchievementCategory>> fetchAchievementCategories(
      int parentId) async {
    String authToken = await Auth().interceptor();
    PackageInfo _packageInfo = await AppInfo.getPackageInfo();
    var mobileOs = kIsWeb
        ? 'unknown'
        : Platform.isAndroid
            ? "android"
            : "iOs";

    // final url =
    //     '${GlobalVariables.apiBaseUrl}/login/android/b2c/achievement/getStudentListByParent';
    final url =
        '${GlobalVariables.apiEndPointLegacyService}/achievement-category';

    try {
      final response = await http.post(
        Uri.parse(url),
        // headers: {'Content-Type': 'application/json'},
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'appVersion': _packageInfo.version,
          'mobileOs': mobileOs,
          'parentId': parentId,
        }),
      );
      if (response.statusCode >= 400) {
        notifyListeners();
        throw HttpException('Error in connecting to the service');
      }

      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        throw HttpException('Error in getting data from server');
      }
      APIResponseMap apiResponse = APIResponseMap.fromJson(extractedData);

      if (apiResponse.data!['status'].toString().trim() != '00') {
        throw HttpException('Unable to fetch achievement categories');
      }
      // if (extractedData['status'].toString().trim() != '00') {
      //   throw HttpException('Unable to fetch achievement categories');
      // }
      final List<AchievementCategory> loadedCategories = [];

      //Iterate the response and build the list
      for (Map<String, dynamic> dt
          in apiResponse.data!['achievementCategoryList']) {
        AchievementCategory category = AchievementCategory.fromJson(dt);
        loadedCategories.add(category);
      }

      return loadedCategories;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }

//Public methods
}
