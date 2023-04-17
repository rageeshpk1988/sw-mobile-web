import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../../adaptive/adaptive_theme.dart';
import '../../../../helpers/route_arguments.dart';
import '../../../../util/app_theme.dart';
import '../../../../util/ui_helpers.dart';
import '../../../../widgets/web_banner.dart';
import '../../../../widgets/web_bottom_bar.dart';

import '../../../models/child.dart';
import '../../../models/firestore/feedpost.dart';
import '../../../models/firestore/followingparents.dart';
import '../../../models/login_response.dart';
import '../../../providers/auth.dart';
import '../../../providers/firestore_services.dart';
import '../../../providers/homestaticdata_new.dart';
import '../widgets/feeds_wall_paginated_list_web.dart';

class UserFeedsScreenWeb extends StatelessWidget {
  static String routeName = '/web-userfeeds';

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // int userId = ModalRoute.of(context)!.settings.arguments as int;
    UserFeedsWebArgs args =
        ModalRoute.of(context)!.settings.arguments as UserFeedsWebArgs;

    Widget _kidsView() {
      TextStyle _headerStyle(double fontSize, FontWeight fontWeight) {
        return AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontSize: fontSize, fontWeight: fontWeight);
      }

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
                      'Kids',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (args.students.isNotEmpty)
                  //CHILD DETAILS
                  GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    // padding: const EdgeInsets.all(10.0),
                    itemCount: args.students.length,

