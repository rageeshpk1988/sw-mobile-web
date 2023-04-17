import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../screens/no_internet_screen.dart';

class ConnectivityHelper {
  static Future<bool> hasInternet<T>(
      BuildContext context, String pageRoute, T? args) async {
    if (kIsWeb) {
      return true;
    }
    //Check internet connection here
    var hasInternet = await InternetConnectionCheckerPlus().hasConnection;
    if (!hasInternet) {
      Navigator.of(context)
          .pushNamed(NoInternetScreen.routeName)
          .then((value) => {
                hasInternet = value as bool,
                if (hasInternet)
                  {
                    Navigator.of(context).pushNamed(pageRoute, arguments: args),
                  }
              });
      return false;
    } else {
      return true;
    }
  }
}
