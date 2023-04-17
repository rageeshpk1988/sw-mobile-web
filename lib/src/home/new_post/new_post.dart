import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../adaptive/adaptive_theme.dart';

import 'post_achievement.dart';
import 'post_activity.dart';
import 'post_general.dart';
import '../../../../src/models/login_response.dart';
import '../../../../src/providers/auth.dart';

import '../../../../util/dialogs.dart';

import '../../../adaptive/adaptive_custom_appbar.dart';
import '../../../helpers/connectivity_helper.dart';
import '../../../util/app_theme.dart';
import '../../../util/app_theme_cupertino.dart';
import '../../../util/ui_helpers.dart';

class NewPostScreen extends StatefulWidget {
  static String routeName = '/new-post';
  const NewPostScreen({Key? key}) : super(key: key);

  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  double _cardHeight(double screenheight) {
    double cardHeight = 0;
    double txtScale = textScale(context);
    if (txtScale <= 0.85) {
      if (screenheight < 750)
        cardHeight =
            screenheight * (kIsWeb || Platform.isAndroid ? 0.30 : 0.34);
      else
        cardHeight =
            screenheight * (kIsWeb || Platform.isAndroid ? 0.26 : 0.29);
    } else if (txtScale >= 0.85 && txtScale < 1.0) {
      if (screenheight < 750)
        cardHeight =
            screenheight * (kIsWeb || Platform.isAndroid ? 0.30 : 0.33);
      else
        cardHeight =
            screenheight * (kIsWeb || Platform.isAndroid ? 0.26 : 0.29);
    } else if (txtScale == 1.0) {
      if (screenheight <= 700) {
        cardHeight =
            screenheight * (kIsWeb || Platform.isAndroid ? 0.36 : 0.34);
      } else if (screenheight > 700 && screenheight < 750)
        cardHeight =
            screenheight * (kIsWeb || Platform.isAndroid ? 0.32 : 0.34);
      else
        cardHeight =
            screenheight * (kIsWeb || Platform.isAndroid ? 0.28 : 0.32);
    } else if (txtScale >= 1.0 && txtScale < 1.15) {
      if (screenheight < 750)
        cardHeight =
            screenheight * (kIsWeb || Platform.isAndroid ? 0.32 : 0.39);
      else
        cardHeight =
            screenheight * (kIsWeb || Platform.isAndroid ? 0.28 : 0.34);
    } else if (txtScale >= 1.15 && txtScale < 1.30) {
      if (screenheight < 750)
        cardHeight =
            screenheight * (kIsWeb || Platform.isAndroid ? 0.37 : 0.40);
      else
        cardHeight =
            screenheight * (kIsWeb || Platform.isAndroid ? 0.31 : 0.35);
    } else if (txtScale >= 1.30) {
      if (screenheight < 750)
        cardHeight =
            screenheight * (kIsWeb || Platform.isAndroid ? 0.39 : 0.42);
      else
        cardHeight =
            screenheight * (kIsWeb || Platform.isAndroid ? 0.32 : 0.35);
    } else {
      if (screenheight < 750)
        cardHeight = screenheight * 0.34;
      else
        cardHeight = screenheight * 0.30;
    }
    return cardHeight;
  }

