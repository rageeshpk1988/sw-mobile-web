import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '/src/models/tc_meeting.dart';
import '/util/date_util.dart';
import '../../helpers/custom_exceptions.dart';

import '../../helpers/global_variables.dart';
import 'auth.dart';

/* Implementation Logic:
All subscription related API calls
*/

class Meeting {
//Public methods

  Future<bool> saveTCMeeting(
    int parentId,
    TCMeeting tcMeeting,
  ) async {
    String authToken = await  Auth().interceptor();
    final url = '${GlobalVariables.apiEndPointStudentService}/meeting-details';

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
          "date": DateUtil.formattedDate_1(
              DateFormat('dd-MM-yyyy').parse(tcMeeting.date)),
          "parent_id": parentId,
          "message": tcMeeting.message,
          "time": tcMeeting.time,
          "questionAnswerList": tcMeeting.questionAnswerList.toList(),
        }),
      );
      if (response.statusCode >= 400) {
        throw HttpException('Error in connecting to the service');
      }

      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        throw HttpException('Error in getting data from server');
      }

      if (extractedData['message'] != 'Success') {
        throw HttpException(extractedData['error']);
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

//Public methods

}
