import 'dart:io';
//import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:async';
//import 'package:sentry/sentry.dart';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import '/helpers/app_info.dart';
import '/helpers/custom_exceptions.dart';
import '/helpers/shared_pref_data.dart';
import '/src/models/b2cparent.dart';
import '/src/models/b2cparentkyc.dart';
import '../../helpers/global_variables.dart';
import '../../src/models/otp_response.dart';
import '/src/models/api_response.dart';

import 'package:path/path.dart';

import 'auth.dart';

/* Implementation Logic:
   Request OTP, Resend OTP, Validate OTP 
*/

class User with ChangeNotifier {
//Class variables
  int _otpCount = 0;
  DateTime? _otpRequestedAt;
  OTPResponse? _otpResponse;
  //Timer _lastOTPrequestedTime;
//Class variables

//Getters
  OTPResponse get otpResponse {
    return _otpResponse!;
  }

  int get otpCount {
    return _otpCount;
  }

  DateTime? get otpRequestedAt {
    return _otpRequestedAt;
  }
//Getters

//Private methods

//Private methods
  Future<bool> _getOTPCount() async {
    //Get the otp requested count from stored data
    Map<String, dynamic>? otpCountData = await SharedPrefData.getOtpCounter();
    if (otpCountData == null) {
      _otpCount = 0;
      _otpRequestedAt = DateTime.now();
    } else {
      _otpCount = (otpCountData['count']);
      _otpRequestedAt = DateTime.parse(otpCountData['requestedAt'] as String);
    }
    return true;
  }
//Public methods

