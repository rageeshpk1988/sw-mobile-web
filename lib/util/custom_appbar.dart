import 'package:flutter/material.dart';
import '../src/models/login_response.dart';
import '../src/models/socialaccesstoken_response.dart';
import '../src/models/ad_response.dart';
import '../src/profile/screens/profile.dart';
import '../util/shopify_utils.dart';
import 'kyc_utils.dart';

/*Custom Material AppBar */
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
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

  CustomAppBar({
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
  });
  @override
  Size get preferredSize => const Size.fromHeight(60.0);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: showHamburger
          ? IconButton(
              icon: Image.asset(
                'assets/icons/ic_drawer_open.png',
                width: 25,
                height: 25,
              ),
              onPressed: () => scaffoldKey!.currentState!.openDrawer(),
            )
          : null,
      elevation: 5.0,
      title: Image.asset('assets/images/sw_appbar_logo.png', height: 25),
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
        if (showKycButton!)
          IconButton(
            icon: kycStatus == 1
                ? Image.asset('assets/icons/tick-1.png')
                : Image.asset('assets/icons/tick-2.png'),
            onPressed: () =>
                KycUtils.launchKycScreen(context, loginResponse, kycStatus),
          ),
        if (showProfileButton!)
          IconButton(
            icon: adResponse == null && socialAccessTokenResponse == null
                ? Image.asset('assets/icons/b2c_profile.png')
                : Image.asset('assets/icons/b2c_profile_filled.png'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(),
                ),
              );
            },
          ),
      ],
      centerTitle: false,
    );
  }
}
