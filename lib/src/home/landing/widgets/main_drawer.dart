import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '/adaptive/adaptive_theme.dart';
import '/helpers/route_arguments.dart';

import '../../../../helpers/global_variables.dart';
import '../../../../util/app_theme_cupertino.dart';

import '../../../../helpers/connectivity_helper.dart';

import '../../../../webviews/webview_support.dart';
import '../../../../util/dialogs.dart';
import '../../../../util/shopify_utils.dart';

import '../../../invite_friend/screens/refer_friend.dart';
import '../../../models/parent_subscription.dart';

import '../../../providers/auth.dart';
import '../../../providers/subscriptions.dart';
import '../../../subscription/screens/mySubscriptionPlan.dart';
import '../../../subscription/screens/subcriptionsPlans.dart';
import '../../child/screens/child_transformation.dart';
import '../../feeds/screens/new_feeds.dart';
import '../screens/coorporate_video_screen.dart';
import '/src/profile/screens/profile.dart';

import '/util/app_theme.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double _iconSize = 24;

    Text _menuTitle(String title) => Text(
          title,
          style: kIsWeb || Platform.isAndroid
              ? AppTheme.lightTheme.textTheme.bodySmall!
                  .copyWith(fontSize: 15, fontWeight: FontWeight.w300)
              : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
                  .copyWith(fontSize: 15, fontWeight: FontWeight.w300),
        );
    Future<bool> verifySubscriptionPackage() async {
      late ParentSubscriptionGroup? parentSubscription;
      bool retValue = false;
      var loginResponse =
          Provider.of<Auth>(context, listen: false).loginResponse;

      var parentId = loginResponse.b2cParent!.parentID;
      //var authToken = loginResponse.token;
      try {
        parentSubscription =
            await Provider.of<Subscriptions>(context, listen: false)
                .listParentSubscription(parentId);
        if (parentSubscription.currentPlan.packageId != 0) {
          retValue = true;
        } else {
          retValue = false;
        }
      } catch (e) {
        retValue = false;
      }
      // parentSubscription =
      //     await Provider.of<Subscriptions>(context, listen: false)
      //         .listParentSubscription(parentId, authToken)
      //         .then((value) {
      //   if (value.packageId != 0) {
      //     retValue = true;
      //   }
      // }).onError((error, stackTrace) {
      //   retValue = false;
      // });
      return retValue;
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: 100,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/sw_appbar_logo.png',
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: SvgPicture.asset(
              'assets/icons/profile_icon.svg',
              color: AppTheme.primaryColor,
              height: _iconSize,
              width: _iconSize,
            ), //Icon(Icons.account_circle, size: _iconSize, color: AppTheme.primaryColor),
            title: _menuTitle('Profile'),
            onTap: () async {
              if (await ConnectivityHelper.hasInternet(
                      context, ProfileScreen.routeName, null) ==
                  true) {
                Navigator.of(context).pushNamed(ProfileScreen.routeName);
              }
            },
          ),
          Divider(),
          ListTile(
            leading: SvgPicture.asset(
              'assets/icons/student_transformation_icon.svg',
              color: AppTheme.primaryColor,
              height: _iconSize,
              width: _iconSize,
            ), //Icon(Icons.analytics, size: _iconSize, color: AppTheme.primaryColor,),
            title: _menuTitle("Child's Transformation"),
            onTap: () async {
              var _loginResponse =
                  Provider.of<Auth>(context, listen: false).loginResponse;
              Provider.of<Auth>(context, listen: false).setInitialChild();
              if (await ConnectivityHelper.hasInternet(
                      context, ChildTransformationScreen.routeName, null) ==
                  true) {
                if (_loginResponse.b2cParent!.childDetails!.length < 1) {
                  Dialogs().noChildPopup(context, null);
                } else {
                  Navigator.of(context).pushNamed(
                      //ChildTransformationScreen.routeName
                      ChildTransformationScreen.routeName);
                }
              }
            },
          ),
          Divider(),
          ListTile(
            leading: SvgPicture.asset(
              'assets/icons/refer_and_earn.svg',
              color: AppTheme.primaryColor,
              height: _iconSize,
              width: _iconSize,
            ), //Icon(Icons.person, size: _iconSize, color: AppTheme.primaryColor,),
            title: _menuTitle('Refer & Earn'),
            onTap: () async {
              if (await ConnectivityHelper.hasInternet(
                      context, ReferFriend.routeName, ReferralArgs(false)) ==
                  true) {
                Navigator.of(context).pushNamed(ReferFriend.routeName,
                    arguments: ReferralArgs(false));
              }
            },
          ),
          Divider(),
          ListTile(
            leading: SvgPicture.asset(
              'assets/icons/parents_wall.svg',
              color: AppTheme.primaryColor,
              height: _iconSize,
              width: _iconSize,
            ), //Icon(Icons.person_add,size: _iconSize,color: AppTheme.primaryColor,),
            title: _menuTitle("Parents' Wall"),
            onTap: () async {
              if (await ConnectivityHelper.hasInternet(
                      context, NewFeedScreen.routeName, null) ==
                  true) {
                Navigator.of(context).pushNamed(NewFeedScreen.routeName);
              }
            },
          ),
          Divider(),
          ListTile(
            leading: SvgPicture.asset(
              'assets/icons/products_and_services.svg',
              color: AppTheme.primaryColor,
              height: _iconSize,
              width: _iconSize,
            ), //Icon(Icons.person_add,size: _iconSize,color: AppTheme.primaryColor,),
            title: _menuTitle("Products & Services"),
            onTap: () async {
              var _adResponse =
                  Provider.of<Auth>(context, listen: false).adResponse;
              var _socialAccessTokenResponse =
                  Provider.of<Auth>(context, listen: false)
                      .socialAccessTokenResponse;
              ShopifyUtils.launchShopifyCart(context, _adResponse, () {}, () {},
                  _socialAccessTokenResponse);
            },
          ),
          Divider(),
          ListTile(
            leading: SvgPicture.asset(
              'assets/icons/subscription_icon.svg',
              color: AppTheme.primaryColor,
              height: _iconSize,
              width: _iconSize,
            ), //Icon(Icons.notification_add,size: _iconSize,color: AppTheme.primaryColor,),
            title: _menuTitle('My Subscription'),
            onTap: () async {
              if (await ConnectivityHelper.hasInternet(
                      context, MySubscriptionPlanScreen.routeName, null) ==
                  true) {
                // LoginResponse loginResponse =
                //     Provider.of<Auth>(context, listen: false).loginResponse;

                // if (loginResponse.currentPackageStatus.toLowerCase() == 'no') {
                if (await verifySubscriptionPackage() == false) {
                  //show the info message
                  // await _showNoPackagePopup(loginResponse.b2cParent!.name);
                  //show plans list
                  Navigator.of(context)
                      .pushNamed(SubscriptionPlansScreen.routeName);
                } else {
                  Navigator.of(context)
                      .pushNamed(MySubscriptionPlanScreen.routeName);
                }
              }
            },
          ),
          Divider(),
          ListTile(
            leading: SvgPicture.asset(
              'assets/icons/help_and_support.svg',
              color: AppTheme.primaryColor,
              height: _iconSize,
              width: _iconSize,
            ), //Icon(Icons.person_add,size: _iconSize,color: AppTheme.primaryColor,),
            title: _menuTitle("Help & Support"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WebViewSupport(
                          initialUrl: GlobalVariables.supportPageUrl,
                        )),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.video_library_outlined,
              size: _iconSize,
              color: AdaptiveTheme.primaryColor(context),
            ),
            title: _menuTitle("Corporate Video"),
            onTap: () async {
              if (await ConnectivityHelper.hasInternet(
                      context, CorporateVideoScreen.routeName, null) ==
                  true) {
                Navigator.of(context).pushNamed(CorporateVideoScreen.routeName);
              }
            },
          ),
          /* Divider(),
          ListTile(
            leading: Icon(
              Icons.info_outline,
              size: _iconSize,
              color: AdaptiveTheme.primaryColor(context),
            ),
            title: _menuTitle("Staging v10"),
            onTap: ()  {

            },
          ),*/
        ],
      ),
    );
  }
}
