import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '/src/models/api_response.dart';

import '../../helpers/custom_exceptions.dart';

import '../../src/models/subscription_package.dart';
import '../../helpers/global_variables.dart';
import '../models/parent_subscription.dart';
import 'auth.dart';

/* Implementation Logic:
All subscription related API calls
*/

class Subscriptions with ChangeNotifier {
//Class variables

//Class variables

//Getters

//Getters

//Private methods

//Private methods

//Public methods
  Future<List<SubscriptionPackage>> fetchSubscriptionPackages(
      int parentId) async {
    String authToken = await Auth().interceptor();
    // print(authToken);
    final url =
        '${GlobalVariables.apiEndPointSubscriptionService}/packages/$parentId';

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
        notifyListeners();
        throw HttpException('Error in connecting to the service');
      }

      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        throw HttpException('Error in getting data from server');
      }
      APIResponseMap apiResponse = APIResponseMap.fromJson(extractedData);

      if (apiResponse.data!['status'].toString().trim() != 'Success') {
        throw HttpException('Unable to fetch subscription packages data');
      }

      final List<SubscriptionPackage> loadedPackages = [];
      //TODO::The packagesubscribestatus is coming in the root json,it has to be handled along with
      //Auth data

      for (Map<String, dynamic> dt in apiResponse.data!['packageList']) {
        SubscriptionPackage subscriptionPackage =
            SubscriptionPackage.fromJson(dt);
        loadedPackages.add(subscriptionPackage);
      }

      return loadedPackages;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }

  Future<ParentSubscriptionGroup> listParentSubscription(int parentId) async {
    String authToken = await Auth().interceptor();
    final url =
        '${GlobalVariables.apiEndPointSubscriptionService}/parent-subscriptions/$parentId';

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
      APIResponseMap apiResponse = APIResponseMap.fromJson(extractedData);

      if (apiResponse.message.toString().trim() != 'Success') {
        throw HttpException('Unable to fetch subscription packages data');
      }

      ParentSubscriptionGroup parentSubscriptionGroup =
          ParentSubscriptionGroup.fromJson(apiResponse.data!);

      return parentSubscriptionGroup;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<bool> saveSubscription(
    int parentId,
    int packageId,
    double amount,
    int shopifyCustomerId,
    String subscriptionStatus,
    String packageStatus,
    String transactionDate,
    String? transactionId,
    String? checkSum,
    String? mID,
    String? orderId,
    // LoginResponse loginResponse,
  ) async {
    String authToken = await Auth().interceptor();
    final url =
        '${GlobalVariables.apiEndPointSubscriptionService}/subscription';

    bool retValue = false;
    try {
      final response = await http.post(
        Uri.parse(url),
        //headers: {'Content-Type': 'application/json'},
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          "amount": amount,
          "checkSum": checkSum ?? '',
          "mID": mID ?? '',
          "orderId": orderId ?? '',
          "packageId": packageId,
          "packageStatus": "$packageStatus",
          "parentId": parentId,
          "shopifyCustomerId": shopifyCustomerId,
          "subscriptionStatus": "$subscriptionStatus",
          "transactionDate": "$transactionDate",
          "transactionId": transactionId ?? '' // "$transactionId"
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

      if (apiResponse.message.toString().trim() != 'Success') {
        //throw HttpException('Invalid operation');
        throw HttpException(apiResponse.message!);
      }
      // //updating the package status locally
      // if (loginResponse.currentPackageStatus.toLowerCase() == 'no') {
      //   loginResponse.currentPackageStatus == 'Yes';
      //   await SharedPrefData.setUserDataPref(loginResponse);
      // }

      retValue = true;
      return retValue;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }

  Future<bool> activateSubscription(
    int parentId,
  ) async {
    String authToken = await Auth().interceptor();
    final url =
        '${GlobalVariables.apiEndPointSubscriptionService}/parent-subscriptions/activate/$parentId';

    bool retValue = false;
    try {
      final response = await http.get(
        Uri.parse(url),
        //headers: {'Content-Type': 'application/json'},
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode >= 400) {
        notifyListeners();
        throw HttpException('Error in connecting to the service');
      }

      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        throw HttpException('Error in getting data from server');
      }

      if (extractedData['message'] != 'Success') {
        throw HttpException(extractedData['message']);
      }

      retValue = true;
      return retValue;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }

  Future<bool> packageStatus(int packageId) async {
    String authToken = await Auth().interceptor();
    final url =
        '${GlobalVariables.apiEndPointSubscriptionService}/package-status';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({"packageId": packageId}),
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
      bool packageStatus = extractedData['data']['deletedStatus'] as bool;

      return packageStatus;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<bool> meetingStatus(String mobileNumber) async {
    String authToken = await Auth().interceptor();
    final url =
        '${GlobalVariables.apiEndPointSubscriptionService}/meeting-status';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({"contactnumber": mobileNumber}),
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
          extractedData['data']['enableMeeting'].toString().toLowerCase() ==
                  'yes'
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
