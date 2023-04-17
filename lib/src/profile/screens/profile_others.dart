// import 'dart:convert';
// import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../adaptive/adaptive_custom_appbar.dart';
import '../../../adaptive/adaptive_theme.dart';
import '../../../util/app_theme.dart';
import '../../providers/homestaticdata_new.dart';
import '/helpers/route_arguments.dart';
import '/src/models/child.dart';
import '/src/models/firestore/followingparents.dart';
import '/src/models/login_response.dart';
import '/src/providers/auth.dart';
import '/src/providers/children.dart';

import '/util/app_theme_cupertino.dart';
import '/src/home/feeds/screens/user_feeds.dart';
import '/src/models/firestore/feedpost.dart';

import '/src/providers/firestore_services.dart';

import '../../../util/ui_helpers.dart';

class ProfileOthersScreen extends StatefulWidget {
  const ProfileOthersScreen({Key? key}) : super(key: key);
  static String routeName = '/profile-others';

  @override
  _ProfileOthersScreenState createState() => _ProfileOthersScreenState();
}

class _ProfileOthersScreenState extends State<ProfileOthersScreen> {
  var _isInIt = true;
  var _isLoading = false;
  late ProfileOthersArgs profileOthersArgs;
  FeedPost? feedPost;
  FollowingParents? followingParents;
  List<Child> students = [];

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      setState(() {
        _isLoading = true;
      });

