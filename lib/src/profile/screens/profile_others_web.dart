import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/util/dialogs.dart';
import '../../../adaptive/adaptive_circular_progressInd.dart';

import '../../../adaptive/adaptive_theme.dart';
import '../../../util/app_theme.dart';
import '../../../widgets/web_banner.dart';
import '../../../widgets/web_bottom_bar.dart';
import '../../home/feeds/screens/user_feeds_web.dart';
import '../../providers/homestaticdata_new.dart';
import '/helpers/route_arguments.dart';
import '/src/models/child.dart';
import '/src/models/firestore/followingparents.dart';
import '/src/models/login_response.dart';
import '/src/providers/auth.dart';
import '/src/providers/children.dart';

import '/src/models/firestore/feedpost.dart';

import '/src/providers/firestore_services.dart';

import '../../../util/ui_helpers.dart';

class ProfileOthersScreenWeb extends StatefulWidget {
  const ProfileOthersScreenWeb({Key? key}) : super(key: key);
  static String routeName = '/web-profile-others';

  @override
  _ProfileOthersScreenWebState createState() => _ProfileOthersScreenWebState();
}

class _ProfileOthersScreenWebState extends State<ProfileOthersScreenWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
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
            }).onError((error, stackTrace) {
              setState(() {
                _isLoading = false;
              });
              Dialogs().ackAlert(context, "Error", error.toString());
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

    Widget _bodyWidget() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpaceSmall,
              HeaderSection(feedPost, followingParents, students),
              verticalSpaceMedium,
              //CHILD DETAILS
              GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                //padding: const EdgeInsets.all(10.0),
                itemCount: students.length, // + 10,
                itemBuilder: (ctx, index) {
                  //if (index > students.length - 1) index = 0;
                  return StudentListItemWeb(students[index]);
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth(context) > 800
                        ? 3
                        : screenWidth(context) > 400
                            ? 2
                            : 1,
                    childAspectRatio: 1 / 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 100),
              ),

              //CHILD DETAILS
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      endDrawer: WebBannerDrawer(),
      body: SizedBox(
        height: screenHeight(context),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              WebBanner(
                showMenu: true,
                showHomeButton: true,
                showProfileButton: true,
                scaffoldKey: scaffoldKey,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 85.0, top: 40),
                child: Row(
                  children: [
                    Text(
                      "Parent's Profile",
                      style: TextStyle(
                          letterSpacing: 0.0,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              Container(
                width: screenWidth(context) * 0.90,
                height: screenHeight(context) * 0.98,
                child: _isLoading == false
                    ? _bodyWidget()
                    : Center(child: AdaptiveCircularProgressIndicator()),
              ),
              WebBottomBar(),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  final FeedPost? feedPost;
  final FollowingParents? followingParents;
  final List<Child> students;
  HeaderSection(
    this.feedPost,
    this.followingParents,
    this.students,
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
      elevation: 1.0,
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
            cardFooter(context, feedPost, followingParents, students),
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
    List<Child> students,
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
        fontSize: screenWidth(context) > 800 ? 15 : 13,
        fontWeight: FontWeight.w700,
        color: Colors.black);
    var _followLabelStyle = TextStyle(
        fontSize: screenWidth(context) > 800 ? 15 : 13,
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
                    UserFeedsWebArgs args;
                    if (feedPost == null) {
                      args = UserFeedsWebArgs(followingParents!.userID!, true,
                          students, feedPost, followingParents);
                      Navigator.of(context).pushNamed(
                          UserFeedsScreenWeb.routeName,
                          arguments: args);
                    } else {
                      args = UserFeedsWebArgs(feedPost.postedUserID!, false,
                          students, feedPost, followingParents);
                      Navigator.of(context).pushNamed(
                          UserFeedsScreenWeb.routeName,
                          arguments: args);
                    }
                  },
                  borderColor: AdaptiveTheme.primaryColor(context),
                  borderRadius: 20),
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

class StudentListItemWeb extends StatelessWidget {
  final Child student;
  StudentListItemWeb(
    this.student,
  );

  @override
  Widget build(BuildContext context) {
    TextStyle _headerStyle(double fontSize, FontWeight fontWeight) {
      return Theme.of(context)
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
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
        child: ListTile(
          leading: getAvatarImage(
              student.imageUrl,
              screenWidth(context) > 800 ? 70 : 40,
              screenWidth(context) > 800 ? 70 : 40,
              BoxShape.circle,
              student.name),
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
                    style: _headerStyle(13, FontWeight.w300)),
                TextSpan(
                    text: '${student.division}',
                    style: _headerStyle(13, FontWeight.w300)
                        .copyWith(color: AdaptiveTheme.secondaryColor(context)))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
