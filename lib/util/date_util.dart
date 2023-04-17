//Date formater
import 'package:intl/intl.dart';

class DateUtil {
  static const DATE_FORMAT = 'dd-MM-yyyy';
  static const DATE_FORMAT1 = 'yyyy-MM-dd';
  static const DATE_FORMAT_EXTENDED = 'dd-MM-yyyy HH:mm:ss';
  static const DATE_FORMAT_EXTENDED1 = 'dd-MM-yyyy hh:mm a';
  static const DATE_FORMAT_EXTENDED2 = 'yyyy-MM-dd hh:mm:ss';

  static String formattedDate(DateTime dateTime) {
    return DateFormat(DATE_FORMAT).format(dateTime);
  }

  static String formattedDate_1(DateTime dateTime) {
    return DateFormat(DATE_FORMAT1).format(dateTime);
  }

  static String formattedDateExtended(DateTime dateTime) {
    return DateFormat(DATE_FORMAT_EXTENDED).format(dateTime);
  }

  static String formattedDateExtended_1(DateTime dateTime) {
    return DateFormat(DATE_FORMAT_EXTENDED1).format(dateTime);
  }

  static String formattedDateExtended_2(DateTime dateTime) {
    return DateFormat(DATE_FORMAT_EXTENDED2).format(dateTime);
  }

  static DateTime yyyyMMddStringToDate(String dateString) {
    DateFormat inputFormat = DateFormat('yyyy-MM-dd');
    DateTime returnValue = inputFormat.parse(dateString);
    return returnValue;
  }

  static DateTime ddMMyyyyStringToDate(String dateString) {
    DateFormat inputFormat = DateFormat(DATE_FORMAT);
    DateTime returnValue = inputFormat.parse(dateString);
    return returnValue;
  }

  static DateTime ddMMyyyyHHMMSSStringToDate(String dateString) {
    // DateFormat inputFormat = DateFormat("yyyy-MM-ddTHH:mm:ss");
    DateTime returnValue =
        DateTime.parse(dateString); // inputFormat.parse(dateString);
    return returnValue;
  }

  static int calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  static DateTime calculatePastDate(int year, int month, int day) {
    DateTime now = DateTime.now();
    return DateTime(now.year - year, now.month - month, now.day - day);
  }

  static int getAge(String birthDateString) {
    var today = DateTime.now();
    var birthDate = DateTime.parse(birthDateString);
    var diff = today.difference(birthDate);
    var age = ((diff.inDays) / 365).round();
    return age;
  }
}
//Date formater
