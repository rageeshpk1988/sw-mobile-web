import 'dart:io';
//import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:provider/provider.dart';
import '/util/app_theme.dart';
import '../../../helpers/route_arguments.dart';
import '../../../src/models/firestore/followingparents.dart';
import '../../../util/app_theme_cupertino.dart';

import '../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../adaptive/adaptive_custom_appbar.dart';
import '../../../adaptive/adaptive_theme.dart';
import '../../../helpers/connectivity_helper.dart';
import '../../home/new_post/new_post.dart';
import '/src/home/feeds/screens/user_feeds.dart';

import '/src/providers/firestore_services.dart';

import '../../../src/providers/auth.dart';
import '../../../src/profile/screens/add_child.dart';
import '../../../src/profile/screens/profile_update.dart';
import '../../../src/models/login_response.dart';
import '../../../src/profile/widgets/child_list_item.dart';
import '../../../src/profile/widgets/profile_hori_list_item.dart';
import '../../../util/ui_helpers.dart';
import '../../../widgets/round_rect_action_button.dart';
import 'followers_screen.dart';
import 'following_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  static String routeName = '/profile';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  LoginResponse? _loginResponse;
  var _isInIt = true;
  Future? vendorsLoaded;
  //var _isLoading = false;
  @override
  void didChangeDependencies() {
    if (_isInIt) {
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

  void refreshPage() {
    setState(() {
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        title: "Parent's Profile",
        showMascot: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              // Text(
              //   'Profile',
              //   style: Theme.of(context).textTheme.headline5,
              // ),
              // verticalSpaceSmall,
              ProfileHeaderSection(refreshPage),
              verticalSpaceMedium,
              //CHILD DETAILS
              Container(
                // decoration: BoxDecoration(
                //   color: Colors.grey[100],
                // ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(left: 2.0, right: 2.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _loginResponse!.b2cParent!.childDetails!.length,
                    itemBuilder: (BuildContext context, int i) {
                      return ChildListItem(
                          _loginResponse!.b2cParent!.childDetails![i],
                          refreshPage,
                          true);
                    },
                  ),
                ),
              ),

              verticalSpaceMedium,
              Padding(
                padding: const EdgeInsets.only(left: 7.0, right: 7.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(AddChildScreen.routeName,
                        arguments: refreshPage);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Add Child',
                        style: kIsWeb || Platform.isAndroid
                            ? AppTheme.lightTheme.textTheme.titleMedium!
                                .copyWith(
                                    color: HexColor.fromHex("#ED247C"),
                                    fontWeight: FontWeight.w400)
                            : AppThemeCupertino
                                .lightTheme.textTheme.navTitleTextStyle
                                .copyWith(
                                    color: HexColor.fromHex("#ED247C"),
                                    fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.add,
                        color: HexColor.fromHex("#ED247C"),
                      ),
                    ],
                  ),
                ),
              ),

              verticalSpaceMedium,
              ProfileMyVendorsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileHeaderSection extends StatefulWidget {
  final Function refreshHandler;
  ProfileHeaderSection(this.refreshHandler);
  @override
  State<ProfileHeaderSection> createState() => _ProfileHeaderSectionState();
}

class _ProfileHeaderSectionState extends State<ProfileHeaderSection> {
  LoginResponse? _loginResponse;
  int? _approvestatus;
  Future? resultsLoaded;
  int _followercount = 0;
  int _followingcount = 0;
  var _isInIt = true;

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
      _approvestatus = Provider.of<Auth>(context, listen: false).kycResponse;
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

  void viewRefresh() async {
    widget.refreshHandler();
    setState(() {
      // evictImage(_loginResponse!.b2cParent!.profileImage);
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
    });
    // WidgetsBinding.instance!.addPostFrameCallback((_) => setState(() async {
    //       _loginResponse =
    //           Provider.of<Auth>(context, listen: true).loginResponse;
    //     }));
  }
  /*void kycRefresh() async{
    setState(() async {
      // evictImage(_loginResponse!.b2cParent!.profileImage);
      _loginResponse = Provider.of<Auth>(context, listen: true).loginResponse;
      await Provider.of<User>(context, listen: false).getapproveStatus(_loginResponse!.b2cParent!.parentID).then((value) => _approvestatus = value);

    });
  }*/

  /*getapproveStatusKyc(int parentID) async {
    int? kycStatus;
    kycStatus = await Provider.of<User>(context, listen: false)
        .getapproveStatus(parentID);
    print(kycStatus);
    setState(() {
      _approvestatus = kycStatus;
    });
    return kycStatus;
  }*/

  @override
  Widget build(BuildContext context) {
    // var _engagementIndexViewTextStyle =
    //     Theme.of(context).textTheme.subtitle1?.apply(color: Colors.white);

    TextStyle _headerStyle(double fontSize, FontWeight fontWeight) {
      return kIsWeb || Platform.isAndroid
          ? AppTheme.lightTheme.textTheme.bodySmall!
              .copyWith(fontSize: fontSize, fontWeight: fontWeight)
          : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
              .copyWith(fontSize: fontSize, fontWeight: fontWeight);
    }

    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getAvatarImage(
                    _loginResponse == null
                        ? null
                        : _loginResponse!.b2cParent!.profileImage,
                    80,
                    80
                    //screenWidth(context) * 0.11,
                    ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        FittedBox(
                          child: Text(
                            _loginResponse == null
                                ? ' '
                                : _loginResponse!.b2cParent!.name,
                            style: _headerStyle(18, FontWeight.w600),
                          ),
                        ),
                        verticalSpaceSmall,
                        Text(
                          _loginResponse == null
                              ? ''
                              : _loginResponse!.b2cParent!.state!.toUpperCase(),
                          style: _headerStyle(12, FontWeight.w400),
                        ),
                        Text(
                          _loginResponse == null
                              ? ''
                              : _loginResponse!.b2cParent!.location!
                                  .toUpperCase(),
                          style: _headerStyle(12, FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ),
                RoundRectActionButton(
                  size: screenWidth(context) * 0.07,
                  iconData: Icons.edit_outlined,
                  onTap: () async {
                    if (await ConnectivityHelper.hasInternet<Function>(context,
                            ProfileUpdateScreen.routeName, viewRefresh) ==
                        true) {
                      Navigator.of(context).pushNamed(
                          ProfileUpdateScreen.routeName,
                          arguments: viewRefresh);
                    }
                  },
                ),
              ],
            ),
            // verticalSpaceTiny,
            // _kycStatusWidget(context),
            verticalSpaceSmall,
            // _engagementIndexWidget(context, _engagementIndexViewTextStyle),
            verticalSpaceSmall,
            _followCountWidget(context),
            verticalSpaceSmall,
          ],
        ),
      ),
    );
  }

