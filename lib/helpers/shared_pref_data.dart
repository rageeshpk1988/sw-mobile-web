/* 
  Shared pref data from app 
 */

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../src/models/socialaccesstoken_response.dart';
import '../src/models/ad_response.dart';
import '../src/models/login_response.dart';

class SharedPrefData {
  static Future<void> setUserDataPref(LoginResponse loginResponse) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');

    final userData = json.encode(loginResponse);
    prefs.setString('userData', userData);
  }

  static Future<void> clearDataPref() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }

  static Future<LoginResponse?> getUserDataPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return null;
    }
    final extractedData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    return LoginResponse.fromJson(extractedData, '');
  }

  static Future<void> setUserAdDDatPref(ADResponse adResponse) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userADData');

    final userADData = json.encode(adResponse);
    prefs.setString('userADData', userADData);
  }

  static Future<ADResponse?> getUserADDataPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userADData')) {
      return null;
    }
    final extractedData =
        json.decode(prefs.getString('userADData')!) as Map<String, dynamic>;
    return ADResponse.fromJson(extractedData);
  }

  static Future<void> setUserSocialAdDDatPref(SocialAdResponse token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userSocialADData');

    final userADData = json.encode(token);
    prefs.setString('userSocialADData', userADData);
  }

  static Future<SocialAdResponse?> getUserSocialADDataPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userSocialADData')) {
      return null;
    }
    final extractedData = json.decode(prefs.getString('userSocialADData')!)
        as Map<String, dynamic>;
    return SocialAdResponse.fromJson(extractedData);
  }

  static Future<void> setOtpCounter(int otpCount) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userOTPCount');

    //encode the data to store in json
    final userOTPCount = json.encode(
      {
        'count': otpCount,
        'requestedAt': DateTime.now().toIso8601String(),
      },
    );

    prefs.setString('userOTPCount', userOTPCount);
  }

  static Future<Map<String, dynamic>?> getOtpCounter() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userOTPCount')) {
      return null;
    }

    return json.decode(prefs.getString('userOTPCount')!)
        as Map<String, dynamic>;
  }
  //to set interest capture block count

  static Future<void> setBlockCounter(int childId, int blockCount) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('interestBlockCount$childId');
    final interestBlockCount = blockCount;
    prefs.setInt('interestBlockCount$childId', interestBlockCount);
  }

  static Future<int?> getBlockCounter(int childId) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('interestBlockCount$childId')) {
      return null;
    }
    final extractedData = prefs.getInt('interestBlockCount$childId');
    return extractedData;
  }

  static Future<int?> getUserKycStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userKycStatus')) {
      return null;
    }
    final extractedData = prefs.getInt('userKycStatus');
    return extractedData;
  }

  static Future<void> setUserKycStatus(int? status) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userKycStatus');

    final userKycStatus = status;
    if (status != null) {
      prefs.setInt('userKycStatus', userKycStatus!);
    }
  }
}
