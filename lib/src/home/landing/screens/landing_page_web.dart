import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/src/home/landing/screens/home_page_web.dart';

import '/util/ui_helpers.dart';
import '/widgets/web_banner.dart';
import '/widgets/web_bottom_bar.dart';

import '../../../models/login_response.dart';
import 'dummy_page.dart';

//This is a dummy page for testing . It will be removed at later stage

class LandingPageWeb extends StatefulWidget {
  static String routeName = '/web-landing-page';
  @override
  _LandingPageWebState createState() => _LandingPageWebState();
}

class _LandingPageWebState extends State<LandingPageWeb> {
  late LoginResponse loginResponse;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          content: Text(
            'Do you really want to exit?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
                //TODO:: FOR iOS MinimizeApp.minimizeApp();
                //   Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        endDrawer: WebBannerDrawer(),
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              WebBanner(
                  showMenu: true,
                  showHomeButton: false,
                  showProfileButton: true,
                  scaffoldKey: scaffoldKey),
              Container(
                  width: screenWidth(context),
                  height: screenHeight(context),
                  child: HomePageWeb() //,DummyPage() //
                  ),
              WebBottomBar(),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
