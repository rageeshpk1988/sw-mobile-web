import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '/src/models/referral.dart';
import '/src/models/api_response.dart';
import '../../helpers/custom_exceptions.dart';

import '../../helpers/global_variables.dart';
import 'auth.dart';

class ReferralDetail with ChangeNotifier {
//Class variables

//Class variables

//Getters

//Getters

//Private methods

//Private methods

//Public methods
  Future<Referral?> fetchReferralCode(int parentId) async {
    String authToken = await Auth().interceptor();
    final url =
        '${GlobalVariables.apiEndPointReferralService}/referral-count/$parentId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      // print("Token: $authToken");
      if (response.statusCode >= 400) {
        notifyListeners();
        throw HttpException('Error in connecting to the service');
      }

      final extractedData = json.decode(response.body);
      //print(extractedData.toString());
      if (extractedData['status'] >= 400) {
        throw Exception(extractedData['message']);
      }
      if (extractedData == null) {
        return null;
      }

      APIResponseMap apiResponse = APIResponseMap.fromJson(extractedData);
      var referralDetails =
          Referral.fromJson(apiResponse.data as Map<String, dynamic>);

      //  print(extractedData.toString());
      notifyListeners();
      return referralDetails;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException("An Error Occurred");
    }
  }
//Public methods
}