                    itemBuilder: (ctx, index) {
                      Child child = args.students[index];
                      return SizedBox(
                        width: screenWidth(context) * 0.05,
                        // height: screenHeight(context) * 0.1,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                getAvatarImage(child.imageUrl, 30, 30,
                                    BoxShape.circle, child.name),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      child.name,
                                      style: _headerStyle(14, FontWeight.w500),
                                    ),
                                    Text(
                                      '${child.schoolName!}',
                                      style: _headerStyle(11, FontWeight.w300),
                                    ),
                                    Text(
                                      '${child.className} ${child.division}',
                                      style: _headerStyle(11, FontWeight.w300)
                                          .copyWith(
                                              color:
                                                  AdaptiveTheme.secondaryColor(
                                                      context)),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Divider(),
                          ],
                        ),
                      );
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 10 / 5,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 1,
                        mainAxisExtent: screenHeight(context) * 0.090),
                  ),
                //CHILD DETAILS
              ],
            ),
          ),
        ),
      );
    }

    Widget _bodyWidget() {
      return FeedsWallPaginatedListWeb(
        userId: args.userId,
        enableProfileNaviagate: false,
        followerFeeds: args.followerFeeds,
      );
    }

    return Scaffold(
      endDrawer: WebBannerDrawer(),
      backgroundColor: Colors.white,
      key: scaffoldKey,
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
              padding: EdgeInsets.only(
                  left: (screenWidth(context) > 800 ? 70.0 : 20.0), top: 40),
              child: Row(
                children: [
                  Text(
                    "Feeds",
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
              width: screenWidth(context) *
                  (screenWidth(context) > 800 ? 0.90 : 0.98),
              child: Padding(
                padding: EdgeInsets.only(
                    left: (screenWidth(context) > 800 ? 1.0 : 10.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: screenWidth(context) *
                              (screenWidth(context) > 800 ? 0.60 : 0.90),
                          child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              elevation: 5.0,
                              child: HeaderSection(
                                args.feedPost,
                                args.followingParents,
                              )),
                        ),
                        Container(
                          width: screenWidth(context) *
                              (screenWidth(context) > 800 ? 0.60 : 0.90),
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
                    if (screenWidth(context) > 800)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _kidsView(),
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

class HeaderSection extends StatelessWidget {
  final FeedPost? feedPost;
  final FollowingParents? followingParents;

  HeaderSection(
    this.feedPost,
    this.followingParents,
  );
  @override
  Widget build(BuildContext context) {
    TextStyle _headerStyle(double fontSize, FontWeight fontWeight) {
      return AppTheme.lightTheme.textTheme.bodySmall!
          .copyWith(fontSize: fontSize, fontWeight: fontWeight);
    }

    var headingSize = screenWidth(context) > 800 ? 18.0 : 14.0;
    var subHeadingSize = screenWidth(context) > 800 ? 12.0 : 10.0;
    return Card(
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getAvatarImage(
                  feedPost == null
                      ? followingParents!.userImage == null
                          ? null
                          : followingParents!.userImage
                      : feedPost!.profileImage == null
                          ? null
                          : feedPost!.profileImage,
                  screenWidth(context) > 800 ? 70 : 40,
                  screenWidth(context) > 800 ? 70 : 40,
                  BoxShape.circle,
                  feedPost == null
                      ? followingParents!.userName == null
                          ? null
                          : followingParents!.userName
                      : feedPost!.postedUserName == null
                          ? null
                          : feedPost!.postedUserName,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          child: feedPost == null
                              ? Text(
                                  followingParents!.userName!.toUpperCase(),
                                  style: _headerStyle(
                                      headingSize, FontWeight.w600),
                                )
                              : Text(
                                  feedPost!.postedUserName!.toUpperCase(),
                                  style: _headerStyle(
                                      headingSize, FontWeight.w600),
                                ),
                        ),
                        verticalSpaceSmall,
                        Row(
                          children: [
                            feedPost == null
                                ? Text(
                                    followingParents!.state!.toUpperCase(),
                                    style: _headerStyle(
                                        subHeadingSize, FontWeight.w400),
                                  )
                                : Text(
                                    feedPost!.postedByUserState!.toUpperCase(),
                                    style: _headerStyle(
                                        subHeadingSize, FontWeight.w400),
                                  ),
                            horizontalSpaceTiny,
                            feedPost == null
                                ? Text(
                                    followingParents!.city!.toUpperCase(),
                                    style: _headerStyle(
                                        subHeadingSize, FontWeight.w400),
                                  )
                                : Text(
                                    feedPost!.postedByUserLocation!
                                        .toUpperCase(),
                                    style: _headerStyle(
                                        subHeadingSize, FontWeight.w400),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            verticalSpaceSmall,
            cardFooter(context, feedPost, followingParents),
            verticalSpaceSmall,
          ],
        ),
      ),
    );
  }

  cardFooter(
    BuildContext context,
    FeedPost? feedPost,
    FollowingParents? followingParents,
  ) {
    LoginResponse _loginResponse =
        Provider.of<Auth>(context, listen: false).loginResponse;
    // bool? _following = false;
    // var _followCountTextStyle = TextStyle(
    //     fontSize: 16,
    //     fontWeight: FontWeight.w700,
    //     color: AdaptiveTheme.primaryColor(context));
    // var _followLabelStyle =
    //     TextStyle(fontSize: 16, fontWeight: FontWeight.w700);

    var _followCountTextStyle = TextStyle(
        fontSize: screenWidth(context) > 800 ? 15 : 13,
        fontWeight: FontWeight.w700,
        color: Colors.black);
    var _followLabelStyle = TextStyle(
        fontSize: screenWidth(context) > 800 ? 15 : 13,
        fontWeight: FontWeight.w400,
        color: AdaptiveTheme.primaryColor(context));

    // bool _checkFollowStatus(QuerySnapshot snap) {
    //   int exists = snap.docs
    //       .where((element) =>
    //           element['userID'] == _loginResponse.b2cParent!.parentID)
    //       .length;
    //   return exists > 0 ? _following = true : _following = false;
    // }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          //mainAxisSize: MainAxisSize.min,
          //mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //FOLLOWING
            // GestureDetector(
            //   onTap: () {
            //     Navigator.of(context).pushNamed(FollowingScreen.routeName);
            //   },
            //   child: Text(
            //     'Following',
            //     style: _followLabelStyle,
            //   ),
            // ),
            Text(
              'Following',
              style: _followLabelStyle,
            ),
            horizontalSpaceSmall,
            StreamBuilder<QuerySnapshot>(
              stream: feedPost == null
                  ? FirestoreServices.getFollowingParents(
                      followingParents!.userID!)
                  : FirestoreServices.getFollowingParents(
                      feedPost.postedUserID!),
              builder: (context, followersSnapshot) {
                if (followersSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Icon(Icons.more_horiz,
                      color: Colors.grey
                          .shade100); // Center(child: AdaptiveCircularProgressIndicator());
                } else {
                  if (followersSnapshot.hasData) {
                    return Text(
                      followersSnapshot.data!.size.toString(),
                      style: _followCountTextStyle,
                    );
                  }
                  return Center(child: AdaptiveCircularProgressIndicator());
                }
              },
            ),
            VerticalDivider(
              thickness: 2,
            ),
            //FOLLOWING
            //FOLLOWERS
            //  GestureDetector(
            //   onTap: () {
            //     Navigator.of(context).pushNamed(FollowersScreen.routeName);
            //   },
            //   child: Text(
            //     'Followers',
            //     style: _followLabelStyle,
            //   ),
            // ),
            Text(
              'Followers',
              style: _followLabelStyle,
            ),
            horizontalSpaceSmall,
            StreamBuilder<QuerySnapshot>(
              stream: feedPost == null
                  ? FirestoreServices.getFollowersParents(
                      followingParents!.userID!)
                  : FirestoreServices.getFollowersParents(
                      feedPost.postedUserID!),
              builder: (context, followersSnapshot) {
                if (followersSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Icon(Icons.more_horiz, color: Colors.grey.shade100);
                  //Center(child: AdaptiveCircularProgressIndicator());
                } else {
                  if (followersSnapshot.hasData) {
                    // _checkFollowStatus(followersSnapshot.data!);
                    return Text(
                      followersSnapshot.data!.size.toString(),
                      style: _followCountTextStyle,
                    );
                  }
                  return Center(child: AdaptiveCircularProgressIndicator());
                }
              },
            ),
            //FOLLOWERS
          ],
        ),
        const SizedBox(height: 10),
        //FOLLOW-UNFOLLOW BUTTON
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FollowUnFollowAction(
              feedPost: feedPost,
              loginResponse: _loginResponse,
              followingParents: followingParents,
            ),
            //Spacer(),
          ],
        ),
        //FOLLOW-UNFOLLOW BUTTON
      ],
    );
  }
}

