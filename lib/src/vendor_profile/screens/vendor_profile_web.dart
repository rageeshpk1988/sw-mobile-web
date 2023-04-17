import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/src/home/search/widgets/products_wall_list_web.dart';
import '../../../src/home/search/widgets/products_wall_list.dart';

import '../../../../adaptive/adaptive_circular_progressInd.dart';

import '../../../../adaptive/adaptive_theme.dart';

import '../../../util/app_theme.dart';

import '../../../widgets/web_banner.dart';
import '../../../widgets/web_bottom_bar.dart';
import '../../home/feeds/widgets/feeds_wall_paginated_list_web.dart';
import '../../models/firestore/vendor_from_ads.dart';
import '../widgets/vendor_feeds_list.dart';
import '/helpers/route_arguments.dart';

import '/src/models/child.dart';
import '/src/models/firestore/feedpost.dart';
import '/src/models/firestore/followingparents.dart';
import '/src/models/login_response.dart';
import '/src/providers/auth.dart';
import '/src/providers/firestore_services.dart';
import '/util/ui_helpers.dart';

class VendorProfileScreenWeb extends StatefulWidget {
  static String routeName = '/web-vendor-profile-new';
  const VendorProfileScreenWeb({Key? key}) : super(key: key);

  @override
  _VendorProfileScreenWebState createState() => _VendorProfileScreenWebState();
}

class _VendorProfileScreenWebState extends State<VendorProfileScreenWeb>
    with SingleTickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var _isInIt = true;
  late ProfileOthersArgs profileOthersArgs;
  FeedPost? feedPost;
  FollowingParents? followingParents;
  AdVendorProfile? adVendorProfile;
  List<Child> students = [];

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      profileOthersArgs =
          ModalRoute.of(context)!.settings.arguments as ProfileOthersArgs;
      feedPost = profileOthersArgs.feedPost;
      followingParents = profileOthersArgs.followingParents;
      adVendorProfile = profileOthersArgs.adVendorProfile;
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Widget _bodyWidget() {
      return FeedsWallPaginatedListWeb(
          enableProfileNaviagate: false,
          userId: feedPost == null && followingParents == null
              ? adVendorProfile!.userID!
              : feedPost == null
                  ? followingParents!.userID!
                  : feedPost!.postedUserID!);
    }

    Widget _vendorProductsView() {
      // TextStyle _headerStyle(double fontSize, FontWeight fontWeight) {
      //   return AppTheme.lightTheme.textTheme.bodySmall!
      //       .copyWith(fontSize: fontSize, fontWeight: fontWeight);
      // }

      return SizedBox(
        width: screenWidth(context) * 0.20,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 5.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Products',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                //PRODUCTS LIST
                feedPost == null && followingParents == null
                    ? ProductsWallListWeb(vendorID: adVendorProfile!.userID!)
                    : feedPost == null
                        ? ProductsWallListWeb(
                            vendorID: followingParents!.userID!)
                        : ProductsWallListWeb(
                            vendorID: feedPost!.postedUserID!),
                //PRODUCTS LIST
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      endDrawer: WebBannerDrawer(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        //physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            WebBanner(
              showMenu: true,
              showHomeButton: true,
              showProfileButton: true,
              scaffoldKey: scaffoldKey,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 70.0, top: 40),
              child: Row(
                children: [
                  Text(
                    "Vendor's Profile",
                    style: TextStyle(
                        letterSpacing: 0.0,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: screenWidth(context) * 0.90,
              child: Padding(
                padding: const EdgeInsets.only(left: 70.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: screenWidth(context) * 0.60,
                          child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              elevation: 5.0,
                              child: VendorHeaderSectionWeb(
                                  feedPost, followingParents, adVendorProfile)),
                        ),
                        Container(
                          width: screenWidth(context) * 0.60,
                          constraints: BoxConstraints(
                            maxHeight: double.infinity,
                          ),
                          child: SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: _bodyWidget(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _vendorProductsView(),
                      ],
                    )
                  ],
                ),
              ),
            ),
            WebBottomBar(),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class ProductAndFeeds extends StatefulWidget {
  final int productOrFeed; // 0 - product selected , 1- feed selected

  final FeedPost? feedPost;
  final FollowingParents? followingParents;
  final AdVendorProfile? adVendorProfile;
  const ProductAndFeeds({
    Key? key,
    required this.productOrFeed,
    this.feedPost,
    this.followingParents,
    this.adVendorProfile,
  }) : super(key: key);

  @override
  _ProductAndFeedsState createState() => _ProductAndFeedsState();
}

class _ProductAndFeedsState extends State<ProductAndFeeds> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.productOrFeed == 0)
            widget.feedPost == null && widget.followingParents == null
                ? ProductsWallList(vendorID: widget.adVendorProfile!.userID!)
                : widget.feedPost == null
                    ? ProductsWallList(
                        vendorID: widget.followingParents!.userID!)
                    : ProductsWallList(
                        vendorID: widget.feedPost!.postedUserID!),
          if (widget.productOrFeed == 1)
            VendorFeedsList(
                vendorId:
                    widget.feedPost == null && widget.followingParents == null
                        ? widget.adVendorProfile!.userID!
                        : widget.feedPost == null
                            ? widget.followingParents!.userID!
                            : widget.feedPost!.postedUserID!),
        ],
      ),
    );
  }
}