  @override
  Widget build(BuildContext context) {
    int? kycstatus = Provider.of<Auth>(context, listen: true).kycResponse;
    LoginResponse _loginResponse =
        Provider.of<Auth>(context, listen: false).loginResponse;
    var deviceSize = MediaQuery.of(context).size;
    var appBarHeight = kToolbarHeight;
    var screenheight = deviceSize.height - appBarHeight;
    //var screenWidth = deviceSize.width;

    final AutoSizeGroup descGroup = AutoSizeGroup();
    TextStyle _textViewStyle = kIsWeb || Platform.isAndroid
        ? AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontSize: 15, fontWeight: FontWeight.w300)
        : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
            .copyWith(fontSize: 15, fontWeight: FontWeight.w300);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AdaptiveCustomAppBar(
        showShopifyHomeButton: false,
        showShopifyCartButton: false,
        showKycButton: false,
        showProfileButton: false,
        showHamburger: false,
        scaffoldKey: null,
        adResponse: null,
        loginResponse: null,
        updateHandler: null,
        title: 'Add New Post',
        showMascot: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: _cardHeight(screenheight),
                    width: double.infinity,
                    child: Card(
                        elevation: 2.0,
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Image.asset(
                              'assets/images/b2c_splash_logo1.png',
                              height: 80,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              //'${textScale(context).toString()}  ${screenheight.toString()}',
                              'Activity',
                              textAlign: TextAlign.center,
                              style: _textViewStyle.copyWith(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: AutoSizeText(
                                "Cherish and appreciate your little one's interest by sharing it with friends and family.",
                                textAlign: TextAlign.center,
                                style: _textViewStyle,
                                maxFontSize: 17,
                                maxLines: 4,
                                minFontSize: 10,
                                overflow: TextOverflow.ellipsis,
                                stepGranularity: 1,
                                group: descGroup,
                              ),
                            ),
                            //SizedBox(height: 5),
                            Divider(),
                            SizedBox(
                              //height: 50,
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    if (kycstatus != 1) {
                                      Dialogs().ackInfoAlert(context,
                                          'Your KYC is not approved yet...');
                                      return;
                                    } else {
                                      if (_loginResponse
                                          .b2cParent!.childDetails!.isEmpty) {
                                        Dialogs().noChildPopup(
                                            context,
                                            //'This enables you to add your kids activities.\n\nIt seems that you haven’t added your kids details yet. Go to profile and add your kids to proceed with the post.');
                                            'This enables you to add your kids activities.\n\nIt seems that you haven’t added your kids details yet. Add your kids to proceed with the post.');
                                        return;
                                      } else {
                                        if (await ConnectivityHelper
                                                .hasInternet(
                                                    context,
                                                    PostActivityScreen
                                                        .routeName,
                                                    null) ==
                                            true) {
                                          Navigator.of(context).pushNamed(
                                              PostActivityScreen.routeName);
                                        }
                                      }
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        'New Post',
                                        style: TextStyle(
                                            fontSize: textScale(context) <= 1.0
                                                ? 16
                                                : 14,
                                            fontWeight: FontWeight.w600,
                                            color: AdaptiveTheme.primaryColor(
                                                context)),
                                        textAlign: TextAlign.left,
                                      ),
                                      Container(
                                          padding: EdgeInsets.all(0.0),
                                          child: Icon(
                                              Icons.navigate_next_outlined)),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        )),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: _cardHeight(screenheight),
                    width: double.infinity,
                    child: Card(
                        elevation: 2.0,
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Image.asset(
                              'assets/images/b2c_splash_logo2.png',
                              height: 80,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              //' ${screenWidth.toString()}',
                              ' Achievements',
                              textAlign: TextAlign.center,
                              style: _textViewStyle.copyWith(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: AutoSizeText(
                                "Every accomplishment is a milestone, so celebrate by sharing it with family and friends.",
                                textAlign: TextAlign.center,
                                style: _textViewStyle,
                                maxFontSize: 17,
                                maxLines: 4,
                                minFontSize: 10,
                                stepGranularity: 1,
                                overflow: TextOverflow.ellipsis,
                                group: descGroup,
                              ),
                            ),
                            //SizedBox(height: 5),
                            Divider(),
                            SizedBox(
                              //height: 50,
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    // int? kycstatus = Provider.of<Auth>(context,listen: true).kycResponse;
                                    if (kycstatus != 1) {
                                      Dialogs().ackInfoAlert(context,
                                          'Your KYC is not approved yet...');
                                      return;
                                    } else {
                                      if (_loginResponse
                                          .b2cParent!.childDetails!.isEmpty) {
                                        Dialogs().noChildPopup(
                                            context,
                                            //'This enables you to add your kids activities.\n\nIt seems that you haven’t added your kids details yet. Go to profile and add your kids to proceed with the post.');
                                            'This enables you to add your kids achievements.\n\nIt seems that you haven’t added your kids details yet. Add your kids to proceed with the post.');

                                        return;
                                      } else {
                                        if (await ConnectivityHelper
                                                .hasInternet(
                                                    context,
                                                    PostAchievementScreen
                                                        .routeName,
                                                    null) ==
                                            true) {
                                          Navigator.of(context).pushNamed(
                                              PostAchievementScreen.routeName);
                                        }
                                      }
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        'New Post',
                                        style: TextStyle(
                                            fontSize: textScale(context) <= 1.0
                                                ? 16
                                                : 14,
                                            fontWeight: FontWeight.w600,
                                            color: AdaptiveTheme.primaryColor(
                                                context)),
                                        textAlign: TextAlign.left,
                                      ),
                                      Icon(Icons.navigate_next_outlined),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        )),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: _cardHeight(screenheight),
                    width: double.infinity,
                    child: Card(
                        elevation: 2.0,
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Image.asset(
                              'assets/images/b2c_splash_logo3.png',
                              height: 80,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'General',
                              textAlign: TextAlign.center,
                              style: _textViewStyle.copyWith(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: AutoSizeText(
                                  "Every step is a milestone, so celebrate by sharing it with family and friends.",
                                  textAlign: TextAlign.center,
                                  style: _textViewStyle,
                                  maxFontSize: 17,
                                  maxLines: 4,
                                  minFontSize: 10,
                                  overflow: TextOverflow.ellipsis,
                                  stepGranularity: 1,
                                  group: descGroup),
                            ),
                            // SizedBox(height: 5),
                            Divider(),
                            SizedBox(
                              //height: 50,
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    if (kycstatus != 1) {
                                      Dialogs().ackInfoAlert(context,
                                          'Your KYC is not approved yet...');
                                      return;
                                    } else {
                                      if (await ConnectivityHelper.hasInternet(
                                              context,
                                              PostGeneralScreen.routeName,
                                              null) ==
                                          true) {
                                        Navigator.of(context).pushNamed(
                                            PostGeneralScreen.routeName);
                                      }
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        'New Post',
                                        style: TextStyle(
                                            fontSize: textScale(context) <= 1.0
                                                ? 16
                                                : 14,
                                            fontWeight: FontWeight.w600,
                                            color: AdaptiveTheme.primaryColor(
                                                context)),
                                        textAlign: TextAlign.left,
                                      ),
                                      Icon(Icons.navigate_next_outlined),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
