import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:webviewx_plus/webviewx_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../adaptive/adaptive_circular_progressInd.dart';

import '../adaptive/adaptive_theme.dart';
import '../helpers/route_arguments.dart';
import '../src/login/screens/login_with_pass.dart';
import '../src/models/ad_response.dart';
import '../src/providers/auth.dart';
//import 'package:webview_flutter/webview_flutter.dart';

import '../util/app_theme.dart';
import '../util/app_theme_cupertino.dart';
import '../util/ui_helpers.dart';
import '../widgets/web_banner.dart';
import '../widgets/web_bottom_bar.dart';

class WebViewShopifyWeb extends StatefulWidget {
  final String initialUrl;
  final ADResponse? adResponse;
  final Function updateHandler;
  final Function socialUpdateHandler;

  const WebViewShopifyWeb(
      {Key? key,
      required this.initialUrl,
      this.adResponse,
      required this.updateHandler,
      required this.socialUpdateHandler})
      : super(key: key);
  @override
  _WebViewShopifyWebState createState() => _WebViewShopifyWebState();
}

class _WebViewShopifyWebState extends State<WebViewShopifyWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<WebViewXController> _controllerCompleter =
      Completer<WebViewXController>();
  var _isLoading = true;
  //Make sure this function return Future<bool> otherwise you will get an error

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
                "Do you want to exit the store?",
                style: kIsWeb || Platform.isAndroid
                    ? AppTheme.lightTheme.textTheme.bodyMedium!
                        .copyWith(fontSize: 14, fontWeight: FontWeight.w700)
                    : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
                        .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 25,
              ),
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
              SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
      context: context,
    ).then((value) => value ?? false);
  }

  /* Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text('Do you really want to exit the store?',style: Platform.isIOS
              ? AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle.copyWith(fontWeight: FontWeight.w500)
              : AppTheme.lightTheme.textTheme.bodySmall,),
         // content: Text('All progress made will be lost.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }*/

  @override
  Widget build(BuildContext context) {
    String mobileNumber =
        Provider.of<Auth>(context, listen: false).loginResponse.mobileNumber;
    var deviceSize = MediaQuery.of(context).size;
    var appBarHeight = kToolbarHeight;
    var screenheight = deviceSize.height - appBarHeight;
    var screenwidth = deviceSize.width;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: scaffoldKey,
        endDrawer: WebBannerDrawer(),
        backgroundColor: Colors.white,
        body: WebViewAware(
          child: SingleChildScrollView(
            child: WebViewAware(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  WebBanner(
                    showMenu: true,
                    showHomeButton: true,
                    showProfileButton: true,
                    scaffoldKey: scaffoldKey,
                  ),
                  WebViewX(
                    height: screenheight * .90,
                    width: screenwidth * 90,
                    initialContent: widget.initialUrl,
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewXController webViewController) {
                      _controllerCompleter.complete(webViewController);
                    },
                    onPageFinished: (String url) {
                      setState(() {
                        _isLoading = false;
                      });
                      String error = url.substring(url.lastIndexOf('/') + 1);
                      //print(error);
                      if (error ==
                          "identityerror?error_description=JWT%20token%20is%20expired") {
                        Navigator.of(context).pushReplacementNamed(
                            LoginWithPassword.routeName,
                            arguments: LoginWithPasswordArgs(
                                true,
                                mobileNumber,
                                widget.updateHandler,
                                widget.socialUpdateHandler,
                                true));
                      }
                    },
                  ),
                  WebBottomBar(),
                  SizedBox(height: 10),
                  _isLoading
                      ? Center(
                          child: AdaptiveCircularProgressIndicator(),
                        )
                      : Stack(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
