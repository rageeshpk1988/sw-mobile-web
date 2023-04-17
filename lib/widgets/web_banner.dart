/**Banner for Web UI */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '/src/home/child/screens/child_transformation_web.dart';
import '/src/home/feeds/screens/new_feeds_web.dart';

import '/src/invite_friend/screens/refer_friend_web.dart';
import '/src/profile/screens/profile_web.dart';
import '/src/subscription/screens/mysubscriptionplan_web.dart';
import '/src/subscription/screens/subscriptionplans_web.dart';

import '../adaptive/adaptive_theme.dart';
import '../helpers/connectivity_helper.dart';
import '../helpers/global_variables.dart';
import '../helpers/route_arguments.dart';
import '../webviews/webview_support.dart';

import '../src/models/login_response.dart';
import '../src/models/parent_subscription.dart';

import '../src/providers/auth.dart';
import '../src/providers/subscriptions.dart';

import '../util/app_theme.dart';
import '../util/dialogs.dart';
import '../util/kyc_utils.dart';
import '../util/shopify_utils.dart';
import '../util/ui_helpers.dart';
import '../webviews/webview_support_web.dart';

class WebBanner extends StatelessWidget {
  final bool showMenu;
  final bool showHomeButton;
  final bool showProfileButton;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const WebBanner({
    this.showMenu = false,
    this.showHomeButton = false,
    this.showProfileButton = false,
    required this.scaffoldKey,
    Key? key,
  }) : super(key: key);

  Future<bool> verifySubscriptionPackage(
      BuildContext context, LoginResponse loginResponse) async {
    late ParentSubscriptionGroup? parentSubscription;
    bool retValue = false;
    var parentId = loginResponse.b2cParent!.parentID;
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

    return retValue;
  }

  @override
  Widget build(BuildContext context) {
    late LoginResponse loginResponse;
    final double _menuGap = 20.0;
    var deviceSize = MediaQuery.of(context).size;
    int? kycStatus;
    if (showMenu) {
      loginResponse = Provider.of<Auth>(context, listen: true).loginResponse;
      kycStatus = Provider.of<Auth>(context, listen: true).kycResponse;
    }

    Text _menuTitle(String title) => Text(title,
        style: AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
            fontSize: 14, fontWeight: FontWeight.w300, letterSpacing: 0.0));

