import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/src/login/screens/login_with_pass_web.dart';

import '../webviews/webview_shop.dart';

import '../../src/models/socialaccesstoken_response.dart';
import '../src/providers/auth.dart';
import '../helpers/global_variables.dart';
import '../helpers/route_arguments.dart';

import '../src/login/screens/login_with_pass.dart';
import '../src/models/ad_response.dart';
import '../webviews/webview_shop_web.dart';

/*
   All shopify related functions
 */
class ShopifyUtils {
  static void launchShopifyHome(
    BuildContext context,
    ADResponse? adResponse,
    Function updateHandler,
    Function socialUpdateHandler,
    SocialAdResponse? socialAccessTokenResponse,
  ) async {
    String mobileNumber =
        Provider.of<Auth>(context, listen: false).loginResponse.mobileNumber;

    if (adResponse == null && socialAccessTokenResponse == null) {
      Navigator.of(context).pushNamed(LoginWithPassword.routeName,
          arguments: LoginWithPasswordArgs(
              true, mobileNumber, updateHandler, socialUpdateHandler, true));
    } else {
      var _shopifyHome = adResponse == null
          ? 'https://store.xecurify.com/moas/broker/login/jwt/callback/20959/jwtsso/${socialAccessTokenResponse!.token}?relay=https://store.xecurify.com/moas/broker/login/shopify/${GlobalVariables.shopify_AccountDomain}/account?redirect_endpoint=index'
          : 'https://store.xecurify.com/moas/broker/login/jwt/callback/20959/jwtsso/${adResponse.idToken}?relay=https://store.xecurify.com/moas/broker/login/shopify/${GlobalVariables.shopify_AccountDomain}/account?redirect_endpoint=index';
      //  print(_shopifyHome);

      if (kIsWeb) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewShopifyWeb(
                  initialUrl: _shopifyHome,
                  updateHandler: updateHandler,
                  socialUpdateHandler:
                      socialUpdateHandler)), // updateSocialADData)),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewShopify(
                  initialUrl: _shopifyHome,
                  updateHandler: updateHandler,
                  socialUpdateHandler:
                      socialUpdateHandler)), // updateSocialADData)),
        );
      }

      // WebViewExample(initialUrl: _shopifyHome);

      //UrlLauncher.launchURL(_shopifyHome);
    }
  }

  static void launchShopifyCart(
      BuildContext context,
      ADResponse? adResponse,
      Function updateHandler,
      Function socialUpdateHandler,
      SocialAdResponse? socialAccessTokenResponse,
      {bool web = false}) async {
    String mobileNumber =
        Provider.of<Auth>(context, listen: false).loginResponse.mobileNumber;

    if (adResponse == null && socialAccessTokenResponse == null) {
      if (web) {
        Navigator.of(context).pushNamed(LoginWithPasswordWeb.routeName,
            arguments: LoginWithPasswordArgs(
                true, mobileNumber, updateHandler, socialUpdateHandler, true));
      } else {
        Navigator.of(context).pushNamed(LoginWithPassword.routeName,
            arguments: LoginWithPasswordArgs(
                true, mobileNumber, updateHandler, socialUpdateHandler, true));
      }
    } else {
      var _shopifyCart = adResponse == null
          ? 'https://store.xecurify.com/moas/broker/login/jwt/callback/20959/jwtsso/${socialAccessTokenResponse!.token}?relay=https://store.xecurify.com/moas/broker/login/shopify/${GlobalVariables.shopify_AccountDomain}/account?redirect_endpoint=index'
          : 'https://store.xecurify.com/moas/broker/login/jwt/callback/20959/jwtsso/${adResponse.idToken}?relay=https://store.xecurify.com/moas/broker/login/shopify/${GlobalVariables.shopify_AccountDomain}/account?redirect_endpoint=index';
      // print(_shopifyCart);
      if (kIsWeb) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewShopifyWeb(
                  initialUrl: _shopifyCart,
                  updateHandler: updateHandler,
                  socialUpdateHandler:
                      socialUpdateHandler)), // updateSocialADData)),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewShopify(
                  initialUrl: _shopifyCart,
                  updateHandler: updateHandler,
                  socialUpdateHandler:
                      socialUpdateHandler)), // updateSocialADData)),
        );
      }

      // WebViewExample(initialUrl: _shopifyCart);

      // UrlLauncher.launchURL(_shopifyCart);
    }
  }
}