class FollowUnFollowAction extends StatefulWidget {
  final FeedPost? feedPost;
  final FollowingParents? followingParents;
  final LoginResponse loginResponse;
  const FollowUnFollowAction({
    Key? key,
    required this.feedPost,
    required this.followingParents,
    required this.loginResponse,
  }) : super(key: key);

  @override
  State<FollowUnFollowAction> createState() => _FollowUnFollowActionState();
}

class _FollowUnFollowActionState extends State<FollowUnFollowAction> {
  refreshSuggestedParents() {
    LoginResponse loginResponse =
        Provider.of<Auth>(context, listen: false).loginResponse;

    Provider.of<HomeStaticDataNew>(context, listen: false)
        .fetchAndSetSuggestedParentList(loginResponse.b2cParent!.parentID)
        .then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 105,
      height: 25,
      child: StreamBuilder<QuerySnapshot>(
        stream: widget.feedPost == null
            ? FirestoreServices.isUserFollowing(
                widget.followingParents!.userID!,
                widget.loginResponse.b2cParent!.parentID)
            : FirestoreServices.isUserFollowing(widget.feedPost!.postedUserID!,
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
                    widget.feedPost == null
                        ? FirestoreServices.undoFollowNew(
                            widget.followingParents!, widget.loginResponse)
                        : FirestoreServices.undoFollow(
                            widget.feedPost!, widget.loginResponse);
                    refreshSuggestedParents();
                  } else {
                    widget.feedPost == null
                        ? FirestoreServices.doFollowNew(
                            widget.followingParents!, widget.loginResponse)
                        : FirestoreServices.doFollow(
                            widget.feedPost!, widget.loginResponse);
                    refreshSuggestedParents();
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