    Widget _lastMenuItems() {
      List<Widget> _menuItem = [
        //PRODUCT AND SERVICES
        GestureDetector(
          child: _menuTitle("Products & Services"),
          onTap: () async {
            var _adResponse =
                Provider.of<Auth>(context, listen: false).adResponse;
            var _socialAccessTokenResponse =
                Provider.of<Auth>(context, listen: false)
                    .socialAccessTokenResponse;
            ShopifyUtils.launchShopifyCart(
                context, _adResponse, () {}, () {}, _socialAccessTokenResponse,
                web: true);
          },
        ),
        //PRODUCT AND SERVICES
        SizedBox(width: _menuGap),
        //MY SUBSCRIPTION
        GestureDetector(
          child: _menuTitle('My Subscription'),
          onTap: () async {
            if (await ConnectivityHelper.hasInternet(
                    context, MySubscriptionPlanScreenWeb.routeName, null) ==
                true) {
              if (await verifySubscriptionPackage(context, loginResponse) ==
                  false) {
                Navigator.of(context)
                    .pushNamed(SubscriptionPlansScreenWeb.routeName);
              } else {
                Navigator.of(context)
                    .pushNamed(MySubscriptionPlanScreenWeb.routeName);
              }
            }
          },
        ),
        //MY SUBSCRIPTION
        SizedBox(width: _menuGap),
        //HELP AND SUPPORT
        GestureDetector(
          child: _menuTitle("Help & Support"),
          onTap: () {
            if (kIsWeb) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WebViewSupportWeb(
                          initialUrl: GlobalVariables.supportPageUrl,
                        )),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WebViewSupport(
                          initialUrl: GlobalVariables.supportPageUrl,
                        )),
              );
            }
          },
        ),
        //HELP AND SUPPORT
      ];

      return Row(
        children: _menuItem,
      );
    }

    Widget _desktopView() {
      return SizedBox(
        width: screenWidth(context) * 0.98,
        child: Padding(
          padding: const EdgeInsets.only(left: 5.0, top: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/');
                    },
                    child: Image.asset(
                      'assets/images/sw_appbar_logo.png',
                      width: deviceSize.width *
                          (screenWidth(context) > 1000 ? 0.12 : 0.35),
                      height: deviceSize.height *
                          (screenWidth(context) > 1000 ? 0.1 : 0.3),
                    ),
                  ),
                ],
              ),
              if (showMenu)
                Padding(
                  padding: const EdgeInsets.only(right: 32.0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              //HOME ICON
                              if (showHomeButton)
                                GestureDetector(
                                  child: SvgPicture.asset(
                                      "assets/icons/homepag_filled.svg",
                                      color: AdaptiveTheme.secondaryColor(
                                          context)),
                                  onTap: () {
                                    Navigator.of(context).pushNamed('/');
                                  },
                                ),
                              //HOME ICON
                              if (showHomeButton) SizedBox(width: _menuGap),
                              //CHILD TRANSFORMATION
                              GestureDetector(
                                child: _menuTitle("Child's Transformation"),
                                onTap: () async {
                                  var _loginResponse =
                                      Provider.of<Auth>(context, listen: false)
                                          .loginResponse;
                                  Provider.of<Auth>(context, listen: false)
                                      .setInitialChild();
                                  if (await ConnectivityHelper.hasInternet(
                                          context,
                                          ChildTransformationScreenWeb
                                              .routeName,
                                          null) ==
                                      true) {
                                    if (_loginResponse
                                            .b2cParent!.childDetails!.length <
                                        1) {
                                      Dialogs().noChildPopup(context, null,
                                          isWeb: true);
                                    } else {
                                      Navigator.of(context).pushNamed(
                                          ChildTransformationScreenWeb
                                              .routeName);
                                    }
                                  }
                                },
                              ),
                              //CHILD TRANSFORMATION
                              SizedBox(width: _menuGap),
                              //REFER AND EARN
                              GestureDetector(
                                child: _menuTitle('Refer & Earn'),
                                onTap: () async {
                                  if (await ConnectivityHelper.hasInternet(
                                          context,
                                          ReferFriendWeb.routeName,
                                          ReferralArgs(false)) ==
                                      true) {
                                    Navigator.of(context).pushNamed(
                                        ReferFriendWeb.routeName,
                                        arguments: ReferralArgs(false));
                                  }
                                },
                              ),
                              SizedBox(width: _menuGap),
                              GestureDetector(
                                child: _menuTitle("Parents' Wall"),
                                onTap: () async {
                                  if (await ConnectivityHelper.hasInternet(
                                          context,
                                          NewFeedScreenWeb.routeName,
                                          null) ==
                                      true) {
                                    Navigator.of(context)
                                        .pushNamed(NewFeedScreenWeb.routeName);
                                  }
                                },
                              ),
                              //REFER AND EARN
                              if (deviceSize.width > 1000)
                                SizedBox(width: _menuGap),

                              if (deviceSize.width > 1000) _lastMenuItems(),
                            ],
                          ),
                          if (deviceSize.width < 1000) _lastMenuItems(),
                        ],
                      ),
                      //PROFILE BUTTON
                      if (deviceSize.width > 1000) SizedBox(width: _menuGap),
                      if (showProfileButton && kycStatus != 1)
                        Align(
                          child: GestureDetector(
                            onTap: () => KycUtils.launchKycScreen(
                                context, loginResponse, kycStatus,
                                isWeb: true),
                            child: Container(
                              width: 78,
                              height: 30,
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  color: Colors.grey.shade100),
                              child: Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Text(
                                    'VERIFY',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall!
                                        .copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: kycStatus == 1
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      if (showProfileButton)
                        Stack(children: <Widget>[
                          IconButton(
                            icon: getAvatarImage(
                                loginResponse.b2cParent!.profileImage,
                                120,
                                120,
                                BoxShape.circle,
                                loginResponse.b2cParent!.name),
                            onPressed: () async {
                              if (await ConnectivityHelper.hasInternet(context,
                                      ProfileScreenWeb.routeName, null) ==
                                  true) {
                                Navigator.of(context)
                                    .pushNamed(ProfileScreenWeb.routeName);
                              }
                            },
                          ),
                          Positioned(
                            bottom: -3,
                            left:
                                5, //give the values according to your requirement
                            child: SizedBox(
                                width: 28,
                                height: 18,
                                child: kycStatus == 1
                                    ? Image.asset('assets/icons/reg_kyc.png')
                                    : Image.asset(
                                        'assets/icons/not_reg_kyc.png')),
                          ),
                        ]),
                      //PROFILE BUTTON
                    ],
                  ),
                )
            ],
          ),
        ),
      );
    }

    // return screenWidth(context) > 800
    //     ? _desktopView()
    //     : Padding(
    //         padding: const EdgeInsets.only(right: 16.0),
    //         child: IconButton(
    //             onPressed: () => scaffoldKey.currentState!.openEndDrawer(),
    //             icon: Icon(
    //               Icons.menu_rounded,
    //               size: 40,
    //             )),
    //       );
    return screenWidth(context) > 800
        ? _desktopView()
        : Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/images/sw_appbar_logo.png',
                    width: 110, height: 60),
                IconButton(
                    onPressed: () => scaffoldKey.currentState!.openEndDrawer(),
                    icon: Icon(
                      Icons.menu_rounded,
                      size: 40,
                    )),
              ],
            ),
          );
  }
}

