//import 'dart:html';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../src/home/search/widgets/products_wall_list.dart';

import '../../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../../adaptive/adaptive_custom_appbar.dart';
import '../../../../adaptive/adaptive_theme.dart';

import '../../../util/app_theme.dart';
import '../../../util/app_theme_cupertino.dart';
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

class VendorProfileScreen extends StatefulWidget {
  static String routeName = '/vendor-profile';
  const VendorProfileScreen({Key? key}) : super(key: key);

  @override
  _VendorProfileScreenState createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen>
    with SingleTickerProviderStateMixin {
  var _isInIt = true;
  late ProfileOthersArgs profileOthersArgs;
  FeedPost? feedPost;
  FollowingParents? followingParents;
  AdVendorProfile? adVendorProfile;
  List<Child> students = [];
  int _productOrFeed = 0; // 0 - product selected , 1- feed selected

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
        title: "Vendor's Profile",
        showMascot: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              VendorHeaderSection(feedPost, followingParents, adVendorProfile),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: _productOrFeed == 0 ? 100 : 110,
                      height: 25,
                      child: appButton(
                        context: context,
                        width: 0,
                        height: 0,
                        title: 'Products',
                        titleFontSize: _productOrFeed == 0
                            ? 10
                            : textScale(context) <= 1.0
                                ? 14
                                : 12,
                        primary: _productOrFeed == 0
                            ? AdaptiveTheme.primaryColor(context)
                            : Colors.white,
                        titleColour:
                            _productOrFeed == 0 ? Colors.white : Colors.black54,
                        onPressed: () {
                          _productOrFeed = 0;
                          setState(() {});
                        },
                        borderColor: _productOrFeed == 0
                            ? AdaptiveTheme.primaryColor(context)
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: _productOrFeed == 1 ? 70 : 80,
                      height: 25,
                      child: appButton(
                        context: context,
                        width: 0,
                        height: 0,
                        title: 'Feeds',
                        titleFontSize: _productOrFeed == 1
                            ? 10
                            : textScale(context) <= 1.0
                                ? 14
                                : 12,
                        primary: _productOrFeed == 1
                            ? AdaptiveTheme.primaryColor(context)
                            : Colors.white,
                        titleColour:
                            _productOrFeed == 1 ? Colors.white : Colors.black54,
                        onPressed: () {
                          _productOrFeed = 1;
                          setState(() {});
                        },
                        borderColor: _productOrFeed == 1
                            ? AdaptiveTheme.primaryColor(context)
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ProductAndFeeds(
                    productOrFeed: _productOrFeed,
                    feedPost: feedPost,
                    followingParents: followingParents,
                    adVendorProfile: adVendorProfile),
              ),
            ],
          ),
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

class VendorHeaderSection extends StatelessWidget {
  final FeedPost? feedPost;
  final FollowingParents? followingParents;
  final AdVendorProfile? adVendorProfile;
  VendorHeaderSection(
      this.feedPost, this.followingParents, this.adVendorProfile);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    TextStyle _headerStyle(double fontSize, FontWeight fontWeight) {
      return kIsWeb || Platform.isAndroid
          ? AppTheme.lightTheme.textTheme.bodySmall!
              .copyWith(fontSize: fontSize, fontWeight: fontWeight)
          : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
              .copyWith(fontSize: fontSize, fontWeight: fontWeight);
    }

    return Column(
      children: [
        Card(
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: size.width * .85,
              height: 150,
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
                          BoxShape.circle,
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
                              BoxShape.circle,
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
                              BoxShape.circle,
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
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AdaptiveTheme.primaryColor(context));
    var _followLabelStyle = TextStyle(
        fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black54);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              //FOLLOW-UNFOLLOW BUTTON
              VendorFollowUnFollowAction(
                feedPost: feedPost,
                loginResponse: _loginResponse,
                followingParents: followingParents,
                adVendorProfile: adVendorProfile,
              ),
              //FOLLOW-UNFOLLOW BUTTON

              SizedBox(width: kIsWeb || Platform.isAndroid ? 60 : 60),

              //FOLLOWERS
              Column(
                children: [
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
                  Text(
                    'Followers',
                    style: _followLabelStyle,
                  ),
                ],
              ),

              //FOLLOWERS
            ],
          ),
        ),
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
                titleFontSize: textScale(context) <= 1.0 ? 12 : 10,
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
                titleFontSize: textScale(context) <= 1.0 ? 12 : 10,
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