//this has to be removed
  // _kycStatusWidget(BuildContext context) => Row(
  //       children: [
  //         GestureDetector(
  //           onTap: () {
  //             KycUtils.launchKycScreen(context, _loginResponse, _approvestatus);
  //           },
  //           child: Text(
  //             "KYC : ",
  //             style: Platform.isIOS
  //                 ? AppThemeCupertino.lightTheme.textTheme.pickerTextStyle
  //                     .apply(
  //                         color: AdaptiveTheme.primaryColor(context),
  //                         fontWeightDelta: 2)
  //                 : Theme.of(context)
  //                     .textTheme
  //                     .headline6
  //                     ?.apply(color: Theme.of(context).primaryColor),
  //           ),
  //         ),
  //         Text(
  //           _approvestatus == 0 && _loginResponse!.b2cParent!.docNumber == ""
  //               ? "Pending"
  //               : _approvestatus == 0 &&
  //                       _loginResponse!.b2cParent!.docNumber != ""
  //                   ? "Submitted"
  //                   : _approvestatus == 1
  //                       ? "Approved"
  //                       : _approvestatus == 2
  //                           ? "On hold"
  //                           : "",
  //         ),
  //       ],
  //     );

//This has to be removed
  // _engagementIndexWidget(
  //         BuildContext context, TextStyle? engagementIndexViewTextStyle) =>
  //     Row(
  //       children: [
  //         Flexible(
  //           flex: 1,
  //           child: Column(
  //             children: [
  //               _followercount <= 500
  //                   ? ImageIcon(AssetImage("assets/icons/group_3037.png"),
  //                       color: Colors.yellow[700])
  //                   : Icon(null),
  //               Container(
  //                 color: Colors.yellow[700],
  //                 width: screenWidth(context),
  //                 child: Text(
  //                   '500',
  //                   textAlign: TextAlign.center,
  //                   style: engagementIndexViewTextStyle,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         Flexible(
  //           flex: 1,
  //           child: Column(
  //             children: [
  //               _followercount >= 501 && _followercount <= 2500
  //                   ? ImageIcon(AssetImage("assets/icons/group_3038.png"),
  //                       color: Colors.yellow[800])
  //                   : Icon(null),
  //               Container(
  //                 color: Colors.yellow[800],
  //                 width: screenWidth(context),
  //                 child: Text(
  //                   '2500',
  //                   textAlign: TextAlign.center,
  //                   style: engagementIndexViewTextStyle,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         Flexible(
  //           flex: 1,
  //           child: Column(
  //             children: [
  //               _followercount >= 2501 && _followercount <= 10000
  //                   ? ImageIcon(AssetImage("assets/icons/group_3039.png"),
  //                       color: Colors.green[700])
  //                   : Icon(null),
  //               Container(
  //                 color: Colors.green[700],
  //                 width: screenWidth(context),
  //                 child: Text(
  //                   '10000',
  //                   textAlign: TextAlign.center,
  //                   style: engagementIndexViewTextStyle,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         Flexible(
  //           flex: 1,
  //           child: Column(
  //             children: [
  //               _followercount >= 10001
  //                   ? ImageIcon(AssetImage("assets/icons/group_3040.png"),
  //                       color: Colors.blueAccent)
  //                   : Icon(null),
  //               Container(
  //                 color: Colors.blueAccent,
  //                 width: screenWidth(context),
  //                 child: Text(
  //                   '> 10000',
  //                   textAlign: TextAlign.center,
  //                   style: engagementIndexViewTextStyle,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     );

  _followCountWidget(BuildContext context) {
    var _followCountTextStyle = TextStyle(
        fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black);
    var _followLabelStyle = TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AdaptiveTheme.primaryColor(context));

    return SizedBox(
      width: screenWidth(context),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_followingcount > 0)
                Navigator.of(context).pushNamed(FollowingScreen.routeName);
            },
            child: AutoSizeText(
              'Following',
              textAlign: TextAlign.center,
              style: _followLabelStyle,
              maxFontSize: textScale(context) <= 1.0 ? 14 : 12,
              maxLines: 1,
              minFontSize: 10,
              stepGranularity: 1,
            ),
          ),
          horizontalSpaceSmall,
          StreamBuilder<QuerySnapshot>(
              stream: FirestoreServices.getFollowingParents(
                  _loginResponse!.b2cParent!.parentID),
              builder: (context, followersSnapshot) {
                if (followersSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Icon(Icons.more_horiz, color: Colors.grey.shade100);
                } else if (followersSnapshot.hasData) {
                  _followingcount = followersSnapshot.data!.size.toInt();
                  return AutoSizeText(
                    followersSnapshot.data!.size.toString(),
                    textAlign: TextAlign.center,
                    style: _followCountTextStyle,
                    maxFontSize: textScale(context) <= 1.0 ? 14 : 12,
                    maxLines: 1,
                    minFontSize: 10,
                    stepGranularity: 1,
                  );
                }
                return Center(child: AdaptiveCircularProgressIndicator());
              }),
          VerticalDivider(thickness: 2),
          horizontalSpaceMedium,
          GestureDetector(
            onTap: () {
              if (_followercount > 0)
                Navigator.of(context).pushNamed(
                  FollowersScreen.routeName,
                );
            },
            child: AutoSizeText(
              'Followers',
              textAlign: TextAlign.center,
              style: _followLabelStyle,
              maxFontSize: textScale(context) <= 1.0 ? 14 : 12,
              maxLines: 1,
              minFontSize: 10,
              stepGranularity: 1,
            ),
          ),
          horizontalSpaceSmall,
          StreamBuilder<QuerySnapshot>(
              stream: FirestoreServices.getFollowersParents(
                  _loginResponse!.b2cParent!.parentID),
              builder: (context, followersSnapshot) {
                if (followersSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Icon(Icons.more_horiz, color: Colors.grey.shade100);
                } else if (followersSnapshot.hasData) {
                  _followercount = followersSnapshot.data!.size.toInt();
                  return AutoSizeText(
                    followersSnapshot.data!.size.toString(),
                    textAlign: TextAlign.center,
                    style: _followCountTextStyle,
                    maxFontSize: textScale(context) <= 1.0 ? 14 : 12,
                    maxLines: 1,
                    minFontSize: 10,
                    stepGranularity: 1,
                  );
                }
                return Center(child: AdaptiveCircularProgressIndicator());
              }),
          Spacer(),
          FeedButton(loginResponse: _loginResponse),
        ],
      ),
    );
  }
}

