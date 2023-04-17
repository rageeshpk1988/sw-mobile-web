import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../helpers/app_info.dart';
import '../../helpers/custom_exceptions.dart';
import '../../helpers/global_variables.dart';
import '../../src/models/fetchkycdata_response.dart';
import '/src/models/api_response.dart';
import '../../src/models/fetchofflinexml_response.dart';
import '../../src/models/getcaptcha_response.dart';
import '../../src/models/kycdoc_response.dart';
import 'package:http/http.dart' as http;

import '../models/onlinekyc_health_check.dart';
import 'auth.dart';

class KycDocument with ChangeNotifier {
  Random random = new Random();

  Future<List<ParentDocumentTypeList>> fetchDocuments() async {
    String authToken = await Auth().interceptor();
    final url =
        '${GlobalVariables.apiEndPointLegacyService}/document-type-by-country';
    PackageInfo _packageInfo = await AppInfo.getPackageInfo();
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'appVersion': _packageInfo.version,
          'countryCode': 'IND',
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
      // print(extractedData.toString());
      APIResponseMap apiResponse = APIResponseMap.fromJson(extractedData);
      /*if (extractedData['status'] != '00') {
        // print('$extractedData');
        throw HttpException('Unable to fetch documents data');
      }*/
      if (apiResponse.data!['status'] != '00') {
        throw HttpException('Unable to fetch documents data');
      }

      final List<ParentDocumentTypeList> loadedDocuments = [];

      //Iterate the response and build the list
      for (Map<String, dynamic> dt
          in apiResponse.data!['parentDocumentTypeList']) {
        //dt.forEach((key, value) => print('$key,$value'));
        ParentDocumentTypeList docName = ParentDocumentTypeList.fromJson(dt);
        loadedDocuments.add(docName);
      }
      //print(loadedDocuments);
      return loadedDocuments;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }

// These are third party apis used for aadhaar online verification

  /* ➔	getCaptcha            :
  <client_code>|<request_id>|<api_key>|<salt>
  ➔	  fetchKYCData     :
  <client_code>|<uuid>|<api_key>|<salt>
*/

