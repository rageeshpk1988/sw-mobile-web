import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import '/src/models/api_response.dart';
import '/src/models/school_division.dart';
import '../../helpers/app_info.dart';
import '../../helpers/custom_exceptions.dart';
import '/src/models/child.dart';

import '../../helpers/global_variables.dart';

import 'package:path/path.dart';

import 'auth.dart';

/* Implementation Logic:
   Request OTP, Resend OTP, Validate OTP 
*/

class Children with ChangeNotifier {
//Class variables

//Class variables

//Getters

//Getters

//Private methods

//Private methods
//Public methods

  Future<Map<String, dynamic>> childAddUpdate(Child child, String? appVersion,
      File selectedFile, DivisionBySchoolList? divisionBySchoolList) async {
    // String authToken = await Auth().interceptor();
    final url =
        '${GlobalVariables.apiBaseUrl}/login/android/b2c/studentregister/post';
    // final url = '${GlobalVariables.apiEndPointLegacyService}/student-register';

    //format dateofbirth
    String childDob = DateFormat('yyyy-MM-dd')
        .format(DateFormat('dd-MM-yyyy').parse(child.dob!));
    //format dateofbirth
    String childIdParam = '';
    if (child.childID != null) {
      childIdParam = '"studentId" :"${child.childID}",';
    }

    String parentReigsterRequest =
        '{$childIdParam "appVersion":$appVersion,"boardId":${child.boardId}, "cityId":${child.cityId},"countryId":${child.countryID},'
        '"dob":"$childDob","gender":${child.gender},"name":"${child.name}",'
        '"parentId":${child.parentId},"relationShipId":${child.relationId},"relationShipName":"${child.relation}",'
        '"schoolId":${child.schoolId},"schoolType":"${child.schoolType}","stateId":${child.stateId},'
        '"tempDivision":"${child.tempDivision}","tempSchoolName":"${child.tempSchoolName}","tempStandard":"${child.tempStandard}"';
    //int divisionMappedId;
    if (divisionBySchoolList == null) {
      parentReigsterRequest = parentReigsterRequest + '}';
    } else {
      parentReigsterRequest = parentReigsterRequest +
          ',"divisionMappedId":${divisionBySchoolList.divisionMappedId}}';
    }

    try {
      var request = http.MultipartRequest("POST", Uri.parse(url));
      //request.headers['authorization'] = 'Bearer ${authToken}';

      request.fields['data'] = parentReigsterRequest;
      if (basename(selectedFile.path) != 'file.txt')
        request.files.add(
            await http.MultipartFile.fromPath('profilePic', selectedFile.path));
      final response = await request.send();

      final extractedResult = await response.stream.bytesToString();
      final extractedData = json.decode(extractedResult);

      Map<String, dynamic> returnValue = {
        'success': true,
        'message': extractedData['imageResponse'],
      };

      if (response.statusCode >= 400) {
        notifyListeners();
        returnValue['success'] = false;
        throw HttpException('Error in connecting to the service');
      }
      if (extractedData['status'].toString().trim() == '00') {
        returnValue['success'] = true;
      } else if (extractedData['status'].toString().trim() == '01') {
        notifyListeners();
        returnValue['success'] = false;
        throw HttpException(
            'Data updation failed  Status value : ${extractedData['status']}');
      }
      notifyListeners();

      return returnValue;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException('Unknown Error ${e.toString()}');
    }
  }
  // TODO:: This needs to be removed
  // Future<bool> childAddUpdate1(
  //     Child child,
  //     String? appVersion,
  //     File selectedFile,
  //     DivisionBySchoolList? divisionBySchoolList,
  //     String authToken) async {
  //   final url =
  //       '${GlobalVariables.apiBaseUrl}/login/android/b2c/studentregister/post';
  //   // final url = '${GlobalVariables.apiEndPointLegacyService}/student-register';

  //   //format dateofbirth
  //   String childDob = DateFormat('yyyy-MM-dd')
  //       .format(DateFormat('dd-MM-yyyy').parse(child.dob!));
  //   //format dateofbirth
  //   String childIdParam = '';
  //   if (child.childID != null) {
  //     childIdParam = '"studentId" :"${child.childID}",';
  //   }

