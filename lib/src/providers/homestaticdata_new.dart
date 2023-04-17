import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import '/src/models/api_response.dart';
import '../../helpers/app_info.dart';
import '../../helpers/custom_exceptions.dart';
import '../../src/models/b2cparent.dart';

import '../../helpers/global_variables.dart';
import '../models/quote_response.dart';
import 'auth.dart';

/* Implementation Logic:
All subscription related API calls
*/

class HomeStaticDataNew with ChangeNotifier {
  List<B2CParent>? _suggestedParents;
  String? authToken;

  void update(String? token) {
    this.authToken = token;
  }
  //Getters

  List<B2CParent>? get suggestedParents {
    return _suggestedParents;
  }
  //Getters

//Private methods

//Private methods

//Public methods

  void removeSuggestedParents(int? id) {
    final existingIndex = _suggestedParents!
        .indexWhere((element) => element.parentID == id); //local object index
    _suggestedParents!.removeAt(existingIndex);
    notifyListeners();
  }

  Future<void> fetchAndSetSuggestedParentList(
      int b2cParentID) async {
    String authToken = await  Auth().interceptor();
    PackageInfo _packageInfo = await AppInfo.getPackageInfo();
    final url = '${GlobalVariables.apiEndPointLegacyService}/suggestions';

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
          'parentID': b2cParentID,
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
        throw HttpException('Unable to fetch subscription packages data');
      }
      final List<B2CParent> loadedParents = [];

      var parentID;
      var parentName;
      var profileImage;
      var parentCountry;
      var parentState;
      var parentLocation;
      for (Map<String, dynamic> dt
          in apiResponse.data!['suggestedParentList']) {
        parentID = dt['parentID'];
        parentName = dt['parentName'].toString();
        profileImage = dt['profileImage'].toString();
        parentCountry = dt['parentCountry'].toString();
        parentState = dt['parentState'].toString();
        parentLocation = dt['parentLocation'].toString();
        loadedParents.add(B2CParent(
          parentID: parentID,
          name: parentName,
          emailID: '',
          profileImage: profileImage,
          country: parentCountry,
          state: parentState,
          location: parentLocation,
        ));
      }
      _suggestedParents = loadedParents;
      notifyListeners();
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }

  Future<QuoteResponse?> getDailyQuote() async {
    String authToken = await  Auth().interceptor();
    final url = '${GlobalVariables.apiEndpointParentService}/active-quote';
    // final url =
    //     'http://20.41.225.227:80/parent-service/api/v1/active-quote';
    // 'Bearer eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI5ODc2NTQzMjEwIiwiYXVkIjoic2Nob29sd2l6YXJkLXVzZXJzIiwibmJmIjoxNjQyNjY2MTg5LCJpc3MiOiJodHRwOi8vd3d3LnNjaG9vbHdpemFyZC5jb20iLCJleHAiOjE2NDUyNTgxODksImlhdCI6MTY0MjY2NjE4OSwianRpIjoiMzIwMmUxYjAtZWU5Yi00NDI1LTk2YjEtZWY1ZTdiNWRkOWUxIn0.mic76YoIW1DNuW8rbkRqi3KGUZbEQpAMFWiqoVndkKOZZ4-1M3KRtJ-DDlLN6mAbDMsou-Pa7EuFa0iAD9yXlZkpC3y1h_xdIeVMoNivKYHwqY1CPAp-5nQOinqCk9Uo4sKC_L7QT5j5A6dnaoEUK5fLIRZ3pPBGo7kw_hoBpCV98n5Yl98Wyu_GEgIduBOB1nsMUtJRZ3emwx3fgdKg4Buxoh5Ou0OXMiThjodiqJsUClHzWwVwhAu7FGt4bFTAaq5h2_nv61YFiR_a7GTL85_Qn5ff5YHA68dABoy5OXhwB-wtYlQfSwUTeaOPF-aOqPRO8hn2oW6a_ryLUoHUQg',
    // token =
    //     ' eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI5ODc2NTQzMjEwIiwiYXVkIjoic2Nob29sd2l6YXJkLXVzZXJzIiwibmJmIjoxNjQyNjY2MTg5LCJpc3MiOiJodHRwOi8vd3d3LnNjaG9vbHdpemFyZC5jb20iLCJleHAiOjE2NDUyNTgxODksImlhdCI6MTY0MjY2NjE4OSwianRpIjoiMzIwMmUxYjAtZWU5Yi00NDI1LTk2YjEtZWY1ZTdiNWRkOWUxIn0.mic76YoIW1DNuW8rbkRqi3KGUZbEQpAMFWiqoVndkKOZZ4-1M3KRtJ-DDlLN6mAbDMsou-Pa7EuFa0iAD9yXlZkpC3y1h_xdIeVMoNivKYHwqY1CPAp-5nQOinqCk9Uo4sKC_L7QT5j5A6dnaoEUK5fLIRZ3pPBGo7kw_hoBpCV98n5Yl98Wyu_GEgIduBOB1nsMUtJRZ3emwx3fgdKg4Buxoh5Ou0OXMiThjodiqJsUClHzWwVwhAu7FGt4bFTAaq5h2_nv61YFiR_a7GTL85_Qn5ff5YHA68dABoy5OXhwB-wtYlQfSwUTeaOPF-aOqPRO8hn2oW6a_ryLUoHUQg';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode >= 400) {
        throw HttpException('Error in connecting to the service');
      }
      if (response.statusCode == 200) {
        //var jsonString = response.body;
        var jsonMap = json.decode(response.body);

        var quoteResponse = QuoteResponse.fromJson(jsonMap);
        return quoteResponse;
      } else {
        return null;
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

//Public methods

}
