import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../util/ui_helpers.dart';
import '../helpers/connectivity_helper.dart';
import '/src/models/login_response.dart';
import '/src/models/socialaccesstoken_response.dart';
import '../src/models/ad_response.dart';
import '../src/profile/screens/profile.dart';
import '../util/shopify_utils.dart';
import 'app_theme.dart';

import 'app_theme_cupertino.dart';
import 'kyc_utils.dart';

/*Custom Material AppBar */
class CustomAppBarNew extends StatelessWidget implements PreferredSizeWidget {
  final bool? showShopifyHomeButton;
  final bool? showShopifyCartButton;
  final bool? showKycButton;
  final bool? showProfileButton;
  final bool showHamburger; //TODO This is to be removed
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

  CustomAppBarNew({
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
    this.disableBackButton
  });
  @override
  Size get preferredSize => const Size.fromHeight(60.0);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: disableBackButton == true ? false:true,
      elevation: 0.0,
      title: title == null
          ? Image.asset('assets/images/sw_appbar_logo.png', height: 25)
          : Text(
              title!,
              style: AppTheme.lightTheme.textTheme.titleLarge!
                  .copyWith(fontSize: 20, fontWeight: FontWeight.w500),
            ),
      actions: [
        if (showShopifyHomeButton!)
          IconButton(
            icon: Image.asset('assets/icons/shopify.png'),
            onPressed: () => ShopifyUtils.launchShopifyCart(
                context,
                adResponse,
                updateHandler!,
                socialUpdateHandler!,
                socialAccessTokenResponse),
          ),
        if (showShopifyCartButton!)
          IconButton(
            icon: Image.asset('assets/icons/cart.png'),
            onPressed: () => ShopifyUtils.launchShopifyCart(
                context,
                adResponse,
                updateHandler!,
                socialUpdateHandler!,
                socialAccessTokenResponse),
          ),
        // if (showKycButton!)
        //   IconButton(
        //     icon: kycStatus == 1
        //         ? Image.asset('assets/icons/tick-1.png')
        //         : Image.asset('assets/icons/tick-2.png'),
        //     onPressed: () =>
        //         KycUtils.launchKycScreen(context, loginResponse, kycStatus),
        //   ),
        if (showKycButton!)
          if (kycStatus != 1)
            Align(
              child: GestureDetector(
                onTap: () =>
                    KycUtils.launchKycScreen(context, loginResponse, kycStatus),
                child: Container(
                  width: 78,
                  height: 30,
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.grey.shade100),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Text(
                        'VERIFY',
                        style: kIsWeb || Platform.isAndroid
                            ? AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color:
                                    kycStatus == 1 ? Colors.green : Colors.red,
                              )
                            : AppThemeCupertino
                                .lightTheme.textTheme.navTitleTextStyle
                                .copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color:
                                    kycStatus == 1 ? Colors.green : Colors.red,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        if (showProfileButton!)
          Stack(children: <Widget>[
            IconButton(
              icon: getAvatarImage(loginResponse!.b2cParent!.profileImage, 100,
                  100, BoxShape.circle, loginResponse!.b2cParent!.name),
              // icon: adResponse == null && socialAccessTokenResponse == null
              //     ? Image.asset('assets/icons/b2c_profile.png')
              //     : Image.asset('assets/icons/b2c_profile_filled.png'),
              onPressed: () async {
                if (await ConnectivityHelper.hasInternet(
                        context, ProfileScreen.routeName, null) ==
                    true) {
                  Navigator.of(context).pushNamed(ProfileScreen.routeName);
                }
              },
            ),
            Positioned(
              bottom: 10,
              left: 18, //give the values according to your requirement
              child: SizedBox(
                  width: 28,
                  height: 18,
                  child: kycStatus == 1
                      ? Image.asset('assets/icons/reg_kyc.png')
                      : Image.asset('assets/icons/not_reg_kyc.png')),
            ),
          ]),
        if (showMascot != null)
          if (showMascot == true)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Image.asset(
                'assets/images/Mascot.png',
                width: 38,
                height: 38,
              ),
            )
      ],
      centerTitle: false,
    );
  }
}