class FeedButton extends StatefulWidget {
  const FeedButton({
    Key? key,
    required LoginResponse? loginResponse,
  })  : _loginResponse = loginResponse,
        super(key: key);

  final LoginResponse? _loginResponse;

  @override
  State<FeedButton> createState() => _FeedButtonState();
}

class _FeedButtonState extends State<FeedButton> {
  bool _isloading2 = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 75,
      height: 25,
      child: appButton(
          context: context,
          width: 20,
          height: 20,
          titleFontSize: textScale(context) <= 1.0 ? 12 : 10,
          title: 'Feeds',
          titleColour: AdaptiveTheme.primaryColor(context),
          onPressed: _isloading2
              ? () {}
              : () async {
                  setState(() {
                    _isloading2 = true;
                  });
                  //Checking whether posts are there for the user
                  var count = await FirestoreServices.getUserFeedsCount(
                      widget._loginResponse!.b2cParent!.parentID);
                  if (count < 1) {
                    Navigator.of(context).pushNamed(NewPostScreen.routeName);
                    setState(() {
                      _isloading2 = false;
                    });
                    return;
                  } else {
                    UserFeedsArgs args;
                    args = UserFeedsArgs(
                        widget._loginResponse!.b2cParent!.parentID, false);
                    Navigator.of(context)
                        .pushNamed(UserFeedsScreen.routeName, arguments: args);
                    setState(() {
                      _isloading2 = false;
                    });
                    // _loginResponse!.b2cParent!.parentID);
                  }
                },
          borderColor: AdaptiveTheme.primaryColor(context),
          borderRadius: 20),
    );
  }
}

