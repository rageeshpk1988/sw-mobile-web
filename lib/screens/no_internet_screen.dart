import 'package:flutter/material.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../adaptive/adaptive_circular_progressInd.dart';

import '../util/custom_appbar_new.dart';
import '../widgets/rounded_button.dart';

class NoInternetScreen extends StatefulWidget {
  static String routeName = '/nointernet';

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    AssetImage imagePath = AssetImage('assets/images/nointernet.png');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBarNew(
          showShopifyHomeButton: false,
          showShopifyCartButton: false,
          showKycButton: false,
          showProfileButton: false,
          showHamburger: false,
          scaffoldKey: null,
          adResponse: null,
          kycStatus: null,
          loginResponse: null,
          updateHandler: null),
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image(image: imagePath),
          if (_isLoading)
            Center(
              child: AdaptiveCircularProgressIndicator(),
            ),
          if (!_isLoading)
            Text(
              'No Internet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (!_isLoading)
            Text(
              'Please check your network connection',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54),
            ),
          const SizedBox(height: 30),
          SizedBox(
            width: 250,
            child: RoundButton(
              title: 'Try Again',
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });

                //Check internet connection here
                var hasInternet =
                    await InternetConnectionCheckerPlus().hasConnection;
                await Future.delayed(const Duration(seconds: 1));
                if (hasInternet) {
                  Navigator.of(context).pop(hasInternet);
                } else {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              color: Colors.grey,
            ),
          ),
        ],
      )),
    );
  }
}
