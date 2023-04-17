import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';

import '/helpers/route_arguments.dart';
import '/src/models/referral.dart';

import '../../../adaptive/adaptive_custom_appbar.dart';
import '../../../util/app_theme.dart';
import '../../../util/app_theme_cupertino.dart';
import '../widgets/referral_detail_item.dart';
import '/util/ui_helpers.dart';

class ReferralDetailScreen extends StatefulWidget {
  static String routeName = '/referral-details';
  const ReferralDetailScreen({Key? key}) : super(key: key);

  @override
  _ReferralDetailScreenState createState() => _ReferralDetailScreenState();
}

class _ReferralDetailScreenState extends State<ReferralDetailScreen> {
  var _isInIt = true;
  //var _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInIt) {}
    _isInIt = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final referralArgs =
        ModalRoute.of(context)!.settings.arguments as ReferralDetailArgs;
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
        updateHandler: null,
        loginResponse: null,
        title: 'Refer a Friend',
        showMascot: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  //padding: EdgeInsets.fromLTRB(16.0, 0, 16.0,0),
                  //decoration: BoxDecoration(color: hexToColor("#FFF3F8"),borderRadius: BorderRadius.circular(13)),
                  height: 104,
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 100,
                        width: 164,
                        child: Card(
                          color: HexColor.fromHex("#FFF3F8"),
                          margin: EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Icon(
                                      Icons.file_download_outlined,
                                      color: HexColor.fromHex("#FF6F95"),
                                    ),
                                  ),
                                  Text(
                                      referralArgs.referral.count != null
                                          ? "${referralArgs.referral.count}"
                                          : "0",
                                      style: kIsWeb || Platform.isAndroid
                                          ? AppTheme
                                              .lightTheme.textTheme.bodySmall!
                                              .copyWith(
                                                  fontSize: 21,
                                                  fontWeight: FontWeight.w700)
                                          : AppThemeCupertino.lightTheme
                                              .textTheme.navTitleTextStyle
                                              .copyWith(
                                                  fontSize: 21,
                                                  fontWeight: FontWeight.w700)),
                                  Text("Downloads",
                                      style: kIsWeb || Platform.isAndroid
                                          ? AppTheme
                                              .lightTheme.textTheme.bodySmall!
                                              .copyWith(fontSize: 12)
                                          : AppThemeCupertino.lightTheme
                                              .textTheme.navTitleTextStyle
                                              .copyWith(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w300)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      SizedBox(
                        height: 100,
                        width: 164,
                        child: Card(
                          color: HexColor.fromHex("#FFF3F8"),
                          margin: EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Icon(
                                      Icons.check_circle_outline,
                                      color: HexColor.fromHex("#FF6F95"),
                                    ),
                                  ),
                                  Text(
                                      referralArgs.referral.subscribedCount !=
                                              null
                                          ? "${referralArgs.referral.subscribedCount}"
                                          : "0",
                                      style: kIsWeb || Platform.isAndroid
                                          ? AppTheme
                                              .lightTheme.textTheme.bodySmall!
                                              .copyWith(
                                                  fontSize: 21,
                                                  fontWeight: FontWeight.w700)
                                          : AppThemeCupertino.lightTheme
                                              .textTheme.navTitleTextStyle
                                              .copyWith(
                                                  fontSize: 21,
                                                  fontWeight: FontWeight.w700)),
                                  Text("Subscribed",
                                      style: kIsWeb || Platform.isAndroid
                                          ? AppTheme
                                              .lightTheme.textTheme.bodySmall!
                                              .copyWith(fontSize: 12)
                                          : AppThemeCupertino.lightTheme
                                              .textTheme.navTitleTextStyle
                                              .copyWith(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w300)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                verticalSpaceMedium,
                referralArgs.referral.referralDetailDto!.isEmpty
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                'No Data Found',
                                style: kIsWeb || Platform.isAndroid
                                    ? AppTheme.lightTheme.textTheme.bodyMedium!
                                        .copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w300)
                                    : AppThemeCupertino
                                        .lightTheme.textTheme.navTitleTextStyle
                                        .copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w300),
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount:
                                referralArgs.referral.referralDetailDto!.length,
                            itemBuilder: (context, index) {
                              //convert the followings object to local Object
                              ReferralDetailDto referralDetailDto = referralArgs
                                  .referral.referralDetailDto![index];
                              //convert the followings object to local Object

                              return Column(
                                children: [
                                  ReferralDetailViewItem(
                                    referral: referralDetailDto,
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              );
                            }),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
