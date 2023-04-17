import 'package:flutter/material.dart';
import '../adaptive/adaptive_circular_progressInd.dart';

import 'package:webviewx_plus/webviewx_plus.dart';

import '../widgets/web_banner.dart';
import '../widgets/web_bottom_bar.dart';
//import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewSupportWeb extends StatefulWidget {
  final String initialUrl;
  static String routeName = '/support-page';

  const WebViewSupportWeb({Key? key, required this.initialUrl})
      : super(key: key);
  @override
  _WebViewSupportWebState createState() => _WebViewSupportWebState();
}

class _WebViewSupportWebState extends State<WebViewSupportWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var _isLoading = true;
  final _key = UniqueKey();
  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    var appBarHeight = kToolbarHeight;
    var screenheight = deviceSize.height - appBarHeight;
    var screenwidth = deviceSize.width;
    return Scaffold(
      key: scaffoldKey,
      endDrawer: WebBannerDrawer(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: WebViewAware(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              WebBanner(
                showMenu: true,
                showHomeButton: true,
                showProfileButton: true,
                scaffoldKey: scaffoldKey,
              ),
              WebViewX(
                  key: _key,
                  initialContent: widget.initialUrl,
                  javascriptMode: JavascriptMode.unrestricted,
                  height: screenheight * .90,
                  width: screenwidth * 90,
                  onPageFinished: (finish) {
                    setState(() {
                      _isLoading = false;
                    });
                  }),
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
    );
  }
}
