import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/src/home/new_post/post_achievement_web.dart';
import '/src/home/new_post/post_activity_web.dart';
import '/src/home/new_post/post_general_web.dart';
import '/util/notify_user.dart';

import '../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../adaptive/adaptive_theme.dart';

import '../../../helpers/route_arguments.dart';
import '../../../util/app_theme.dart';
import '../../../util/dialogs.dart';
import '../../../util/ui_helpers.dart';

import '../../home/feeds/screens/user_feeds.dart';

import '../../models/login_response.dart';
import '../../providers/auth.dart';
import '../../providers/firestore_services.dart';

import '../screens/followers_screen_web.dart';
import '../screens/following_screen_web.dart';

class NewFeedsHeaderSectionWeb extends StatefulWidget {
  final Function refreshHandler;
  final bool enableFollowersNavigation;
  final bool showFeedButton;
  NewFeedsHeaderSectionWeb(
    this.refreshHandler,
    this.enableFollowersNavigation,
    this.showFeedButton,
  );
  @override
  State<NewFeedsHeaderSectionWeb> createState() =>
      _NewFeedsHeaderSectionWebState();
}

class _NewFeedsHeaderSectionWebState extends State<NewFeedsHeaderSectionWeb> {
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
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _headerStyle(double fontSize, FontWeight fontWeight) {
      return AppTheme.lightTheme.textTheme.bodySmall!
          .copyWith(fontSize: fontSize, fontWeight: fontWeight);
    }