  //   String parentReigsterRequest =
  //       '{$childIdParam "appVersion":$appVersion,"boardId":${child.boardId}, "cityId":${child.cityId},"countryId":${child.countryID},'
  //       '"dob":"$childDob","gender":${child.gender},"name":"${child.name}",'
  //       '"parentId":${child.parentId},"relationShipId":${child.relationId},"relationShipName":${child.relation},'
  //       '"schoolId":${child.schoolId},"schoolType":"${child.schoolType}","stateId":${child.stateId},'
  //       '"tempDivision":"${child.tempDivision}","tempSchoolName":"${child.tempSchoolName}","tempStandard":"${child.tempStandard}"';
  //   //int divisionMappedId;
  //   if (divisionBySchoolList == null) {
  //     parentReigsterRequest = parentReigsterRequest + '}';
  //   } else {
  //     parentReigsterRequest = parentReigsterRequest +
  //         ',"divisionMappedId":${divisionBySchoolList.divisionMappedId}}';
  //   }
  //   bool returnValue = false;
  //   try {
  //     var request = http.MultipartRequest("POST", Uri.parse(url));
  //     //request.headers['authorization'] = 'Bearer ${authToken}';

  //     request.fields['data'] = parentReigsterRequest;
  //     if (basename(selectedFile.path) != 'file.txt')
  //       request.files.add(
  //           await http.MultipartFile.fromPath('profilePic', selectedFile.path));
  //     final response = await request.send();

  //     final extractedResult = await response.stream.bytesToString();
  //     final extractedData = json.decode(extractedResult);

  //     if (response.statusCode >= 400) {
  //       notifyListeners();
  //       returnValue = false;
  //       throw HttpException('Error in connecting to the service');
  //     }
  //     if (extractedData['status'].toString().trim() == '00') {
  //       returnValue = true;
  //     } else if (extractedData['status'].toString().trim() == '01') {
  //       notifyListeners();
  //       returnValue = false;
  //       throw HttpException(
  //           'Data updation failed  Status value : ${extractedData['status']}');
  //     }
  //     notifyListeners();
  //     return returnValue;
  //   } on SocketException {
  //     throw NoInternetException('No Internet');
  //   } on HttpException catch (e) {
  //     throw NoServiceFoundException(e.message);
  //     //throw NoServiceFoundException('No Service Found');
  //   } catch (e) {
  //     throw UnknownException('Unknown Error ${e.toString()}');
  //   }
  // }

  Future<List<Child>> fetchStudentList(int postedUserID) async {
    String authToken = await Auth().interceptor();
    PackageInfo _packageInfo = await AppInfo.getPackageInfo();
    // final url =
    //     '${GlobalVariables.apiBaseUrl}/login/android/studentDetailsByparentId';
    final url = '${GlobalVariables.apiEndPointLegacyService}/student-details';

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
          'postedUserID': postedUserID,
          'appVersion': _packageInfo.version,
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
        throw HttpException("Invalid User Data...");
      }
      // if (extractedData['status'].toString().trim() != '00') {
      //   throw HttpException("Unable to fetch student's details");
      // }
      final List<Child> loadedStudents = [];

      var name;
      //var childID;
      var schoolName;
      var division;
      var imageUrl;
      //var dob;
      // int? schoolID;
      for (Map<String, dynamic> dt in apiResponse.data!['studentList']) {
        name =
            "${dt['firstName']} ${dt['lastName'] == null ? ' ' : dt['lastName']}";
        //childID = dt['studentID'].toString();
        schoolName = dt['schoolName'].toString();
        division = dt['division'].toString();
        imageUrl = dt['imageUrl'].toString();
        //dob = dt['dateofBirth'].toString();
        //schoolID = dt['schoolID'];
        loadedStudents.add(Child(
          name: name,
          gender: '',
          //childID: childID,
          schoolName: schoolName,
          division: division,
          imageUrl: imageUrl,
          //dob: dob,
          //schoolId: schoolID,
        ));
      }

      return loadedStudents;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
      //throw NoServiceFoundException('No Service Found');
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }

//Public methods
}