      profileOthersArgs =
          ModalRoute.of(context)!.settings.arguments as ProfileOthersArgs;
      feedPost = profileOthersArgs.feedPost;
      followingParents = profileOthersArgs.followingParents;
      LoginResponse loginResponse =
          Provider.of<Auth>(context, listen: false).loginResponse;
      feedPost == null
          ? Provider.of<Children>(context, listen: false)
              .fetchStudentList(followingParents!.userID!)
              .then((value) {
              students = value;
              setState(() {
                _isLoading = false;
              });
            })
          : Provider.of<Children>(context, listen: false)
              .fetchStudentList(feedPost!.postedUserID!)
              .then((value) {
              students = value;
              setState(() {
                _isLoading = false;
              });
            });
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // ProfileOthersArgs profileOthersArgs =
    //     ModalRoute.of(context)!.settings.arguments as ProfileOthersArgs;
    // FeedPost? feedPost = profileOthersArgs.feedPost;
    // FollowingParents? followingParents = profileOthersArgs.followingParents;

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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpaceSmall,
                HeaderSection(feedPost, followingParents),
                verticalSpaceMedium,
                //CHILD DETAILS
                Container(
                  //decoration: BoxDecoration(color: Colors.grey[100]),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2.0, right: 2.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: students.length,
                      itemBuilder: (BuildContext context, int i) {
                        return StudentListItem(students[i]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  final FeedPost? feedPost;
  final FollowingParents? followingParents;
  HeaderSection(this.feedPost, this.followingParents);
  @override
  Widget build(BuildContext context) {
    TextStyle _headerStyle(double fontSize, FontWeight fontWeight) {
      return Platform.isIOS
          ? AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
              .copyWith(fontSize: fontSize, fontWeight: fontWeight)
          : AppTheme.lightTheme.textTheme.bodySmall!
              .copyWith(fontSize: fontSize, fontWeight: fontWeight);
    }

    return Card(
      elevation: 2.0,
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
                  80,
                  80,
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
                                  style: _headerStyle(18, FontWeight.w600),
                                )
                              : Text(
                                  feedPost!.postedUserName!.toUpperCase(),
                                  style: _headerStyle(18, FontWeight.w600),
                                ),
                        ),
                        verticalSpaceSmall,
                        Row(
                          children: [
                            feedPost == null
                                ? Text(
                                    followingParents!.state!.toUpperCase(),
                                    style: _headerStyle(12, FontWeight.w400),
                                  )
                                : Text(
                                    feedPost!.postedByUserState!.toUpperCase(),
                                    style: _headerStyle(12, FontWeight.w400),
                                  ),
                            horizontalSpaceTiny,
                            feedPost == null
                                ? Text(
                                    followingParents!.city!.toUpperCase(),
                                    style: _headerStyle(12, FontWeight.w400),
                                  )
                                : Text(
                                    feedPost!.postedByUserLocation!
                                        .toUpperCase(),
                                    style: _headerStyle(12, FontWeight.w400),
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
    bool? _following = false;
    // var _followCountTextStyle = TextStyle(
    //     fontSize: 16,
    //     fontWeight: FontWeight.w700,
    //     color: AdaptiveTheme.primaryColor(context));
    // var _followLabelStyle =
    //     TextStyle(fontSize: 16, fontWeight: FontWeight.w700);

    var _followCountTextStyle = TextStyle(
        fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black);
    var _followLabelStyle = TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AdaptiveTheme.primaryColor(context));

    bool _checkFollowStatus(QuerySnapshot snap) {
      int exists = snap.docs
          .where((element) =>
              element['userID'] == _loginResponse.b2cParent!.parentID)
          .length;
      return exists > 0 ? _following = true : _following = false;
    }

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
            Spacer(),
            Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 25,
                  child: appButton(
                      context: context,
                      width: 20,
                      height: 20,
                      titleFontSize: 12,
                      title: 'Feeds',
                      titleColour: AdaptiveTheme.primaryColor(context),
                      onPressed: () async {

                        UserFeedsArgs args;
                        if (feedPost == null) {
                          var count = await FirestoreServices.getUserFeedsCount(
                              followingParents!.userID!);
                          args = UserFeedsArgs(followingParents.userID!, true);
                          if (count > 0) {
                            Navigator.of(context).pushNamed(UserFeedsScreen.routeName,
                                arguments: args);
                          }
                        } else {
                          args = UserFeedsArgs(feedPost.postedUserID!, false);
                          Navigator.of(context).pushNamed(UserFeedsScreen.routeName,
                              arguments: args);
                        }
                      },
                      borderColor: AdaptiveTheme.primaryColor(context),
                      borderRadius: 20
                  ),
                ),
                SizedBox(width: 10,),
                ParentBlockUnblockAction(
                    followingParents: followingParents,
                    feedPost: feedPost,
                    loginResponse: _loginResponse),
              ],
            ),
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

class StudentListItem extends StatelessWidget {
  final Child student;
  StudentListItem(
    this.student,
  );

  @override
  Widget build(BuildContext context) {
    TextStyle _headerStyle(double fontSize, FontWeight fontWeight) {
      return Platform.isIOS
          ? AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
              .copyWith(fontSize: fontSize, fontWeight: fontWeight)
          : Theme.of(context)
              .textTheme
              .displayMedium!
              .copyWith(fontSize: fontSize, fontWeight: fontWeight);
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
        child: ListTile(
          leading: getAvatarImage(
              student.imageUrl, 60, 60, BoxShape.circle, student.name),
          isThreeLine: true,
          title: Text(
            student.name,
            style: _headerStyle(18, FontWeight.w500),
          ),
          subtitle: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: '${student.schoolName!}\n',
                    style: _headerStyle(
                        textScale(context) <= 1.0 ? 13 : 15, FontWeight.w300)),
                TextSpan(
                    text: '${student.division}',
                    style: _headerStyle(textScale(context) <= 1.0 ? 13 : 15,
                            FontWeight.w300)
                        .copyWith(color: AdaptiveTheme.secondaryColor(context)))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ParentBlockUnblockAction extends StatefulWidget {
  final FollowingParents? followingParents;
  final FeedPost? feedPost;
  final LoginResponse loginResponse;
  const ParentBlockUnblockAction({
    Key? key,
    required this.feedPost,
    required this.loginResponse,
    required this.followingParents,
  }) : super(key: key);

  @override
  State<ParentBlockUnblockAction> createState() =>
      _ParentBlockUnblockActionState();
}

class _ParentBlockUnblockActionState extends State<ParentBlockUnblockAction> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 25,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirestoreServices.isUserBlocked(
            widget.loginResponse.b2cParent!.parentID, widget.feedPost != null ? widget.feedPost!.postedUserID!:widget.followingParents!.userID!),
        // initialData: null,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Container(
              width: 105,
              height: 25,
              padding: EdgeInsets.all(3),
              child: appButton(
                  context: context,
                  width: 20,
                  height: 20,
                  title: ' ',
                  titleColour: AdaptiveTheme.primaryColor(context),
                  borderColor: AdaptiveTheme.primaryColor(context),
                  onPressed: () {},
                  borderRadius: 20,
                  titleFontSize: 10),
            );
          } else {
            return Container(
              width: 105,
              height: 25,
              // padding: EdgeInsets.all(3),
              child: appButton(
                  context: context,
                  width: 20,
                  height: 20,
                  title: snap.data!.size > 0 ? 'UnBlock' : 'Block',
                  titleColour: AdaptiveTheme.primaryColor(context),
                  borderColor: AdaptiveTheme.primaryColor(context),
                  onPressed: () {
                    if (snap.data!.size > 0) {
                      FirestoreServices.unBlockParent(
                           widget.feedPost,
                          widget.followingParents, widget.loginResponse);
                      setState(() {});
                    } else {
                      FirestoreServices.blockParent(
                           widget.feedPost,
                          widget.followingParents, widget.loginResponse);
                      setState(() {});
                    }
                  },
                  borderRadius: 20,
                  titleFontSize: 10),
            );
          }
        },
      ),
    );
  }
}
