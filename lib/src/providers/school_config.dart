import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '/src/models/api_response.dart';
import '../../helpers/custom_exceptions.dart';
import '../../src/models/parent_releation.dart';
import '../../src/models/school.dart';
import '../../src/models/school_board.dart';
import '../../src/models/school_division.dart';

import '../../helpers/global_variables.dart';
import 'auth.dart';

/* Implementation Logic:
All school related API calls
*/

class SchoolConfig with ChangeNotifier {
//Class variables

//Class variables

//Getters

//Getters

//Private methods

//Private methods

//Public methods
  Future<List<School>> fetchSchools(int cityID) async {
    String authToken = await  Auth().interceptor();
    final url = '${GlobalVariables.apiEndPointLegacyService}/schools';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'cityID': cityID,
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
        throw HttpException('Unable to fetch schools data');
      }

      final List<School> loadedSchools = [];

      for (Map<String, dynamic> dt
          in apiResponse.data!['tempSchoolJoinModel']) {
        School school = School.fromJson(dt);
        loadedSchools.add(school);
      }

      return loadedSchools;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }

  Future<List<SchoolBoard>> fetchSchoolBoard(
      String countryID) async {
    String authToken = await  Auth().interceptor();
    final url = '${GlobalVariables.apiEndPointLegacyService}/country-board';

    //PackageInfo _packageInfo = await AppInfo.getPackageInfo();
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          // 'appVersion': _packageInfo.version,
          'country': countryID,
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
        throw HttpException('Unable to fetch board of education data');
      }

      final List<SchoolBoard> loadedBoards = [];

      for (Map<String, dynamic> dt in apiResponse.data!['boardList']) {
        SchoolBoard board = SchoolBoard.fromJson(dt);
        loadedBoards.add(board);
      }

      return loadedBoards;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }

  Future<DivisionAndParentRelation> fetchDivsionAndParentRelation(
      School school) async {
    String authToken = await  Auth().interceptor();
    final url =
        '${GlobalVariables.apiEndPointLegacyService}/student-register/division-relation-list';
    //PackageInfo _packageInfo = await AppInfo.getPackageInfo();
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          // 'appVersion': _packageInfo.version,
          'schoolId': school.schoolId,
          'schoolType': school.schoolType,
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
        throw HttpException('Unable to fetch relations data');
      }

      final List<ParentReleation> loadedRelations = [];
      // List<SchoolDivision> loadedDivisions =
      //     List<SchoolDivision>.from(extractedData['divisionList']);
      // final List<SchoolDivision> loadedDivisions =
      //     (extractedData['divisionList'] as List<dynamic>)
      //         .cast<SchoolDivision>();

      List<SchoolDivision> loadedDivisions = [];
      List<DivisionBySchoolList> loadedDivisionBySchoolList = [];

      if (apiResponse.data!['divisionList'] != null) {
        for (String str in apiResponse.data!['divisionList']) {
          loadedDivisions.add(SchoolDivision(division: str));
        }
      }
      if (apiResponse.data!['divisionBySchoolList'] != null) {
        for (Map<String, dynamic> dt
            in apiResponse.data!['divisionBySchoolList']) {
          DivisionBySchoolList divisionBySchool =
              DivisionBySchoolList.fromJson(dt);
          loadedDivisionBySchoolList.add(divisionBySchool);
        }
      }

      for (Map<String, dynamic> dt in apiResponse.data!['relationShipList']) {
        ParentReleation releation = ParentReleation.fromJson(dt);
        loadedRelations.add(releation);
      }
      DivisionAndParentRelation divisionAndParentRelation =
          DivisionAndParentRelation(
              schoolDivisionList: loadedDivisions,
              parentReleationList: loadedRelations,
              divisionBySchoolList: loadedDivisionBySchoolList);
      return divisionAndParentRelation;
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