class VendorHeaderSectionWeb extends StatelessWidget {
  final FeedPost? feedPost;
  final FollowingParents? followingParents;
  final AdVendorProfile? adVendorProfile;
  VendorHeaderSectionWeb(
      this.feedPost, this.followingParents, this.adVendorProfile);
  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    TextStyle _headerStyle(double fontSize, FontWeight fontWeight) {
      return AppTheme.lightTheme.textTheme.bodySmall!
          .copyWith(fontSize: fontSize, fontWeight: fontWeight);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            //width: size.width * .85,
            height: screenHeight(context) * 0.20,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  feedPost == null && followingParents == null
                      ? getAvatarImage(
                          adVendorProfile!.userImage == null
                              ? null
                              : adVendorProfile!.userImage,
                          70,
                          70,
                          BoxShape.rectangle,
                          adVendorProfile!.userName == null
                              ? null
                              : adVendorProfile!.userName,
                        )
                      : feedPost == null
                          ? getAvatarImage(
                              followingParents!.userImage == null
                                  ? null
                                  : followingParents!.userImage,
                              70,
                              70,
                              BoxShape.rectangle,
                              followingParents!.userName == null
                                  ? null
                                  : followingParents!.userName,
                            )
                          : getAvatarImage(
                              feedPost!.profileImage == null
                                  ? null
                                  : feedPost!.profileImage,
                              70,
                              70,
                              BoxShape.rectangle,
                              feedPost!.postedUserName == null
                                  ? null
                                  : feedPost!.postedUserName,
                            ),
                  const SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      feedPost == null && followingParents == null
                          ? SizedBox(
                              width: 200,
                              child: Text(
                                adVendorProfile!.userName!,
                                style: _headerStyle(15, FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            )
                          : feedPost == null
                              ? SizedBox(
                                  width: 200,
                                  child: Text(
                                    followingParents!.userName!,
                                    style: _headerStyle(15, FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                )
                              : SizedBox(
                                  width: 200,
                                  child: Text(
                                    feedPost!.postedUserName!,
                                    style: _headerStyle(15, FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                      const SizedBox(height: 5),
                      feedPost == null && followingParents == null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Location:',
                                  style: _headerStyle(13, FontWeight.w500),
                                ),
                                adVendorProfile!.city != null
                                    ? Text(adVendorProfile!.city!,
                                        style:
                                            _headerStyle(12, FontWeight.w400))
                                    : const Text(''),
                              ],
                            )
                          : feedPost == null
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Location:',
                                      style: _headerStyle(13, FontWeight.w500),
                                    ),
                                    followingParents!.city != null
                                        ? Text(followingParents!.city!,
                                            style: _headerStyle(
                                                12, FontWeight.w400))
                                        : const Text(''),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Location:',
                                      style: _headerStyle(13, FontWeight.w500),
                                    ),
                                    feedPost!.postedByUserLocation != null
                                        ? Text(
                                            //feedPost!.description!,
                                            feedPost!.postedByUserLocation!,
                                            style: _headerStyle(
                                                12, FontWeight.w400))
                                        : const Text(''),
                                  ],
                                ),
                      const SizedBox(height: 10),
                      cardFooter(
                          context, feedPost, followingParents, adVendorProfile),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  cardFooter(
    BuildContext context,
    FeedPost? feedPost,
    FollowingParents? followingParents,
    AdVendorProfile? adVendorProfile,
  ) {
    LoginResponse _loginResponse =
        Provider.of<Auth>(context, listen: false).loginResponse;

    var _followCountTextStyle = TextStyle(
        fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black);
    var _followLabelStyle = TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AdaptiveTheme.primaryColor(context));

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //FOLLOW-UNFOLLOW BUTTON
              VendorFollowUnFollowAction(
                feedPost: feedPost,
                loginResponse: _loginResponse,
                followingParents: followingParents,
                adVendorProfile: adVendorProfile,
              ),
              //FOLLOW-UNFOLLOW BUTTON

              SizedBox(width: 60),

              //FOLLOWERS
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Followers',
                    style: _followLabelStyle,
                  ),
                  const SizedBox(width: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: feedPost == null && followingParents == null
                        ? FirestoreServices.getFollowersVendors(
                            adVendorProfile!.userID!)
                        : feedPost == null
                            ? FirestoreServices.getFollowersVendors(
                                followingParents!.userID!)
                            : FirestoreServices.getFollowersVendors(
                                feedPost.postedUserID!),
                    builder: (context, followersSnapshot) {
                      if (followersSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Icon(Icons.more_horiz,
                            color: Colors.grey.shade100);
                      } else {
                        if (followersSnapshot.hasData) {
                          // _checkFollowStatus(followersSnapshot.data!);
                          return Text(
                            followersSnapshot.data!.size.toString(),
                            style: _followCountTextStyle,
                          );
                        }
                        return Center(
                            child: AdaptiveCircularProgressIndicator());
                      }
                    },
                  ),
                ],
              ),

              //FOLLOWERS
            ],
          ),
        ),
        Divider(),
      ],
    );
  }
}