class WebBannerDrawer extends StatelessWidget {
  final bool showMenu;
  final bool showHomeButton;
  final bool showProfileButton;
  const WebBannerDrawer({
    this.showMenu = false,
    this.showHomeButton = false,
    this.showProfileButton = false,
    Key? key,
  }) : super(key: key);

  Future<bool> verifySubscriptionPackage(
      BuildContext context, LoginResponse loginResponse) async {
    late ParentSubscriptionGroup? parentSubscription;
    bool retValue = false;
    var parentId = loginResponse.b2cParent!.parentID;
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

    return retValue;
  }

  @override
  Widget build(BuildContext context) {
    late LoginResponse loginResponse;

    int? kycStatus;
    //if (showMenu) {
    loginResponse = Provider.of<Auth>(context, listen: true).loginResponse;
    kycStatus = Provider.of<Auth>(context, listen: true).kycResponse;
    // }

    Text _menuTitle(String title) => Text(title,
        style: AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
            fontSize: 14, fontWeight: FontWeight.w300, letterSpacing: 0.0));

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          //if (showProfileButton)
          //HEADER PROFILE
          Container(
            height: 100,
            width: double.infinity,
            child: DrawerHeader(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    children: <Widget>[
                      Transform.scale(
                        scale: 1.5,
                        child: IconButton(
                          icon: getAvatarImage(
                              loginResponse.b2cParent!.profileImage,
                              100,
                              100,
                              BoxShape.circle,
                              loginResponse.b2cParent!.name),
                          onPressed: () async {
                            if (await ConnectivityHelper.hasInternet(context,
                                    ProfileScreenWeb.routeName, null) ==
                                true) {
                              Navigator.of(context)
                                  .pushNamed(ProfileScreenWeb.routeName);
                            }
                          },
                        ),
                      ),
                      Positioned(
                        bottom: -5,
                        left: 10,
                        child: SizedBox(
                            width: 35,
                            height: 35,
                            child: kycStatus == 1
                                ? Image.asset('assets/icons/reg_kyc.png')
                                : Image.asset('assets/icons/not_reg_kyc.png')),
                      ),
                    ],
                  ),
                  if (kycStatus != 1)
                    GestureDetector(
                      onTap: () => KycUtils.launchKycScreen(
                          context, loginResponse, kycStatus,
                          isWeb: true),
                      child: Container(
                        width: screenWidth(context) *
                            (screenWidth(context) > 400 ? 0.18 : 0.25),
                        height: screenHeight(context) * 0.04,
                        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.grey.shade100),
                        child: Center(
                          child: Text(
                            'VERIFY',
                            style: AppTheme.lightTheme.textTheme.bodySmall!
                                .copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: kycStatus == 1 ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              decoration: BoxDecoration(
                color: AdaptiveTheme.primaryColor(context),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black45,
                    offset: Offset(0, 10),
                  )
                ],
              ),
            ),
          ),
          //HEADER PROFILE
          // if (showHomeButton)
          //HOME
          ListTile(
            title: _menuTitle("Home"),
            onTap: () {
              Navigator.of(context).pushNamed('/');
            },
          ),
          //HOME
          Divider(),
          //CHILD TRANSFORMATION
          ListTile(
            title: _menuTitle("Child's Transformation"),
            onTap: () async {
              var _loginResponse =
                  Provider.of<Auth>(context, listen: false).loginResponse;
              Provider.of<Auth>(context, listen: false).setInitialChild();
              if (await ConnectivityHelper.hasInternet(
                      context, ChildTransformationScreenWeb.routeName, null) ==
                  true) {
                if (_loginResponse.b2cParent!.childDetails!.length < 1) {
                  Dialogs().noChildPopup(context, null, isWeb: true);
                } else {
                  Navigator.of(context)
                      .pushNamed(ChildTransformationScreenWeb.routeName);
                }
              }
            },
          ),
          //CHILD TRANSFORMATION
          Divider(),
          //REFER AND EARN
          ListTile(
            title: _menuTitle('Refer & Earn'),
            onTap: () async {
              if (await ConnectivityHelper.hasInternet(
                      context, ReferFriendWeb.routeName, ReferralArgs(false)) ==
                  true) {
                Navigator.of(context).pushNamed(ReferFriendWeb.routeName,
                    arguments: ReferralArgs(false));
              }
            },
          ),
          //REFER AND EARN
          Divider(),
          //PARENTS WALL
          ListTile(
            title: _menuTitle("Parents' Wall"),
            onTap: () async {
              if (await ConnectivityHelper.hasInternet(
                      context, NewFeedScreenWeb.routeName, null) ==
                  true) {
                Navigator.of(context).pushNamed(NewFeedScreenWeb.routeName);
              }
            },
          ),
          //PARENTS WALL
          Divider(),
          //PRODUCT AND SERVICES
          ListTile(
            title: _menuTitle("Products & Services"),
            onTap: () async {
              var _adResponse =
                  Provider.of<Auth>(context, listen: false).adResponse;
              var _socialAccessTokenResponse =
                  Provider.of<Auth>(context, listen: false)
                      .socialAccessTokenResponse;
              ShopifyUtils.launchShopifyCart(context, _adResponse, () {}, () {},
                  _socialAccessTokenResponse,
                  web: true);
            },
          ),
          //PRODUCT AND SERVICES
          Divider(),
          //MY SUBSCRIPTION
          ListTile(
            title: _menuTitle('My Subscription'),
            onTap: () async {
              if (await ConnectivityHelper.hasInternet(
                      context, MySubscriptionPlanScreenWeb.routeName, null) ==
                  true) {
                if (await verifySubscriptionPackage(context, loginResponse) ==
                    false) {
                  Navigator.of(context)
                      .pushNamed(SubscriptionPlansScreenWeb.routeName);
                } else {
                  Navigator.of(context)
                      .pushNamed(MySubscriptionPlanScreenWeb.routeName);
                }
              }
            },
          ),
          //MY SUBSCRIPTION
          Divider(),
          //HELP AND SUPPORT
          ListTile(
            title: _menuTitle("Help & Support"),
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WebViewSupportWeb(
                          initialUrl: GlobalVariables.supportPageUrl,
                        )),
              );
            },
          ),
          //HELP AND SUPPORT
        ],
      ),
    );
  }
}
