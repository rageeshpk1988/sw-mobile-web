import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../src/models/socialaccesstoken_response.dart';
import '../helpers/connectivity_helper.dart';
import '/src/models/ad_response.dart';
import '/src/models/login_response.dart';
import '/src/profile/screens/profile.dart';
import '/util/shopify_utils.dart';

import 'kyc_utils.dart';

class CustomCupertinoNavigationBarNew extends StatelessWidget {
  final bool? showShopifyHomeButton;
  final bool? showShopifyCartButton;
  final bool? showKycButton;
  final bool? showProfileButton;
  final bool showHamburger; //THIS IS TO BE REMOVED
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
  CustomCupertinoNavigationBarNew({
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
  // @override
  // Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      padding: EdgeInsetsDirectional.only(start: 0),
      border: Border(
        bottom: BorderSide(
          width: 0,
          color: Colors.white,
          //style: BorderStyle.solid,
        ),
      ),
      automaticallyImplyLeading: disableBackButton == true ? false:true,
      //automaticallyImplyMiddle: false,
      // leading: showHamburger
      //     ? GestureDetector(
      //         onTap: () => scaffoldKey!.currentState!.openDrawer(),
      //         child: Padding(
      //           padding: const EdgeInsets.only(left: 8.0, right: 5.0),
      //           child: Image.asset('assets/icons/ic_drawer_open.png',
      //               width: 25, height: 25),
      //         ),
      //       )
      //     : GestureDetector(
      //         onTap: () {
      //           Navigator.of(context).pop();
      //         },
      //         child: Icon(CupertinoIcons.back, color: Color(0xFFED247C)),
      //       ),
      leading: disableBackButton != true ? GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Icon(CupertinoIcons.back, color: Color(0xFFED247C)),
      ):null,
      middle: title == null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset('assets/images/sw_appbar_logo.png', height: 25),
                Spacer()
              ],
            )
          : Text(
              title!,
              style: TextStyle(color: Colors.black),
            ),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //SizedBox(width: 20),
            if (showShopifyHomeButton!)
              GestureDetector(
                onTap: () => ShopifyUtils.launchShopifyHome(
                    context,
                    adResponse,
                    updateHandler!,
                    socialUpdateHandler!,
                    socialAccessTokenResponse),
                child: Image.asset('assets/icons/shopify.png',
                    fit: BoxFit.scaleDown, width: 30, height: 30),
              ),
            if (showShopifyHomeButton!) const SizedBox(width: 10),
            if (showShopifyCartButton!)
              GestureDetector(
                onTap: () => ShopifyUtils.launchShopifyCart(
                    context,
                    adResponse,
                    updateHandler!,
                    socialUpdateHandler!,
                    socialAccessTokenResponse),
                child: Image.asset('assets/icons/cart.png',
                    fit: BoxFit.scaleDown, width: 30, height: 30),
              ),
            if (showShopifyCartButton!) const SizedBox(width: 10),
            if (showKycButton!)
              GestureDetector(
                onTap: () =>
                    KycUtils.launchKycScreen(context, loginResponse, kycStatus),
                child: kycStatus == 1
                    ? Image.asset('assets/icons/tick-1.png',
                        fit: BoxFit.scaleDown, width: 30, height: 30)
                    : Image.asset('assets/icons/tick-2.png',
                        fit: BoxFit.scaleDown, width: 30, height: 30),
              ),
            if (showKycButton!) const SizedBox(width: 10),
            if (showProfileButton!)
              GestureDetector(
                onTap: () async {
                  if (await ConnectivityHelper.hasInternet(
                          context, ProfileScreen.routeName, null) ==
                      true) {
                    Navigator.of(context).pushNamed(ProfileScreen.routeName);
                  }
                },
                child: adResponse == null
                    ? Image.asset('assets/icons/b2c_profile.png',
                        fit: BoxFit.scaleDown, width: 30, height: 30)
                    : Image.asset('assets/icons/b2c_profile_filled.png',
                        fit: BoxFit.scaleDown, width: 30, height: 30),
              ),
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
        ),
      ),
    );
  }
}
