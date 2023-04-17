import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '/src/models/child.dart';

import '/src/models/child_skill_summary_group.dart';

import '../../helpers/app_info.dart';
import '../../helpers/custom_exceptions.dart';
import '../../helpers/global_variables.dart';
import '../models/api_response.dart';
import 'auth.dart';

class ChildSkillSummary with ChangeNotifier {
  ChildSkillSummaryGroup? _skillSummaryGroup;
  String? authToken;

  void update(String? token) {
    this.authToken = token;
  }
  //Getters

  ChildSkillSummaryGroup? get skillSummaryGroup {
    return _skillSummaryGroup;
  }
  //Getters

  //Other Methods
  int _getAge(dateString) {
    var today = DateTime.now();
    var birthDate = DateTime.parse(dateString);
    var diff = today.difference(birthDate);
    var age = ((diff.inDays) / 365).round();
    return age;
  }

  //Other Methods
  //Http Methods
  Future<void> fetchAndSetSkillSummary(
      Child child, int parentId, String appType) async {
    String authToken = await  Auth().interceptor();
    // final url =
    //     '${GlobalVariables.apiBaseUrl}/login/android/b2c/childInterestCategory/getCategory';
    final url = '${GlobalVariables.apiEndPointLegacyService}/skill-summary';
    PackageInfo _packageInfo = await AppInfo.getPackageInfo();
    try {
      var stageID = '402';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        // headers: {
        //   'Content-Type': 'application/json',
        // },
        body: json.encode({
          'appVersion': _packageInfo.version,
          'boardID': child.boardId,
          'type': appType,
          'childID': child.childID,
          'countryID': child.countryID,
          'age': _getAge(child.dob),
          'parentId': parentId,
          'stageID': stageID, // child.stateId
        }),
      );

      if (response.statusCode >= 400) {
        notifyListeners();
        throw HttpException('Error in connecting to the service');
      }

      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        return;
      }
      if (extractedData['status'] >= 500) {
        throw HttpException('Data fetch error');
      }
      APIResponseMap apiResponse = APIResponseMap.fromJson(extractedData);

      if (apiResponse.data!['status'].toString().trim() != '00') {
        throw HttpException('${apiResponse.message}');
      }

      _skillSummaryGroup = ChildSkillSummaryGroup.fromJson(apiResponse.data!);
      // _skillSummaryGroup = ChildSkillSummaryGroup.fromJson(extractedData);

      // // APIResponseMap apiResponse = APIResponseMap.fromJson(extractedData);
      // // _skillSummaryGroup = ChildSkillSummaryGroup.fromJson(
      // //     apiResponse.data as Map<String, dynamic>);

      notifyListeners();
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException('Unknown Error  ${e.toString()}');
    }
  }

  Future<ChildSkillReport?> fetchAndSetSkillReport(
      int childId, int parentId, ChildSkillCategory category) async {
    String authToken = await  Auth().interceptor();
    final url =
        '${GlobalVariables.apiEndPointChildInterestService}/skill-report';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'assessmentId': category.catID,
          'childId': childId,
          'indexId': category.subCategoryList![0].subCategoryList![0].catID,
          'parentId': parentId,
          'percentage': category.percentage
        }),
      );

      if (response.statusCode >= 400) {
        throw HttpException('Error in connecting to the service');
      }

      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        return null;
      }
      APIResponseMap apiResponse = APIResponseMap.fromJson(extractedData);

      if (apiResponse.message! != 'Success') {
        throw HttpException('Data error');
      }

      ChildSkillReport report = ChildSkillReport.fromJson(apiResponse.data!);
      return report;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException('Unknown Error  ${e.toString()}');
    }
  }

  Future<String> fetchAssessmentDescription(int childId, int indexId) async {
    String authToken = await  Auth().interceptor();
    final url =
        '${GlobalVariables.apiEndPointAssessmentService}/assessment/description/$childId/$indexId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode >= 400) {
        throw HttpException('Error in connecting to the service');
      }

      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        return '';
      }
      if (extractedData['data'] == null) {
        return '';
      }
      APIResponseMap apiResponse = APIResponseMap.fromJson(extractedData);

      if (apiResponse.message! != 'Success') {
        throw HttpException('Data error');
      }
      return apiResponse.data!["description"];
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException('Unknown Error  ${e.toString()}');
    }
  }
  //Http Methods

}