class ProfileMyVendorsSection extends StatelessWidget {
  const ProfileMyVendorsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final deviceSize = MediaQuery.of(context).size;
    Widget _emptyVendors() {
      return Container();
    }

    LoginResponse _loginResponse =
        Provider.of<Auth>(context, listen: false).loginResponse;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalSpaceTiny,
            Text(
              'My Vendors',
              style: kIsWeb || Platform.isAndroid
                  ? Theme.of(context).textTheme.headline2!.copyWith(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500)
                  : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
                      .copyWith(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
            ),
            //verticalSpaceSmall,

            //height: screenWidth(context) * 0.40,
            SingleChildScrollView(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirestoreServices.getFollowingVendors(
                    _loginResponse.b2cParent!.parentID),
                builder: (context, vendorSnapshot) {
                  if (vendorSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Container(
                      //height: screenWidth(context) * 0.40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(child: AdaptiveCircularProgressIndicator()),
                        ],
                      ),
                    );
                  } else {
                    if (vendorSnapshot.hasData) {
                      final vendors = vendorSnapshot.data!.docs;
                      if (vendors.isNotEmpty) {
                        return Container(
                          height: screenWidth(context) * 0.40,
                          child: ListView.builder(
                            // physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: vendors.length,
                            itemBuilder: (BuildContext context, int index) {
                              //convert the followings object to local Object
                              DocumentSnapshot followings = vendors[index];
                              FollowingParents followingVendors =
                                  FollowingParents.fromJson(followings.data()
                                      as Map<String, dynamic>);
                              //convert the followings object to local Object

                              return Row(
                                children: [
                                  BasicProfileItemWidget(
                                      followingParents: followingVendors),
                                  const SizedBox(width: 10),
                                ],
                              );
                            },
                          ),
                        );
                      } else {
                        return _emptyVendors();
                      }
                    } else {
                      return _emptyVendors();
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
