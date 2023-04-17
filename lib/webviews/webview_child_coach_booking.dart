import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../src/providers/auth.dart';

import '../adaptive/adaptive_circular_progressInd.dart';
import '../adaptive/adaptive_custom_appbar.dart';

import 'package:webview_flutter/webview_flutter.dart';

import '../adaptive/adaptive_theme.dart';
import '../util/app_theme.dart';
import '../util/app_theme_cupertino.dart';
import '../util/ui_helpers.dart';

class ChildCoachBookingWebView extends StatefulWidget {
  static String routeName = '/booking-page';
  final Function updateHandler;

  const ChildCoachBookingWebView({Key? key, required this.updateHandler})
      : super(key: key);
  @override
  _ChildCoachBookingWebViewState createState() =>
      _ChildCoachBookingWebViewState();
}

class _ChildCoachBookingWebViewState extends State<ChildCoachBookingWebView> {
  var _isLoading = true;
  final _key = UniqueKey();
  Future<bool> _onBackPressed() {
    return showDialog(
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 32.0, right: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 25),
              Image.asset('assets/icons/alert_info.png', width: 40, height: 40),
              const SizedBox(height: 10),
              Text(
                "Do you want to go back?",
                style: kIsWeb || Platform.isAndroid
                    ? AppTheme.lightTheme.textTheme.bodyMedium!
                        .copyWith(fontSize: 14, fontWeight: FontWeight.w700)
                    : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
                        .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  appButton(
                    context: context,
                    width: double.infinity,
                    height: 35,
                    title: 'Yes',
                    titleColour: AdaptiveTheme.primaryColor(context),
                    borderColor: AdaptiveTheme.primaryColor(context),
                    onPressed: () {
                      widget.updateHandler();
                      Navigator.of(context).pop(true);
                    },
                  ),
                  verticalSpaceSmall,
                  appButton(
                    context: context,
                    width: double.infinity,
                    height: 35,
                    title: 'No',
                    titleColour: HexColor.fromHex("#333333"),
                    borderColor: HexColor.fromHex('#C9C9C9'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30)
            ],
          ),
        ),
      ),
      context: context,
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    var authData = Provider.of<Auth>(context, listen: false);
    String url =
        "https://schoolwizardprivatelimited.zohobookings.in/#/customer/119221000000022053?Contact%20Number=${authData.loginResponse.mobileNumber}&Email=${authData.loginResponse.b2cParent!.emailID}";
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AdaptiveCustomAppBar(
          title: "Schedule a Meeting",
          showShopifyHomeButton: false,
          showShopifyCartButton: false,
          showKycButton: false,
          showProfileButton: false,
          showHamburger: false,
          scaffoldKey: null,
          adResponse: null,
          loginResponse: null,
          updateHandler: null,
          showMascot: true,
        ),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              WebView(
                key: _key,
                initialUrl: url, //GlobalVariables.coachBookingUrl,
                javascriptMode: JavascriptMode.unrestricted,
                onPageFinished: (finish) {
                  setState(() {
                    _isLoading = false;
                  });
                },
              ),
              _isLoading
                  ? Center(
                      child: AdaptiveCircularProgressIndicator(),
                    )
                  : Stack(),
            ],
          ),
        ),
      ),
    );
  }
}
