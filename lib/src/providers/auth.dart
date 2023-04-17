import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/api_response.dart';
import '../models/child.dart';
import '/src/models/socialaccesstoken_response.dart';
import '/helpers/custom_exceptions.dart';
import '../../helpers/app_info.dart';
import '../../helpers/shared_pref_data.dart';
import '../../src/models/ad_response.dart';
import '../../src/models/login_request.dart';
import '../../src/models/login_response.dart';
import '../../helpers/global_variables.dart';

/* Implementation Logic:
    -If authenticated agaist JWT token and the last authentication date (both stored in Shared Pref) is not the same 
      then call _authenticateMobileNumber() again to check the build version
    -If Not authenticated then in the login() , we call _authenticateMobileNumber() followed by
      _authenticateADLogin() and
      JWT token along with date of last authentication will be stored in shared preferences 
      Authenticated response will be stored in SQLite DB.
*/

class Auth with ChangeNotifier {
//Class variables
  LoginResponse? _loginResponse;
  ADResponse? _adResponse;
  SocialAdResponse? _socialAccessTokenResponse;
  int? _kycStatus;
  Child? _child;

//Class variables

//Getters
  //Checking whether a valid token is available or not
  bool get isAuth {
    if (_loginResponse == null) return false;

    bool authenticated = _loginResponse!.status == 'Success';

    //if authenticated and the date of authentication is on the same day  then need not call
    //_authenticateMobileNumber()  else call _authenticateMobileNumber()

    return authenticated;
  }

  LoginResponse get loginResponse {
    return _loginResponse!;
  }

  ADResponse? get adResponse {
    return _adResponse;
  }

  SocialAdResponse? get socialAccessTokenResponse {
    return _socialAccessTokenResponse;
  }

  int? get kycResponse {
    //return 1; //TODO:: only for testing
    return _kycStatus;
  }

  //new getter for retrieving current child
  Child? get currentChild {
    return _child;
  }

//Getters

//Private methods
  void setInitialChild() {
    if (loginResponse.b2cParent?.childDetails != null) {
      if (loginResponse.b2cParent!.childDetails!.length > 0) {
        _child = _loginResponse?.b2cParent?.childDetails?[0];
        notifyListeners();
      }
    }
  }

  Future<String> interceptor() async {
    _loginResponse = await SharedPrefData.getUserDataPref();
    if (_loginResponse?.tokenExpiry != null &&
        _loginResponse!.tokenExpiry!.isAfter(DateTime.now())) {
      return _loginResponse!.token;
    } else {
      bool inserted = await _updateToken();
      if (inserted == true) {
        return _loginResponse!.token;
      } else {
        return _loginResponse!.token;
      }
    }
  }

  void updateChild(Child? child) {
    _child = child;
    notifyListeners();
  }