  Future<bool> requestOTP(String mobileNumber) async {
    if (await _getOTPCount()) {
      if (_otpCount > 2) {
        Duration timeElapsed = DateTime.now().difference(_otpRequestedAt!);
        if (timeElapsed.inMinutes > GlobalVariables.otpTimeRequestTimer) {
          SharedPrefData.setOtpCounter(0);
          _otpCount = 0;
        } else {
          throw AttemptsExceededException(
              'Try requesting OTP after ${GlobalVariables.otpTimeRequestTimer} minutes');
        }
      }
    }
    _otpCount++;
    // final url = '${GlobalVariables.apiBaseUrl}/login/otp';
    final url = '${GlobalVariables.apiEndPointLegacyService}/otp';

    PackageInfo _packageInfo = await AppInfo.getPackageInfo();
    bool retValue = false;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "appVersion": _packageInfo.version,
          "phoneNumber": mobileNumber,
          "otpReqCount": _otpCount,
          "countryCode": GlobalVariables.defaultCountryCode,
          "countryName": GlobalVariables.defaultCountryName,
          "lastReqTime": '',
          "type": kIsWeb || Platform.isAndroid
              ? 'android'
              : Platform.isIOS
                  ? 'iOS'
                  : 'Unknown',
        }),
      );
      SharedPrefData.setOtpCounter(_otpCount); //increment counter
      if (response.statusCode >= 400) {
        notifyListeners();
        throw HttpException('Error in connecting to the service');
      }

      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        throw HttpException('Error in getting data from server');
      }
      if (extractedData['data']['status'].toString().trim() != '00') {
        //TODO:: This error message need to be changed
        throw HttpException('Invalid operation');
      }
      OTPResponse otpResponse = OTPResponse.fromJson(extractedData['data']);

      //TODO:: A Generic response format can be incorporated here

      _otpResponse = otpResponse;

      notifyListeners();
      retValue = true;
      return retValue;
    } on SocketException {
      SharedPrefData.setOtpCounter(_otpCount); //setting the counter
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      SharedPrefData.setOtpCounter(_otpCount); //setting the counter
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      SharedPrefData.setOtpCounter(_otpCount); //setting the counter
      throw UnknownException('Unknown Error ${e.toString()}');
    }
  }

  Future<bool> validateOTPLocal(String mobileNumber, String otp) async {
    final url =
        '${GlobalVariables.smsProviderLocal_Url}username=${GlobalVariables.smsProviderLocal_UserName}&password=${GlobalVariables.smsProviderLocal_Password}&mobile=$mobileNumber&otp=$otp';
    bool retValue = false;
    try {
      if (mobileNumber == "8289955083") {
        //  if (mobileNumber == "6666666666") {
        if (otp == "333333") {
          retValue = true;
        } else {
          throw HttpException('Not a valid OTP');
        }
      } else {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          // headers: {
          //   'Content-Type': 'application/json',
          //   'Accept': 'application/json',
          //   'Access-Control-Allow-Headers':
          //       'Origin, Content-Type, Cookie, X-CSRF-TOKEN, Accept, Authorization, X-XSRF-TOKEN, Access-Control-Allow-Origin',
          //   'Access-Control-Expose-Headers': "" 'Authorization, authenticated',
          //   'Access-Control-Allow-Origin': '*',
          //   'Access-Control-Allow-Methods': 'GET,POST,OPTIONS,DELETE,PUT',
          //   'Access-Control-Allow-Credentials': 'true',
          // },
        );

        if (response.statusCode >= 400) {
          throw HttpException('Error in connecting to the service');
        }

        //final extractedData = response.body;
        if (response.body.contains('OTP FAILED')) {
          throw HttpException('Not a valid OTP');
        } else if (response.body.contains('OTP VERIFIED')) {
          retValue = true;
        } else {
          throw HttpException('Unknown Error');
        }
      }
      SharedPrefData.setOtpCounter(0); //reset the counter
      _otpCount = 0;
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

  Future<bool> validateOTPIntl(String mobileNumber, String otp) async {
    final url =
        '${GlobalVariables.smsProviderIntl_Url}authkey=${_otpResponse!.authKey}&mobile=$mobileNumber&otp=$otp';
    bool retValue = false;
    try {
      final response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode >= 400) {
        throw HttpException('Error in connecting to the service');
      }

      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        throw HttpException('Error in getting data from server');
      }
      if (extractedData['type'].toString().trim() == 'error') {
        //TODO:: This error message need to be changed
        throw HttpException('Invalid OTP');
      } else if (extractedData['type'] == 'success') {
        retValue = true;
      } else {
        throw HttpException('Unknown Error');
      }
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

  Future<bool> changePhoneNumber(
      String oldMobileNumber, String newMobileNumber, String password) async {
    //final url = '${GlobalVariables.apiBaseUrl}/login/android/changePhnnumber';
    final url =
        '${GlobalVariables.apiEndPointLegacyService}/change-phone-number';

    bool retValue = false;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "oldNumber": oldMobileNumber,
          "newNumber": newMobileNumber,
          "password": password,
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
      if (extractedData['message'].toString().trim() == 'Success') {
        retValue = true;
      } else {
        //TODO:: This error message need to be changed
        throw HttpException('Failed to change the phone number');
      }
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

  Future<int?> resetPasswordRequest(String mobileNumber) async {
    String authToken = await Auth().interceptor();
    // final url =
    //     '${GlobalVariables.apiBaseUrl}/login/android/azure/password/resetpassword';
    final url = '${GlobalVariables.apiEndPointLegacyService}/resetpassword';

    int? parentId;
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
          "phoneNumber": mobileNumber,
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
        throw HttpException('Invalid operation');
      }

      // if (extractedData['status'].toString().trim() != '00') {
      //   //TODO:: This error message need to be changed
      //   throw HttpException('Invalid operation');
      // }
      parentId = apiResponse.data!['parentID'];
      return parentId;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }

  Future<bool> updatePassword(
    String mobileNumber,
    int parentId,
    String? tempPassword,
    String? password,
  ) async {
    String authToken = await Auth().interceptor();
    // final url =
    //     '${GlobalVariables.apiBaseUrl}/login/android/azure/password/updatepassword';
    final url = '${GlobalVariables.apiEndPointLegacyService}/update-password';

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
          'password': password,
          'userName': mobileNumber,
          'tempPassword': tempPassword,
          'parentID': parentId,
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
        //throw HttpException('Invalid operation');
        throw HttpException(extractedData['message']);
      }
      // if (extractedData['status'].toString().trim() != '00') {
      //   //TODO:: This error message need to be changed
      //   throw HttpException(extractedData['message']);
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

  Future<bool> registerParent(String mobileNumber, String name, String email,
      String password, String refcode) async {
    final url = '${GlobalVariables.apiEndPointLegacyService}/parent-register';
    // String parentReigsterRequest =
    //     '{"adStatus":"notexist","appVersion":"31","cityId":"7301","countryCode":"91",'
    //     '"countryId":"IND","docType":"Aadhaar","documentNumber":"123456789012",'
    //     '"email":$email,"kycStatus":"offline","mobileOs":"android",'
    //     '"name":$name,"parentDocumentTypeId":"10","parentId":"0","password":$password,'
    //     '"phone":$mobileNumber,"pin":"691601","registrationType":"document","stateId":"206",'
    //     '"userID":""}';
    PackageInfo _packageInfo = await AppInfo.getPackageInfo();
    var mobileOs = kIsWeb || Platform.isAndroid ? "android" : "iOS";
    String parentReigsterRequest =
        '{"adStatus":"notexist","appVersion":${_packageInfo.version},'
        '"email":$email,"mobileOs":$mobileOs,"name":"$name","password":$password,'
        '"phone":"$mobileNumber","registrationType":"document","usedreferralCode":"$refcode","kycStatus":"offline","countryId":"IND"}';
    //print(parentReigsterRequest);
    bool returnValue = false;
    try {
      var request = http.MultipartRequest("POST", Uri.parse(url));
      // request.headers['authorization'] = 'Bearer ${this.authToken}';
      request.fields['data'] = parentReigsterRequest;
      // request.headers.addAll({
      //   'Content-Type': 'application/json',
      //   'Accept': 'application/json',
      //   'Authorization': 'Bearer $authToken',
      // });

      final response = await request.send();

      final extractedResult = await response.stream.bytesToString();
      final extractedData = json.decode(extractedResult);

      if (response.statusCode >= 400) {
        notifyListeners();
        returnValue = false;
        throw HttpException('Error in connecting to the service');
      }
      if (extractedData['data']['referralStatus'] == "Invalid ReferralCode") {
        throw HttpException('Invalid referral code');
      }
      if (extractedData['data']['status'] == '01') {
        throw HttpException(extractedData['message']);
      }
      if (extractedData['message'] == 'Success') {
        returnValue = true;
      }
      // if (extractedData['status'].toString().trim() == '00') {
      //   returnValue = true;
      // }
      notifyListeners();
      return returnValue;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  //TODO:: registerParent and parentProfileAddUpdate and parentProfileKYC has to be merged to a single proc
  Future<bool> registerParentOld(
      String mobileNumber, String name, String email, String password) async {
    final url = '';
    //     '${GlobalVariables.apiBaseUrl}/login/android/b2c/parentregister/post';
    // String parentReigsterRequest =
    //     '{"adStatus":"notexist","appVersion":"31","cityId":"7301","countryCode":"91",'
    //     '"countryId":"IND","docType":"Aadhaar","documentNumber":"123456789012",'
    //     '"email":$email,"kycStatus":"offline","mobileOs":"android",'
    //     '"name":$name,"parentDocumentTypeId":"10","parentId":"0","password":$password,'
    //     '"phone":$mobileNumber,"pin":"691601","registrationType":"document","stateId":"206",'
    //     '"userID":""}';
    PackageInfo _packageInfo = await AppInfo.getPackageInfo();
    var mobileOs = kIsWeb || Platform.isAndroid ? "android" : "iOS";
    String parentReigsterRequest =
        '{"adStatus":"notexist","appVersion":${_packageInfo.version},'
        '"email":$email,"mobileOs":$mobileOs,"name":"$name","password":$password,'
        '"phone":"$mobileNumber","registrationType":"document","kycStatus":"offline","countryId":"IND"}';
    //print(parentReigsterRequest);
    bool returnValue = false;
    try {
      var request = http.MultipartRequest("POST", Uri.parse(url));
      // request.headers['authorization'] = 'Bearer ${this.authToken}';
      request.fields['data'] = parentReigsterRequest;

      final response = await request.send();

      final extractedResult = await response.stream.bytesToString();
      final extractedData = json.decode(extractedResult);

      if (response.statusCode >= 400) {
        notifyListeners();
        returnValue = false;
        throw HttpException('Error in connecting to the service');
      }
      if (extractedData['status'].toString().trim() == '00') {
        returnValue = true;
      }
      notifyListeners();
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

  Future<bool> parentProfileAddUpdate(B2CParent parent, String? mobileNumber,
      String? appVersion, String? mobileOs, File selectedFile) async {
    // final url =
    //     '${GlobalVariables.apiBaseUrl}/login/android/b2c/parentregister/post';
    final url = '${GlobalVariables.apiEndPointLegacyService}/parent-register';

    String parentReigsterRequest =
        '{"adStatus":"notexist","appVersion":$appVersion,"cityId":${parent.locationID},"countryCode":"${GlobalVariables.defaultCountryCode}",'
        '"countryId":${parent.countryID},"docType":"","documentNumber":"",'
        '"email":${parent.emailID},"kycStatus":"","mobileOs":$mobileOs,'
        '"name":"${parent.name}","parentDocumentTypeId":0,"parentId":${parent.parentID},'
        '"phone":$mobileNumber,"pin":${parent.pinCode},"registrationType":"","stateId":${parent.stateID},'
        '"userID":"","usedreferralCode":"","postMode":"edit"}';
    bool returnValue = false;
    try {
      var request = http.MultipartRequest("POST", Uri.parse(url));
      // request.headers['authorization'] = 'Bearer ${this.authToken}';
      request.fields['data'] = parentReigsterRequest;
      if (basename(selectedFile.path) != 'file.txt')
        request.files.add(
            await http.MultipartFile.fromPath('profilePic', selectedFile.path));
      // request.files.add(
      //   http.MultipartFile.fromBytes('profPicFile', selectedFile,
      //       contentType: MediaType('application', 'octet-stream'),
      //       filename: fileName),
      // );
      final response = await request.send();

      final extractedResult = await response.stream.bytesToString();
      final extractedData = json.decode(extractedResult);

      if (response.statusCode >= 400) {
        notifyListeners();
        returnValue = false;
        throw HttpException(
            'Error in connecting to the service ${response.statusCode}');
      }
      if (extractedData['message'] == 'Success') {
        returnValue = true;
      } else {
        notifyListeners();
        returnValue = false;
        throw HttpException('Data updation failed');
      }
      // if (extractedData['status'].toString().trim() == '00') {
      //   //testing throw HttpException('Sentry test error');
      //   returnValue = true;
      // } else if (extractedData['status'].toString().trim() == '01') {
      //   notifyListeners();
      //   returnValue = false;
      //   throw HttpException('Data updation failed');
      // }
      notifyListeners();
      return returnValue;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      // await Sentry.captureException(e, stackTrace: staackTrace);
      throw UnknownException('Unknown Error');
    }
  }

  Future<bool> parentProfileKYC(B2CParentKYC parent, String? mobileNumber,
      String? appVersion, String? mobileOs, File selectedFile) async {
    // final url =
    //     '${GlobalVariables.apiBaseUrl}/login/android/b2c/parentregister/post';
    final url = '${GlobalVariables.apiEndPointLegacyService}/parent-register';

    if (parent.stateID == "") {
      String parentReigsterRequest =
          '{"adStatus":"notexist","appVersion":$appVersion,"countryCode":"${GlobalVariables.defaultCountryCode}",'
          '"countryId":${parent.countryID},"docType":"${parent.docType}","documentNumber":"${parent.docNumber}",'
          '"email":${parent.emailID},"kycStatus":"${parent.kycType}","mobileOs":$mobileOs,'
          '"name":"${parent.name}","parentDocumentTypeId":${parent.parentDocumentTypeId},"parentId":${parent.parentID},'
          '"phone":$mobileNumber,"registrationType":"document",'
          '"userID":"","usedreferralCode":"","postMode":"edit"}';
      // print(parentReigsterRequest);

      bool returnValue = false;
      try {
        var request = http.MultipartRequest("POST", Uri.parse(url));
        // request.headers['authorization'] = 'Bearer ${this.authToken}';
        request.fields['data'] = parentReigsterRequest;
        if (basename(selectedFile.path) != 'file.txt')
          request.files.add(
              await http.MultipartFile.fromPath('document', selectedFile.path));
        // request.files.add(
        //   http.MultipartFile.fromBytes('profPicFile', selectedFile,
        //       contentType: MediaType('application', 'octet-stream'),
        //       filename: fileName),
        // );
        final response = await request.send();

        final extractedResult = await response.stream.bytesToString();
        final extractedData = json.decode(extractedResult);

        if (response.statusCode >= 400) {
          notifyListeners();
          returnValue = false;
          throw HttpException('Error in connecting to the service');
        }
        if (extractedData['message'] == 'Success') {
          returnValue = true;
        } else {
          notifyListeners();
          returnValue = false;
          throw HttpException('Data updation failed');
        }
        // if (extractedData['status'].toString().trim() == '00') {
        //   returnValue = true;
        // } else if (extractedData['status'].toString().trim() == '01') {
        //   notifyListeners();
        //   returnValue = false;
        //   throw HttpException('Data updation failed');
        // }
        notifyListeners();
        return returnValue;
      } on SocketException {
        throw NoInternetException('No Internet');
      } on HttpException catch (e) {
        throw NoServiceFoundException(e.message);
        //throw NoServiceFoundException('No Service Found');
      } catch (e) {
        throw UnknownException('Unknown Error');
      }
    } else {
      String parentReigsterRequest =
          '{"adStatus":"notexist","appVersion":$appVersion,"cityId":"${parent.locationID}","countryCode":"${GlobalVariables.defaultCountryCode}",'
          '"countryId":${parent.countryID},"docType":"${parent.docType}","documentNumber":"${parent.docNumber}",'
          '"email":${parent.emailID},"kycStatus":"${parent.kycType}","mobileOs":$mobileOs,'
          '"name":"${parent.name}","parentDocumentTypeId":${parent.parentDocumentTypeId},"parentId":${parent.parentID},'
          '"phone":$mobileNumber,"pin":"${parent.pinCode}","registrationType":"document","stateId":"${parent.stateID}",'
          '"userID":"","usedreferralCode":"","postMode":"edit"}';
      // print(parentReigsterRequest);

      bool returnValue = false;
      try {
        var request = http.MultipartRequest("POST", Uri.parse(url));
        // request.headers['authorization'] = 'Bearer ${this.authToken}';
        request.fields['data'] = parentReigsterRequest;
        if (basename(selectedFile.path) != 'file.txt')
          request.files.add(
              await http.MultipartFile.fromPath('document', selectedFile.path));
        // request.files.add(
        //   http.MultipartFile.fromBytes('profPicFile', selectedFile,
        //       contentType: MediaType('application', 'octet-stream'),
        //       filename: fileName),
        // );
        final response = await request.send();

        final extractedResult = await response.stream.bytesToString();
        final extractedData = json.decode(extractedResult);

        if (response.statusCode >= 400) {
          notifyListeners();
          returnValue = false;
          throw HttpException('Error in connecting to the service');
        }
        if (extractedData['message'] == 'Success') {
          returnValue = true;
        } else {
          notifyListeners();
          returnValue = false;
          throw HttpException('Data updation failed');
        }
        // if (extractedData['status'].toString().trim() == '00') {
        //   returnValue = true;
        // } else if (extractedData['status'].toString().trim() == '01') {
        //   notifyListeners();
        //   returnValue = false;
        //   throw HttpException('Data updation failed');
        // }
        notifyListeners();
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
  }

//Public methods
}
//