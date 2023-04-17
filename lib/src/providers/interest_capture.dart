import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/src/models/interest_qa.dart';
import '../../helpers/global_variables.dart';
import '../models/api_response.dart';
import '/helpers/custom_exceptions.dart';
import 'auth.dart';

class InterestCapture with ChangeNotifier {
  InterestQA? _interestQA;
  String? authToken;
  // InterestStatus? _interestStatus;

  void update(String? token) {
    this.authToken = token;
  }

  //Getters
  InterestQA? get interestQA {
    return _interestQA;
  }

  //Getters
  //Other Methods

  //chek the object (if list is not empty search with q no. update answer id), if it
  //is empty add to the list

  //Other Methods
  //HTTP Methods
  Future<void> fetchAndSetInterestQAs(int childId, int parentId) async {
    String authToken = await Auth().interceptor();
    final url =
        '${GlobalVariables.apiEndPointChildInterestService}/child-interest-questions';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({'childId': childId, 'parentId': parentId}),
      );

      if (response.statusCode >= 400) {
        notifyListeners();
        throw HttpException('Error in connecting to the service');
      }else
      if (response.statusCode == 204) {
        notifyListeners();
        throw HttpException('We are fetching the results, Please try after a few seconds.!');
      }

      final extractedData = json.decode(response.body);
      // print(extractedData.toString());
      if (extractedData['status'] >= 400) {
        throw Exception(extractedData['message']);
      }
      if (extractedData == null) {
        return;
      }



      APIResponseMap apiResponse = APIResponseMap.fromJson(extractedData);
      _interestQA =
          InterestQA.fromJson(apiResponse.data as Map<String, dynamic>);
      //print(_interestQA?.moreRecords);

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

  Future<bool> updateAnswer(int parentId, int childId, bool submitted,
      QuestionAnswer question) async {
    String authToken = await Auth().interceptor();
    final url =
        '${GlobalVariables.apiEndPointChildInterestService}/child-interest';

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
          'answer': question.answer,
          'answerId': question.answerId,
          'parentId': parentId,
          'question': question.question,
          'questionId': question.questionId,
          'studentId': childId,
          'submitted': submitted,
        }),
      );
      // var requestSent = json.encode({
      //   'answer': question.answer,
      //   'answerId': question.answerId,
      //   'parentId': parentId,
      //   'question': question.question,
      //   'questionId': question.questionId,
      //   'studentId': childId,
      //   'submitted': submitted,
      // });
      // print("request sent: ${requestSent.toString()}");

      final responseData = json.decode(response.body);
      // print(responseData.toString());
      if (response.statusCode >= 400) {
        returnValue = false;
        throw HttpException('Error in connecting to the service');
      }
      if (responseData['status'] >= 400) {
        returnValue = false;
        throw Exception(responseData['message']);
      }

      if (responseData['data']['status'] == 'Success') {
        //dummy status
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

  Future<InterestStatus?> fetchAndSetInterestStatus(
      int childId, int parentId) async {
    String authToken = await Auth().interceptor();
    final url =
        '${GlobalVariables.apiEndPointChildInterestService}/child-interest-status/$parentId/$childId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      //print("Token: $authToken");
      if (response.statusCode >= 400) {
        notifyListeners();
        throw HttpException('Error in connecting to the service');
      }

      final extractedData = json.decode(response.body);
      // print(extractedData.toString());
      if (extractedData['status'] >= 400) {
        throw Exception(extractedData['message']);
      }
      if (extractedData == null) {
        return null;
      }

      APIResponseMap apiResponse = APIResponseMap.fromJson(extractedData);
      var interestStatus =
          InterestStatus.fromJson(apiResponse.data as Map<String, dynamic>);

      //print(extractedData.toString());
      notifyListeners();
      return interestStatus;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

//HTTP Methods
}