  //this is from microservice
  Future<bool> _updateToken() async {
    final url = '${GlobalVariables.apiEndpointLoginService}/refresh-token';
    bool retValue = false;
    try {
      final response = await http.post(Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({"token": _loginResponse!.token}));
      if (response.statusCode >= 400) {
        notifyListeners();
        throw HttpException('Error in connecting to Service');
      }

      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        throw HttpException('Error in getting data from server');
      }
      if (extractedData['status'] < 200 || extractedData['status'] > 299) {
        //throw HttpException('Invalid login credentials');
        notifyListeners();
        return retValue;
      }
      APIResponseMap apiResponse = APIResponseMap.fromJson(extractedData);
      LoginResponse loginResponseNew = loginResponse;
      loginResponseNew.tokenExpiry = DateTime.now().add(Duration(minutes: 50));
      loginResponseNew.token = apiResponse.data!['token'];

      SharedPrefData.setUserDataPref(loginResponseNew);
      _loginResponse = loginResponseNew;
      notifyListeners();
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

  Future<bool> _authenticateMobileNumber(LoginRequest loginRequest) async {
    final url = '${GlobalVariables.apiEndpointLoginService}/license';
    bool retValue = false;
    try {
      final response = await http.post(
        Uri.parse(url),
        // headers: {
        //   // "Accept": "application/json",
        //   "content-type": "application/json"
        // },

        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Access-Control-Allow-Headers':
              'Origin, Content-Type, Cookie, X-CSRF-TOKEN, Accept, Authorization, X-XSRF-TOKEN, Access-Control-Allow-Origin',
          'Access-Control-Expose-Headers': "" 'Authorization, authenticated',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET,POST,OPTIONS,DELETE,PUT',
          'Access-Control-Allow-Credentials': 'true',
        },
        body: json.encode({
          "buildVersion": loginRequest.buildVersion,
          "appVersion": loginRequest.appVersion,
          "phoneNumber": loginRequest.phoneNumber,
          "apiVersion": loginRequest.apiVersion,
          "type": loginRequest.type,
          "downloadStatus": loginRequest.downloadStatus,
          "fcmTocken": loginRequest.fcmTocken ?? null,
          "mobileOs": loginRequest.mobileOS
        }),
      );
      if (response.statusCode >= 400) {
        notifyListeners();
        throw HttpException('Error in connecting to Service');
      }

      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        throw HttpException('Error in getting data from server');
      }
      if (extractedData['status'] < 200 || extractedData['status'] > 299) {
        //throw HttpException('Invalid login credentials');
        notifyListeners();
        return retValue;
      }
      APIResponseMap apiResponse = APIResponseMap.fromJson(extractedData);

      LoginResponse loginResponse =
          LoginResponse.fromJson(apiResponse.data!, loginRequest.phoneNumber);

      //TODO:: A Generic response format can be incorporated here

      //_autoLogout(); // Setting the timer for logout once the JWT is in place

      //TODO:: Shared preference storage  store JWT and current date.

      // final prefs = await SharedPreferences.getInstance();
      // prefs.remove('userData');
      // // prefs.clear();

      // final userData = json.encode(loginResponse);
      // prefs.setString('userData', userData);
      loginResponse.tokenExpiry = DateTime.now().add(Duration(minutes: 50));
      SharedPrefData.setUserDataPref(loginResponse);
      _loginResponse = loginResponse;
      if (_kycStatus != 1) {
        await getApproveStatusKyc(loginResponse.b2cParent!.parentID);
      }

      // //Subscribe firestore Notification topic
      // await FirebaseMessaging.instance.subscribeToTopic('vendor_post');

      // _saveDataLocal();
      notifyListeners();
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

  //todo:: to be deleted
  // Future<bool> _authenticateMobileNumber_old(LoginRequest loginRequest) async {
  //   final url = '${GlobalVariables.apiBaseUrl}/login/android/license';
  //   bool retValue = false;
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({
  //         "buildVersion": loginRequest.buildVersion,
  //         "appVersion": loginRequest.appVersion,
  //         "phoneNumber": loginRequest.phoneNumber,
  //         "apiVersion": loginRequest.apiVersion,
  //         "type": loginRequest.type,
  //         "downloadStatus": loginRequest.downloadStatus,
  //         "fcmTocken": loginRequest.fcmTocken ?? null,
  //         "mobileOs": loginRequest.mobileOS
  //       }),
  //     );
  //     if (response.statusCode >= 400) {
  //       notifyListeners();
  //       throw HttpException('Error in connecting to Service');
  //     }

  //     final extractedData = json.decode(response.body);
  //     if (extractedData == null) {
  //       throw HttpException('Error in getting data from server');
  //     }
  //     if (extractedData['status'].toString().trim() == 'Inavlid User') {
  //       //throw HttpException('Invalid login credentials');
  //       notifyListeners();
  //       return retValue;
  //     }
  //     LoginResponse loginResponse =
  //         LoginResponse.fromJson(extractedData, loginRequest.phoneNumber);

  //     //TODO:: A Generic response format can be incorporated here

  //     //_autoLogout(); // Setting the timer for logout once the JWT is in place

  //     //TODO:: Shared preference storage  store JWT and current date.

  //     // final prefs = await SharedPreferences.getInstance();
  //     // prefs.remove('userData');
  //     // // prefs.clear();

  //     // final userData = json.encode(loginResponse);
  //     // prefs.setString('userData', userData);
  //     SharedPrefData.setUserDataPref(loginResponse);
  //     _loginResponse = loginResponse;
  //     if (_kycStatus != 1) {
  //       await getApproveStatusKyc(loginResponse.b2cParent!.parentID);
  //     }

  //     // //Subscribe firestore Notification topic
  //     // await FirebaseMessaging.instance.subscribeToTopic('vendor_post');

  //     // _saveDataLocal();
  //     //notifyListeners();
  //     retValue = true;
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

  Future<bool> _authenticateADLogin(
      String mobileNumber, String password) async {
    final url = '${GlobalVariables.loginAD_Url}';
    bool retValue = false;
    try {
      Map<String, dynamic> formMap = {
        'grant_type': GlobalVariables.loginAD_GrantType,
        'client_id': GlobalVariables.loginAD_ClientId,
        'client_secret': GlobalVariables.loginAD_ClientSecret,
        'username': mobileNumber,
        'password': password,
      };
      String encodedBody =
          formMap.keys.map((key) => "$key=${formMap[key]}").join("&");

      var response = await http.post(
        Uri.parse(url),
        body: encodedBody,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        encoding: Encoding.getByName("utf-8"),
      );
      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        throw HttpException('Error in getting data from server');
      }
      if (response.statusCode >= 400) {
        retValue = false;
        notifyListeners();
        if (extractedData['status'].toString().trim() == 'FAILED') {
          throw HttpException(extractedData['message']);
        } else {
          throw HttpException('Error in connecting to the service');
        }
      }

      if (extractedData['status'].toString().trim() != 'SUCCESS') {
        retValue = false;
      }
      ADResponse adResponse = ADResponse.fromJson(extractedData);
      // final prefs = await SharedPreferences.getInstance();
      // prefs.remove('userADData');
      // // prefs.clear();

      // final userADData = json.encode(adResponse);
      // prefs.setString('userADData', userADData);
      _adResponse = adResponse;
      SharedPrefData.setUserAdDDatPref(adResponse);

      notifyListeners();
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

  Future<bool> _authenticateADLoginSocial(
      String appName, String socialAccessToken) async {
    final url =
        'https://store.xecurify.com/moas/rest/shopify/mobilelogin?shopname=${GlobalVariables.shopify_SocialLoginDomain}&appname=$appName&action=token&access_token=$socialAccessToken';
    //print(url);
    bool retValue = false;
    try {
      /*String encodedBody =
      formMap.keys.map((key) => "$key=${formMap[key]}").join("&");*/

      var response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        throw HttpException('Error in getting data from server');
      }
      if (response.statusCode >= 400) {
        retValue = false;
        notifyListeners();
        if (extractedData['status'].toString().trim() == 'fail') {
          throw HttpException(extractedData['message']);
        } else {
          throw HttpException('Error in connecting to the service');
        }
      }

      if (extractedData['status'].toString().trim() != 'success') {
        // print("going inside not success");
        retValue = false;
      }
      SocialAdResponse adResponse = SocialAdResponse.fromJson(extractedData);
      // final prefs = await SharedPreferences.getInstance();
      // prefs.remove('userADData');
      // // prefs.clear();

      // final userADData = json.encode(adResponse);
      // prefs.setString('userADData', userADData);

      _socialAccessTokenResponse = adResponse;
      SharedPrefData.setUserSocialAdDDatPref(adResponse);

      notifyListeners();
      retValue = true;
      return retValue;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException('$e');
    }
  }

  //TODO:: THIS NEEDS TO BE ENABLED AT LATER POINT OF TIME
  // Future<void> _saveDataLocal() async {
  //   try {
  //     Map<String, dynamic> row = _loginResponse!.toJson();
  //     row.forEach((key, value) {
  //       DBHelper.insert(DBHelper.tableUserData, {'key': key, 'value': value});
  //     });
  //   } catch (error) {
  //     throw error;
  //   }
  // }

  Future<LoginRequest> _setLoginRequest(String mobileNumber) async {
    PackageInfo _packageInfo = await AppInfo.getPackageInfo();

    // String? fcmToken = await FirebaseMessaging.instance.getToken();

    LoginRequest loginRequest = LoginRequest(
      buildVersion: _packageInfo.buildNumber,
      appVersion: _packageInfo.version,
      phoneNumber: mobileNumber,
      apiVersion: '1.0',
      // mobileOS: Platform.isIOS
      //     ? 'iOS'
      //     : Platform.isAndroid
      //         ? 'android'
      //         : 'Unknown',
      mobileOS: kIsWeb
          ? 'unknown'
          : Platform.isIOS
              ? 'iOS'
              : Platform.isAndroid
                  ? 'android'
                  : 'Unknown',
      type: '',
      downloadStatus: '',
      //fcmTocken: fcmToken,
    );
    return loginRequest;
  }

//Private methods

//Public methods
  Future<void> loginAD(String mobileNumber, String password) async {
    if (isAuth) {
      //call AD login
      await _authenticateADLogin(mobileNumber, password);
    } else {
      LoginRequest loginRequest = await _setLoginRequest(mobileNumber);
      var mobileAuthenticated = await _authenticateMobileNumber(loginRequest);
      if (mobileAuthenticated) {
        await _authenticateADLogin(mobileNumber, password);
      }
    }
  }

  Future<void> loginADSocial(
      String socialAccessToken, String mobileNumber, String appName) async {
    if (isAuth) {
      //call AD login
      await _authenticateADLoginSocial(appName, socialAccessToken);
    } else {
      LoginRequest loginRequest = await _setLoginRequest(mobileNumber);
      var mobileAuthenticated = await _authenticateMobileNumber(loginRequest);
      if (mobileAuthenticated) {
        await _authenticateADLoginSocial(appName, socialAccessToken);
      }
    }
  }

  Future<bool> validateMobileNumber(String mobileNumber,
      [bool generateFcmToken = false]) async {
    LoginRequest loginRequest = await _setLoginRequest(mobileNumber);

    //FCM TOKEN
    if (generateFcmToken) {
      loginRequest.fcmTocken = await FirebaseMessaging.instance.getToken();
    }
    bool retValue = await _authenticateMobileNumber(loginRequest);
    //return await _authenticateMobileNumber(loginRequest);
    if (!kIsWeb) {
      if (generateFcmToken) {
        // //Subscribe firestore Notification topic
        await FirebaseMessaging.instance.subscribeToTopic('vendor_post');
      }
    }
    return retValue;
  }

//Read the Shared preference
  Future<bool> tryAutoLogin() async {
    _loginResponse = await SharedPrefData.getUserDataPref();
    if (_loginResponse == null) return false;

    _adResponse = await SharedPrefData.getUserADDataPref();
    _socialAccessTokenResponse = await SharedPrefData.getUserSocialADDataPref();
    _kycStatus = await SharedPrefData.getUserKycStatus();

    // fetchAndSetUserData();
    // if (_loginResponse == null) return false;
    notifyListeners();
    //_autoLogout(); setting the timer for logout once the JWT is in place
    return true;
  }

  //kyc status receiving function
  Future<bool> getApproveStatusKyc(int parentID) async {
    String authToken = await interceptor();
    final url =
        '${GlobalVariables.apiEndPointLegacyService}/parent-approval-status';
    int? approveStatus;
    PackageInfo _packageInfo = await AppInfo.getPackageInfo();
    bool retValue = false;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          "appVersion": _packageInfo.version,
          "parentId": parentID,
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
      if (apiResponse.data!['status'] != '00') {
        //TODO:: This error message need to be changed
        throw HttpException('Invalid operation');
      }
      approveStatus = apiResponse.data!['approvalstatus'];
      _kycStatus = approveStatus;
      SharedPrefData.setUserKycStatus(approveStatus);

      // //Subscribe firestore Notification topic
      // await FirebaseMessaging.instance.subscribeToTopic('vendor_post');

      // _saveDataLocal();
      notifyListeners();
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

  Future<bool> logout() async {
    _loginResponse = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    //prefs.remove('userData');
    prefs.clear();
    return true;
  }

  Future<bool> deleteAccount(int parentId,String phoneNumber) async {
    String authToken = await  Auth().interceptor();
    final url =
        '${GlobalVariables.apiEndpointParentService}/parents/delete-parent/$parentId/$phoneNumber';

    bool returnValue = true;
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      final responseData = json.decode(response.body);
      print(responseData.toString());
      if (response.statusCode >= 400) {
        returnValue = false;
        throw HttpException('Error in connecting to the service');
      }
      if (responseData['status'] >= 400) {
        returnValue = false;
        throw Exception(responseData['message']);
      }

      if (responseData['message'] == 'Success') {
        //await logout();
        //dummy status
        returnValue = true;
      } else {
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

  //Auto logout functionality has to be implemented once the JWT is in place.

//Public methods
}