    return Center(
      child: Card(
        elevation: 0.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getAvatarImage(
                    _loginResponse == null
                        ? null
                        : _loginResponse!.b2cParent!.profileImage,
                    screenWidth(context) > 400 ? 80 : 50,
                    screenWidth(context) > 400 ? 80 : 50,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            child: Text(
                              _loginResponse == null
                                  ? ' '
                                  : _loginResponse!.b2cParent!.name,
                              style: _headerStyle(18, FontWeight.w600),
                            ),
                          ),
                          verticalSpaceTiny,
                          Row(
                            children: [
                              Text(
                                _loginResponse == null
                                    ? ''
                                    : _loginResponse!.b2cParent!.state!
                                        .toUpperCase(),
                                style: _headerStyle(12, FontWeight.w400),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _loginResponse == null
                                    ? ''
                                    : _loginResponse!.b2cParent!.location!
                                        .toUpperCase(),
                                style: _headerStyle(12, FontWeight.w400),
                              ),
                            ],
                          ),
                          if (screenWidth(context) > 400) verticalSpaceTiny,
                          if (screenWidth(context) > 400)
                            _followCountWidget(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (screenWidth(context) <= 400) verticalSpaceTiny,
              if (screenWidth(context) <= 400)
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: _followCountWidget(context),
                ),
              Divider(),
              if (widget.showFeedButton)
                Row(
                  children: [
                    FeedButtonWeb(loginResponse: _loginResponse),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  _followCountWidget(BuildContext context) {
    var _followCountTextStyle = TextStyle(
        fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black);
    var _followLabelStyle = TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AdaptiveTheme.primaryColor(context));
    int? kycstatus = Provider.of<Auth>(context, listen: true).kycResponse;

    Future showNewPostPopup(Widget widget) {
      return showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: SizedBox(
                width: screenWidth(context) > 800
                    ? screenWidth(context) * 0.50
                    : screenWidth(context) * 0.98,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.close,
                            size: 30,
                            color: Colors.black,
                          )),
                      widget,
                    ],
                  ),
                )),
          ),
        ),
      );
    }

    List<Widget> _items = [
      //Item 0
      GestureDetector(
        onTap: () {
          if (widget.enableFollowersNavigation) {
            if (_followingcount > 0)
              Navigator.of(context).pushNamed(FollowingScreenWeb.routeName);
          }
        },
        child: AutoSizeText(
          'Following',
          textAlign: TextAlign.center,
          style: _followLabelStyle,
          maxFontSize: 14,
          maxLines: 1,
          minFontSize: 10,
          stepGranularity: 1,
        ),
      ),
      // horizontalSpaceSmall,
      //item 1
      StreamBuilder<QuerySnapshot>(
          stream: FirestoreServices.getFollowingParents(
              _loginResponse!.b2cParent!.parentID),
          builder: (context, followersSnapshot) {
            if (followersSnapshot.connectionState == ConnectionState.waiting) {
              return Icon(Icons.more_horiz, color: Colors.grey.shade100);
            } else if (followersSnapshot.hasData) {
              _followingcount = followersSnapshot.data!.size.toInt();
              return AutoSizeText(
                followersSnapshot.data!.size.toString(),
                textAlign: TextAlign.center,
                style: _followCountTextStyle,
                maxFontSize: 14,
                maxLines: 1,
                minFontSize: 10,
                stepGranularity: 1,
              );
            }
            return Center(child: AdaptiveCircularProgressIndicator());
          }),
      //  VerticalDivider(thickness: 2),
      // horizontalSpaceMedium,
      //item 2
      GestureDetector(
        onTap: () {
          if (widget.enableFollowersNavigation) {
            if (_followercount > 0)
              Navigator.of(context).pushNamed(
                FollowersScreenWeb.routeName,
              );
          }
        },
        child: AutoSizeText(
          'Followers',
          textAlign: TextAlign.center,
          style: _followLabelStyle,
          maxFontSize: 14,
          maxLines: 1,
          minFontSize: 10,
          stepGranularity: 1,
        ),
      ),
      // horizontalSpaceSmall,
      //item 3
      StreamBuilder<QuerySnapshot>(
          stream: FirestoreServices.getFollowersParents(
              _loginResponse!.b2cParent!.parentID),
          builder: (context, followersSnapshot) {
            if (followersSnapshot.connectionState == ConnectionState.waiting) {
              return Icon(Icons.more_horiz, color: Colors.grey.shade100);
            } else if (followersSnapshot.hasData) {
              _followercount = followersSnapshot.data!.size.toInt();
              return AutoSizeText(
                followersSnapshot.data!.size.toString(),
                textAlign: TextAlign.center,
                style: _followCountTextStyle,
                maxFontSize: 14,
                maxLines: 1,
                minFontSize: 10,
                stepGranularity: 1,
              );
            }
            return Center(child: AdaptiveCircularProgressIndicator());
          }),
      //  const Spacer(),
      //item 4
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () {
              if (kycstatus != 1) {
                Dialogs()
                    .ackInfoAlert(context, 'Your KYC is not approved yet...');
                return;
              } else {
                showNewPostPopup(PostActivityWeb());
              }
            },
            icon: Icon(
              Icons.dashboard,
              color: Colors.grey,
            ),
            label: Text(
              'Activity',
              style: TextStyle(
                  fontSize: (screenWidth(context) > 400 ? 16 : 12),
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0),
            ),
            style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
          ),
          VerticalDivider(),
          TextButton.icon(
            onPressed: () {
              if (kycstatus != 1) {
                Dialogs()
                    .ackInfoAlert(context, 'Your KYC is not approved yet...');
                return;
              } else {
                showNewPostPopup(PostAchievementWeb());
              }
            },
            icon: Icon(
              Icons.local_activity,
              color: Colors.grey,
            ),
            label: Text(
              'Achievements',
              style: TextStyle(
                  fontSize: (screenWidth(context) > 400 ? 16 : 12),
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0),
            ),
            style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
          ),
          VerticalDivider(),
          TextButton.icon(
            onPressed: () {
              if (kycstatus != 1) {
                Dialogs()
                    .ackInfoAlert(context, 'Your KYC is not approved yet...');
                return;
              } else {
                showNewPostPopup(PostGeneralWeb());
              }
            },
            icon: Icon(
              Icons.notes,
              color: Colors.grey,
            ),
            label: Text(
              'General',
              style: TextStyle(
                  fontSize: (screenWidth(context) > 400 ? 16 : 12),
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0),
            ),
            style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
          )
        ],
      )
    ];
    return SizedBox(
      width: screenWidth(context),
      child: screenWidth(context) > 400
          ? Row(
              children: [
                _items[0],
                horizontalSpaceSmall,
                _items[1],
                VerticalDivider(thickness: 2),
                horizontalSpaceMedium,
                _items[2],
                horizontalSpaceSmall,
                _items[3],
                const Spacer(),
                _items[4],
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _items[0],
                    horizontalSpaceSmall,
                    _items[1],
                    horizontalSpaceMedium,
                    _items[2],
                    horizontalSpaceSmall,
                    _items[3],
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _items[4],
                  ],
                ),
              ],
            ),
    );
  }
}

class FeedButtonWeb extends StatefulWidget {
  const FeedButtonWeb({
    Key? key,
    required LoginResponse? loginResponse,
  })  : _loginResponse = loginResponse,
        super(key: key);

  final LoginResponse? _loginResponse;

  @override
  State<FeedButtonWeb> createState() => _FeedButtonWebState();
}

class _FeedButtonWebState extends State<FeedButtonWeb> {
  bool _isloading2 = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextButton.icon(
        icon: Icon(
          Icons.feed,
          color: AdaptiveTheme.primaryColor(context),
        ),
        label: Text(
          'Feeds',
          style: TextStyle(
              fontSize: 18, color: Colors.black, fontWeight: FontWeight.w700),
        ),
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
                  NotifyUser().showSnackBar(
                      "No feeds have been shared by you", context);
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
      ),
    );
  }
}
