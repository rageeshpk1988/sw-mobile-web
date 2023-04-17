import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
//import 'package:package_info_plus/package_info_plus.dart';
import '/src/models/api_response.dart';
import '../../helpers/custom_exceptions.dart';
//import '../../helpers/app_info.dart';
import '../../helpers/global_variables.dart';
import '../../src/models/city_name.dart';
import '../../src/models/country_name.dart';
import '../../src/models/state_name.dart';
import 'auth.dart';

/* Implementation Logic:
  Location - Country, State and City
*/

class UserLocation with ChangeNotifier {
//Class variables

//Class variables

//Getters

//Getters

//Private methods

//Private methods

//Public methods

  Future<List<CountryName>> fetchCountries() async {
    String authToken = await  Auth().interceptor();
    final url = '${GlobalVariables.apiEndPointLegacyService}/location';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'status': 'country',
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

      if (apiResponse.data!['status'].toString().trim() != 'Success') {
        throw HttpException('Unable to fetch countries data');
      }
      final List<CountryName> loadedCountries = [];

      for (Map<String, dynamic> dt in apiResponse.data!['countryList']) {
        CountryName countryName = CountryName.fromJson(dt);
        loadedCountries.add(countryName);
      }

      return loadedCountries;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }

  Future<List<StateName>> fetchStateNames(
      String countryId) async {
    String authToken = await  Auth().interceptor();
    final url = '${GlobalVariables.apiEndPointLegacyService}/location';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'countryId': countryId,
          'status': 'state',
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

      if (apiResponse.data!['status'].toString().trim() != 'Success') {
        throw HttpException('Unable to fetch states data');
      }

      final List<StateName> loadedStates = [];

      for (Map<String, dynamic> dt in apiResponse.data!['stateList']) {
        StateName stateName = StateName.fromJson(dt);
        loadedStates.add(stateName);
      }

      return loadedStates;
    } on SocketException {
      throw NoInternetException('No Internet');
    } on HttpException catch (e) {
      throw NoServiceFoundException(e.message);
    } catch (e) {
      throw UnknownException('Unknown Error');
    }
  }

  Future<List<CityName>> fetchCityNames(
      String countryId, var stateId) async {
    String authToken = await  Auth().interceptor();
    final url = '${GlobalVariables.apiEndPointLegacyService}/location';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'countryId': countryId,
          'stateId': stateId,
          'status': 'city',
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

      if (apiResponse.data!['status'].toString().trim() != 'Success') {
        throw HttpException('Unable to fetch location data');
      }

      final List<CityName> loadedCities = [];

      for (Map<String, dynamic> dt in apiResponse.data!['cityList']) {
        CityName cityName = CityName.fromJson(dt);
        loadedCities.add(cityName);
      }

      return loadedCities;
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
