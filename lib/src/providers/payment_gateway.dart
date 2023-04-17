import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '/src/models/api_response.dart';
import '/src/models/checksum_response.dart';
import '/src/models/login_response.dart';
import '../../helpers/custom_exceptions.dart';

import '../../helpers/global_variables.dart';
import 'auth.dart';

/* Implementation Logic:
All subscription related API calls
*/

class PaymentGateway with ChangeNotifier {
//Class variables

//Class variables

//Getters

//Getters

//Private methods

//Private methods

//Public methods
  Future<ChecksumResponse> checksum(
      LoginResponse loginResponse, int packageId) async {
    String authToken = await Auth().interceptor();
    final url =
        '${GlobalVariables.apiEndPointSubscriptionService}/paytm/initiate-transaction';

    try {
      final response = await http.post(Uri.parse(url),
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
          body: json.encode({
            "callBackURL": "${GlobalVariables.paytmCallBackUrl}",
            "channelID": "WAP",
            "email": "${loginResponse.b2cParent!.emailID}",
            "industryTypeID": "${GlobalVariables.paytmIndustryType}",
            "mobileNumber": "${loginResponse.mobileNumber}",
            "packageId": packageId,
            "website": "${GlobalVariables.paytmWebsiteName}"
          }));
      if (response.statusCode >= 400) {
        notifyListeners();
        throw HttpException('Error in connecting to the service');
      }

      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        throw HttpException('Error in getting data from server');
      }
      APIResponseMap apiResponse = APIResponseMap.fromJson(extractedData);

      if (apiResponse.status != 200) {
        throw HttpException('Unable to verify payment');
      }
      var checksumResponse = ChecksumResponse.fromJson(apiResponse.data!);

      return checksumResponse;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }

  //ios verify receipt
  Future<bool> verifyReceipt(String receiptData) async {
    String authToken = await Auth().interceptor();
    final url =
        '${GlobalVariables.apiEndPointSubscriptionService}/verify-receipt';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({"receiptData": receiptData}),
      );
      if (response.statusCode >= 400) {
        notifyListeners();
        throw HttpException('Error in connecting to the service');
      }

      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        throw HttpException('Error in getting data from server');
      }
      if (extractedData['status'] != 200) {
        throw HttpException(extractedData['message']);
      }
      bool meetingStatus =
          extractedData['data']['status'].toString().toLowerCase() == 'success'
              ? true
              : false;

      return meetingStatus;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

//Public methods
}
