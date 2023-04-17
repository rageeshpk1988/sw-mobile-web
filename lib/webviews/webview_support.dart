import 'package:flutter/material.dart';
import '../adaptive/adaptive_circular_progressInd.dart';
import '../adaptive/adaptive_custom_appbar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewSupport extends StatefulWidget {
  final String initialUrl;
  static String routeName = '/support-page';

  const WebViewSupport({Key? key, required this.initialUrl}) : super(key: key);
  @override
  _WebViewSupportState createState() => _WebViewSupportState();
}

class _WebViewSupportState extends State<WebViewSupport> {
  var _isLoading = true;
  final _key = UniqueKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AdaptiveCustomAppBar(
        title: " Help & Support",
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
            InAppWebView(
              key: _key,
              initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      "${widget.initialUrl}")),
              initialOptions: InAppWebViewGroupOptions(
                ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true),
                crossPlatform: InAppWebViewOptions(
                  preferredContentMode: UserPreferredContentMode.MOBILE,
                  javaScriptEnabled: true,
                  mediaPlaybackRequiresUserGesture: false,
                ),
              ),

              onLoadStop: (controller, uri) async {
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
    );
  }
}
