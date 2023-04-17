import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../src/models/child_recomendation.dart';
import '../../helpers/global_variables.dart';
import '../models/api_response.dart';

import '/helpers/custom_exceptions.dart';
import 'auth.dart';

class ChildRecomendations with ChangeNotifier {
  String? authToken;

  void update(String? token) {
    this.authToken = token;
  }
  //Getters
  //Getters

  //HTTP Methods
  Future<List<ChildSuggestion>> fetchChildSuggestions(
      int childId, int parentId) async {
    String authToken = await Auth().interceptor();
    final url =
        '${GlobalVariables.apiEndPointChildInterestService}/child-interest-suggestions/$parentId/$childId';

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
        //notifyListeners();
        throw HttpException('Error in connecting to the service');
      }

      final extractedData = json.decode(response.body);
      // print(extractedData.toString());
      if (extractedData == null) {
        return [];
      }
      if (extractedData['status'] > 200) {
        throw Exception(extractedData['message']);
      }
      APIResponseMap apiResponse = APIResponseMap.fromJson(extractedData);

      final List<ChildSuggestion> loadedSuggestions = [];

      //Iterate the response and build the list
      for (Map<String, dynamic> dt in apiResponse.data!['suggestions']) {
        ChildSuggestion suggestion = ChildSuggestion.fromJson(dt);
        loadedSuggestions.add(suggestion);
      }
      return loadedSuggestions;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException {
      throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<bool> sentAssessmentData(int assessmentId, String assessmentName,
      int parentId, int studentId) async {
    String authToken = await Auth().interceptor();
    final url = '${GlobalVariables.apiEndPointChildInterestService}/assessment';

    bool returnValue = true;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          "assessmentId": assessmentId,
          "assessmentName": "$assessmentName",
          "assessmentType": "Basic",
          "parentId": parentId,
          "studentId": studentId
        }),
      );
      // var req = json.encode({
      //   "assessmentId": assessmentId,
      //   "assessmentName": "$assessmentName",
      //   "assessmentType": "Basic",
      //   "parentId": parentId,
      //   "studentId": studentId
      // });
      // print("req: ${req.toString()}");

      final responseData = json.decode(response.body);
      //  print("resp: ${responseData.toString()}");

      if (response.statusCode >= 400) {
        returnValue = false;
        throw HttpException('Error in connecting to the service');
      }

      if (responseData['data'] == true) {
        returnValue = true;
      } else {
        returnValue = false;
        throw HttpException(responseData['message']);
      }
      return returnValue;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }

//TODO :: This has to be removed later
  // Future<bool> getQuestion(GetQuestionReq getQuestionReq) async {
  //   final url =
  //       '${GlobalVariables.apiBaseUrl}login/android/b2c/questions/getQuestion';
  //   bool retValue = false;
  //   // PackageInfo _packageInfo = await AppInfo.getPackageInfo();
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({"age":"${getQuestionReq.age}",
  //         "studentId" :"${getQuestionReq.studentId}",
  //         "hierarchyId" :"${getQuestionReq.hierarchyId}",
  //         "currentLeafId" : "${getQuestionReq.currentLeafId}",
  //         "countryCode" :"${getQuestionReq.countryCode}",
  //         "hierarchyCount" : "${getQuestionReq.hierarchyCount}"}
  //       ),
  //     );
  //     if (response.statusCode >= 400) {
  //       retValue = false;
  //       notifyListeners();
  //       throw HttpException('Error in connecting to the service');
  //     }

  //     final extractedData = json.decode(response.body);
  //     if (extractedData == null) {
  //       retValue = false;
  //       throw HttpException('Error in getting data from server');
  //     }
  //     if (extractedData['status'].toString().trim() != '00') {
  //       retValue = false;
  //       //TODO:: This error message need to be changed
  //       throw HttpException('Invalid operation');
  //     }

  //     if(extractedData['questionCompletionStatus'].toString().trim() == 'notcompleted')
  //     {
  //       retValue = true;
  //       notifyListeners();
  //     }

  //     return retValue;
  //   } on SocketException {
  //     throw NoInternetException('No Internet');
  //   } on HttpException catch (e) {
  //     throw NoServiceFoundException(e.message);
  //     //throw NoServiceFoundException('No Service Found');
  //   } catch (e) {
  //     throw UnknownException('Unknown Error');
  //   }
  // }

//HTTP Methods
}