class VendorFollowUnFollowAction extends StatefulWidget {
  final FeedPost? feedPost;
  final FollowingParents? followingParents;
  final AdVendorProfile? adVendorProfile;
  final LoginResponse loginResponse;
  const VendorFollowUnFollowAction({
    Key? key,
    required this.feedPost,
    required this.followingParents,
    required this.adVendorProfile,
    required this.loginResponse,
  }) : super(key: key);

  @override
  State<VendorFollowUnFollowAction> createState() =>
      _VendorFollowUnFollowActionState();
}

class _VendorFollowUnFollowActionState
    extends State<VendorFollowUnFollowAction> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 25,
      child: StreamBuilder<QuerySnapshot>(
        stream: widget.feedPost == null && widget.followingParents == null
            ? FirestoreServices.isVendorFollowing(
                widget.adVendorProfile!.userID!,
                widget.loginResponse.b2cParent!.parentID)
            : widget.feedPost == null
                ? FirestoreServices.isVendorFollowing(
                    widget.followingParents!.userID!,
                    widget.loginResponse.b2cParent!.parentID)
                : FirestoreServices.isVendorFollowing(
                    widget.feedPost!.postedUserID!,
                    widget.loginResponse.b2cParent!.parentID),
        // initialData: null,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return appButton(
                context: context,
                width: 20,
                height: 20,
                titleFontSize: 12,
                title: snap.data == null
                    ? 'Follow'
                    : snap.data!.size > 0
                        ? 'Unfollow'
                        : 'Follow',
                titleColour: AdaptiveTheme.primaryColor(context),
                onPressed: () {},
                borderColor: AdaptiveTheme.primaryColor(context),
                borderRadius: 20);
          } else {
            return appButton(
                context: context,
                width: 20,
                height: 20,
                titleFontSize: 12,
                title: snap.data!.size > 0 ? 'UnFollow' : 'Follow',
                titleColour: AdaptiveTheme.primaryColor(context),
                onPressed: () async {
                  if (snap.data!.size > 0) {
                    widget.feedPost == null && widget.followingParents == null
                        ? FirestoreServices.undoFollowNewVendor2(
                            widget.adVendorProfile!, widget.loginResponse)
                        : widget.feedPost == null
                            ? FirestoreServices.undoFollowNewVendor(
                                widget.followingParents!, widget.loginResponse)
                            : FirestoreServices.undoFollowVendor(
                                widget.feedPost!, widget.loginResponse);
                    setState(() {});
                  } else {
                    widget.feedPost == null && widget.followingParents == null
                        ? FirestoreServices.doFollowNewVendor2(
                            widget.adVendorProfile!, widget.loginResponse)
                        : widget.feedPost == null
                            ? FirestoreServices.doFollowNewVendor(
                                widget.followingParents!, widget.loginResponse)
                            : FirestoreServices.doFollowVendor(
                                widget.feedPost!, widget.loginResponse);
                    setState(() {});
                  }
                },
                borderColor: AdaptiveTheme.primaryColor(context),
                borderRadius: 20);
          }
        },
      ),
    );
  }
}
