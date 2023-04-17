import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '/src/models/socialaccesstoken_response.dart';
import '/util/custom_appbar_new.dart';
import '/util/custom_cupertinonavigationbar_new.dart';
import '/src/models/ad_response.dart';
import '/src/models/login_response.dart';

class AdaptiveCustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool? showShopifyHomeButton;
  final bool? showShopifyCartButton;
  final bool? showKycButton;
  final bool? showProfileButton;
  final bool showHamburger;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final ADResponse? adResponse;
  final SocialAdResponse? socialAccessTokenResponse;
  final LoginResponse? loginResponse;
  final int? kycStatus;
  final Function? updateHandler;
  final Function? socialUpdateHandler;
  final String? title;
  final bool? showMascot;
  final bool? disableBackButton;
  const AdaptiveCustomAppBar({
    @required this.showShopifyHomeButton,
    @required this.showShopifyCartButton,
    @required this.showKycButton,
    @required this.showProfileButton,
    required this.showHamburger,
    @required this.scaffoldKey,
    @required this.adResponse,
    @required this.loginResponse,
    @required this.updateHandler,
    this.kycStatus,
    this.socialAccessTokenResponse,
    this.socialUpdateHandler,
    this.title,
    this.showMascot,
    this.disableBackButton,
  });
  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return kIsWeb || Platform.isAndroid
        ? CustomAppBarNew(
            showShopifyHomeButton: showShopifyHomeButton,
            showShopifyCartButton: showShopifyCartButton,
            showKycButton: showKycButton,
            showProfileButton: showProfileButton,
            showHamburger: showHamburger,
            scaffoldKey: scaffoldKey,
            adResponse: adResponse,
            socialAccessTokenResponse: socialAccessTokenResponse,
            loginResponse: loginResponse,
            kycStatus: kycStatus,
            updateHandler: updateHandler,
            socialUpdateHandler: socialUpdateHandler,
            title: title,
            showMascot: showMascot,
            disableBackButton:disableBackButton
          )
        : CustomCupertinoNavigationBarNew(
            showShopifyHomeButton: showShopifyHomeButton,
            showShopifyCartButton: showShopifyCartButton,
            showKycButton: showKycButton,
            showProfileButton: showProfileButton,
            showHamburger: showHamburger,
            scaffoldKey: scaffoldKey,
            adResponse: adResponse,
            socialAccessTokenResponse: socialAccessTokenResponse,
            loginResponse: loginResponse,
            kycStatus: kycStatus,
            updateHandler: updateHandler,
            socialUpdateHandler: socialUpdateHandler,
            title: title,
            showMascot: showMascot,
            disableBackButton:disableBackButton
          );
  }
}