  getHealth() async {
    final url = 'https://prod.veri5digital.com/video-id-kyc/_checkUIDAIStatus';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      //  print(response.headers.toString());
      // print(response.body.toString());
      if (response.statusCode >= 400) {
        throw HttpException('Error in connecting to the service');
      }
      if (response.statusCode == 200) {
        //var jsonString = response.body;
        var jsonMap = json.decode(response.body);

        var healthStatus = HealthCheck.fromJson(jsonMap);
        //print(captchaResponseStatus.responseStatus?.message);
        return healthStatus;
      }
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    }
  }

  getCaptchaKyc(String? reqID) async {
    //Salt : hf3hfs9ajsaq
    String clientID = "ZOFT8053";
    String apiKey = "sfhj38hf93zx";
    String saLt = "hf3hfs9ajsaq";
    int dateTime = DateTime.now().millisecondsSinceEpoch;
    final url = '${GlobalVariables.kycOnlineBaseUrl}/getCaptcha';
    //print(reqID);
    var bytes1 = utf8.encode("$clientID|$reqID|$apiKey|$saLt");
    var hash1 = sha256.convert(bytes1);

    // print(hash1);
    // print(bytes1);
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          "headers": {
            "client_code": "ZOFT8053",
            "sub_client_code": "",
            "channel_code": "ANDROID_SDK",
            "channel_version": "3.1.7",
            "stan": "$dateTime",
            "client_ip": "",
            "transmission_datetime": "$dateTime",
            "operation_mode": "SELF",
            "run_mode": "DEFAULT",
            "actor_type": "DEFAULT",
            "user_handle_type": "DEFAULT",
            "user_handle_value": "DEFAULT",
            "location": "",
            "function_code": "DEFAULT",
            "function_sub_code": "DEFAULT"
          },
          "request": {
            "api_key": "sfhj38hf93zx",
            "request_id": "$reqID",
            "hash": "$hash1"
          },
        }),
      );
      // print(response.headers.toString());
      // print(response.body.toString());
      if (response.statusCode >= 400) {
        throw HttpException('Error in connecting to the service');
      }
      if (response.statusCode == 200) {
        //var jsonString = response.body;
        var jsonMap = json.decode(response.body);

        var captchaResponseStatus = GetCaptcha.fromJson(jsonMap);
        //print(captchaResponseStatus.responseStatus?.message);
        return captchaResponseStatus;
      }
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }

  enterAadhaarKyc(
      String? uuID, BuildContext ctx, String? aDd, String? captcha) async {
    //Salt : hf3hfs9ajsaq
    int dateTime = DateTime.now().millisecondsSinceEpoch;
    final url = '${GlobalVariables.kycOnlineBaseUrl}/enterAadhaar';
    // print(aDd);
    // print(captcha);
    // print(uuID);
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          "headers": {
            "client_code": "ZOFT8053",
            "sub_client_code": "",
            "channel_code": "ANDROID_SDK",
            "channel_version": "3.1.7",
            "stan": "$dateTime",
            "client_ip": "",
            "transmission_datetime": "$dateTime",
            "operation_mode": "SELF",
            "run_mode": "DEFAULT",
            "actor_type": "DEFAULT",
            "user_handle_type": "DEFAULT",
            "user_handle_value": "DEFAULT",
            "location": "",
            "function_code": "DEFAULT",
            "function_sub_code": "DEFAULT"
          },
          "request": {
            "uuid": "$uuID",
            "aadhaar": "$aDd",
            "captcha": "$captcha",
            "verification_type": "OTP",
            "consent": "YES"
          },
        }),
      );
      // print(response.headers.toString());
      // print(response.body.toString());
      if (response.statusCode >= 400) {
        throw HttpException('Error in connecting to the service');
      }
      if (response.statusCode == 200) {
        //var jsonString = response.body;
        var jsonMap = json.decode(response.body);

        var captchaResponseStatus = GetCaptcha.fromJson(jsonMap);
        //print(captchaResponseStatus.responseStatus?.message);
        return captchaResponseStatus;
      }
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }

  getNewCaptchaKyc(String? uuID, BuildContext ctx) async {
    int dateTime = DateTime.now().millisecondsSinceEpoch;
    //Salt : hf3hfs9ajsaq
    final url = '${GlobalVariables.kycOnlineBaseUrl}/getNewCaptcha';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          "headers": {
            "client_code": "ZOFT8053",
            "sub_client_code": "",
            "channel_code": "ANDROID_SDK",
            "channel_version": "3.1.7",
            "stan": "$dateTime",
            "client_ip": "",
            "transmission_datetime": "$dateTime",
            "operation_mode": "SELF",
            "run_mode": "DEFAULT",
            "actor_type": "DEFAULT",
            "user_handle_type": "DEFAULT",
            "user_handle_value": "DEFAULT",
            "location": "",
            "function_code": "DEFAULT",
            "function_sub_code": "DEFAULT"
          },
          "request": {"uuid": "$uuID"},
        }),
      );
      // print(response.headers.toString());
      // print(response.body.toString());
      if (response.statusCode >= 400) {
        throw HttpException('Error in connecting to the service');
      }
      if (response.statusCode == 200) {
        //var jsonString = response.body;
        var jsonMap = json.decode(response.body);

        var captchaResponseStatus = GetCaptcha.fromJson(jsonMap);
        //print(captchaResponseStatus.responseStatus?.message);
        return captchaResponseStatus;
      }
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }

  enterOtpKyc(
      String? uuID, BuildContext ctx, String? oTp, String? shareCode) async {
    int dateTime = DateTime.now().millisecondsSinceEpoch;

    final url = '${GlobalVariables.kycOnlineBaseUrl}/enterOtp';

    // print(oTp);
    // print(shareCode);
    // print(uuID);
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          "headers": {
            "client_code": "ZOFT8053",
            "sub_client_code": "",
            "channel_code": "ANDROID_SDK",
            "channel_version": "3.1.7",
            "stan": "$dateTime",
            "client_ip": "",
            "transmission_datetime": "$dateTime",
            "operation_mode": "SELF",
            "run_mode": "DEFAULT",
            "actor_type": "DEFAULT",
            "user_handle_type": "DEFAULT",
            "user_handle_value": "DEFAULT",
            "location": "",
            "function_code": "DEFAULT",
            "function_sub_code": "DEFAULT"
          },
          "request": {
            "uuid": "$uuID",
            "otp": "$oTp",
            "share_code": "$shareCode"
          },
        }),
      );
      // print(response.headers.toString());
      // print(response.body.toString());
      if (response.statusCode >= 400) {
        throw HttpException('Error in connecting to the service');
      }
      if (response.statusCode == 200) {
        //var jsonString = response.body;
        var jsonMap = json.decode(response.body);

        var captchaResponseStatus = GetCaptcha.fromJson(jsonMap);
        //print(captchaResponseStatus.responseStatus?.message);
        return captchaResponseStatus;
      }
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }

  /* ➔	getCaptcha            :
  <client_code>|<request_id>|<api_key>|<salt>
  ➔	  fetchKYCData     :
  <client_code>|<uuid>|<api_key>|<salt>
*/

  fetchKycDataKyc(String? uuID, BuildContext ctx) async {
    int dateTime = DateTime.now().millisecondsSinceEpoch;

    //Salt : hf3hfs9ajsaq
    String clientID = "ZOFT8053";
    String apiKey = "sfhj38hf93zx";
    String saLt = "hf3hfs9ajsaq";

    final url = '${GlobalVariables.kycOnlineBaseUrl}/fetchKYCData';
    /*String captchaimg;
    String uuid;*/
    // var captchaResponseStatus ;
    // print(uuID);
    var bytes1 = utf8.encode("$clientID|$uuID|$apiKey|$saLt");
    var hash1 = sha256.convert(bytes1);

    // print(hash1);
    // print(bytes1);
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          "headers": {
            "client_code": "ZOFT8053",
            "sub_client_code": "",
            "channel_code": "ANDROID_SDK",
            "channel_version": "3.1.7",
            "stan": "$dateTime",
            "client_ip": "",
            "transmission_datetime": "$dateTime",
            "operation_mode": "SELF",
            "run_mode": "DEFAULT",
            "actor_type": "DEFAULT",
            "user_handle_type": "DEFAULT",
            "user_handle_value": "DEFAULT",
            "location": "",
            "function_code": "DEFAULT",
            "function_sub_code": "DEFAULT"
          },
          "request": {
            "api_key": "sfhj38hf93zx",
            "uuid": "$uuID",
            "hash": "$hash1"
          },
        }),
      );
      // print(response.headers.toString());
      // print(response.body.toString());
      if (response.statusCode >= 400) {
        throw HttpException('Error in connecting to the service');
      }
      if (response.statusCode == 200) {
        //var jsonString = response.body;
        var jsonMap = json.decode(response.body);

        var captchaResponseStatus = FetchKycData.fromJson(jsonMap);
        //print(captchaResponseStatus.responseStatus?.message);
        return captchaResponseStatus;
      }
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }

  fetchOfflineXmlKyc(String? uuID, BuildContext ctx) async {
    int dateTime = DateTime.now().millisecondsSinceEpoch;
    //Salt : hf3hfs9ajsaq
    String clientID = "ZOFT8053";
    String apiKey = "sfhj38hf93zx";
    String saLt = "hf3hfs9ajsaq";
    final url = '${GlobalVariables.kycOnlineBaseUrl}/fetchOfflineXML';
    /*String captchaimg;
    String uuid;*/
    // var captchaResponseStatus ;
    //print(uuID);
    var bytes1 = utf8.encode("$clientID|$uuID|$apiKey|$saLt");
    var hash1 = sha256.convert(bytes1);

    // print(hash1);
    // print(bytes1);
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          "headers": {
            "client_code": "ZOFT8053",
            "sub_client_code": "",
            "channel_code": "ANDROID_SDK",
            "channel_version": "3.1.7",
            "stan": "$dateTime",
            "client_ip": "",
            "transmission_datetime": "$dateTime",
            "operation_mode": "SELF",
            "run_mode": "DEFAULT",
            "actor_type": "DEFAULT",
            "user_handle_type": "SYSTEM",
            "user_handle_value": "SYSTEM",
            "location": "",
            "function_code": "DOWNLOAD",
            "function_sub_code": "DELETE"
          },
          "request": {
            "uuid": "$uuID",
            "hash": "$hash1",
            "api_key": "sfhj38hf93zx"
          },
        }),
      );
      // print(response.headers.toString());
      // print(response.body.toString());
      if (response.statusCode >= 400) {
        throw HttpException('Error in connecting to the service');
      }
      if (response.statusCode == 200) {
        //var jsonString = response.body;
        var jsonMap = json.decode(response.body);

        var captchaResponseStatus = FetchOfflineXml.fromJson(jsonMap);
        //print(captchaResponseStatus.responseStatus?.message);
        return captchaResponseStatus;
      }
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }
}
//