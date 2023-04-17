import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/src/models/api_response.dart';
import '/src/models/child_skill.dart';

import '../../helpers/custom_exceptions.dart';
import '../../helpers/global_variables.dart';
import 'auth.dart';

class ChildSkillEnrichment with ChangeNotifier {
  ChildSkill? _skill;
  String? authToken;

  void update(String? token) {
    this.authToken = token;
  }
  //Getters

  ChildSkill? get skill {
    return _skill;
  }
  //Getters

  //Other Methods

  //Other Methods
  //Http Methods
  Future<void> fetchAndSetSkills(int childId, int parentId) async {
    String authToken = await  Auth().interceptor();
    final url =
        '${GlobalVariables.apiEndPointChildInterestService}/program-suggestions/$parentId/$childId';

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
        throw HttpException('Error in connecting to the service');
      }

      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        return;
      }

      APIResponseMap apiResponse = APIResponseMap.fromJson(extractedData);
      _skill = ChildSkill.fromJson(apiResponse.data as Map<String, dynamic>);

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

  Future<bool> addReview(int userId, ProductReview review) async {
    String authToken = await  Auth().interceptor();
    final url = '${GlobalVariables.apiEndPointProductService}/product/review';

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
          'createdUserId': userId,
          'productId': review.productId,
          'productName': review.productName,
          'programType': review.programType,
          'reviewComment': review.comment,
          'reviewRating': review.rating,
        }),
      );

      final responseData = json.decode(response.body);

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

  //Http Methods

}
