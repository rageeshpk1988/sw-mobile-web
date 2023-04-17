import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/src/profile/screens/profile_update_web.dart';

import '../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../adaptive/adaptive_theme.dart';

import '../../../helpers/connectivity_helper.dart';
import '../../../helpers/route_arguments.dart';
import '../../../util/app_theme.dart';
import '../../../util/notify_user.dart';
import '../../../util/ui_helpers.dart';

import '../../../widgets/round_rect_action_button.dart';
import '../../home/feeds/screens/user_feeds.dart';

import '../../models/login_response.dart';
import '../../providers/auth.dart';
import '../../providers/firestore_services.dart';

import '../screens/add_child_web.dart';
import '../screens/followers_screen_web.dart';
import '../screens/following_screen_web.dart';

class ProfileHeaderSectionWeb extends StatefulWidget {
  final Function refreshHandler;
  final bool enableFollowersNavigation;
  final bool showFeedButton;
  ProfileHeaderSectionWeb(
    this.refreshHandler,
    this.enableFollowersNavigation,
    this.showFeedButton,
  );
  @override
  State<ProfileHeaderSectionWeb> createState() =>
      _ProfileHeaderSectionWebState();
}

class _ProfileHeaderSectionWebState extends State<ProfileHeaderSectionWeb> {
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

  void refreshPage() {
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

    var headingSize = screenWidth(context) > 800 ? 18.0 : 14.0;
    var subHeadingSize = screenWidth(context) > 800 ? 12.0 : 10.0;

    return Card(
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
                  screenWidth(context) > 800 ? 70 : 50,
                  screenWidth(context) > 800 ? 70 : 50,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              child: Text(
                                _loginResponse == null
                                    ? ' '
                                    : _loginResponse!.b2cParent!.name,
                                style:
                                    _headerStyle(headingSize, FontWeight.w600),
                              ),
                            ),
                            if (widget.showFeedButton)
                              const SizedBox(width: 10),
                            //EDIT BUTTON
                            if (widget.showFeedButton)
                              RoundRectActionButton(
                                size: screenWidth(context) *
                                    (screenWidth(context) > 800
                                        ? 0.018
                                        : screenWidth(context) > 400
                                            ? 0.035
                                            : 0.06),
                                iconData: Icons.edit_outlined,
                                onTap: () async {
                                  if (await ConnectivityHelper.hasInternet<
                                              Function>(
                                          context,
                                          ProfileUpdateScreenWeb.routeName,
                                          viewRefresh) ==
                                      true) {
                                    Navigator.of(context).pushNamed(
                                        ProfileUpdateScreenWeb.routeName,
                                        arguments: viewRefresh);
                                  }
                                },
                              ),
                            //EDIT BUTTON
                          ],
                        ),
                        verticalSpaceTiny,
                        Row(
                          children: [
                            SizedBox(
                              width: screenWidth(context) * 0.41,
                              child: Text(
                                '${_loginResponse == null ? '' : _loginResponse!.b2cParent!.state!.toUpperCase()} ${_loginResponse == null ? '' : _loginResponse!.b2cParent!.location!.toUpperCase()}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: _headerStyle(
                                    subHeadingSize, FontWeight.w400),
                              ),
                            ),
                            if (widget.showFeedButton) const Spacer(),
                            if (widget.showFeedButton)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 75,
                                    height: 25,
                                    child: appButton(
                                        context: context,
                                        width: 20,
                                        height: 20,
                                        titleFontSize: 12,
                                        title: 'Add Child',
                                        titleColour:
                                            AdaptiveTheme.primaryColor(context),
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                              AddChildScreenWeb.routeName,
                                              arguments: refreshPage);
                                        },
                                        borderColor:
                                            AdaptiveTheme.primaryColor(context),
                                        borderRadius: 20),
                                  ),
                                ],
                              )
                          ],
                        ),
                        if (screenWidth(context) >= 800) verticalSpaceTiny,
                        if (screenWidth(context) >= 800)
                          _followCountWidget(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (screenWidth(context) < 800) verticalSpaceTiny,
            if (screenWidth(context) < 800) _followCountWidget(context),
          ],
        ),
      ),
    );
  }

  _followCountWidget(BuildContext context) {
    var _followCountTextStyle = TextStyle(
        fontSize: screenWidth(context) > 800 ? 15 : 12,
        fontWeight: FontWeight.w700,
        color: Colors.black);
    var _followLabelStyle = TextStyle(
        fontSize: screenWidth(context) > 800 ? 15 : 12,
        fontWeight: FontWeight.w700,
        color: AdaptiveTheme.primaryColor(context));

    return SizedBox(
      width: screenWidth(context) * (screenWidth(context) > 400 ? 0.83 : 0.75),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (widget.enableFollowersNavigation) {
                if (_followingcount > 0)
                  Navigator.of(context).pushNamed(FollowingScreenWeb.routeName);
              }
            },
            child: Text(
              'Following',
              style: _followLabelStyle,
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
                    maxFontSize: 14,
                    maxLines: 1,
                    minFontSize: 10,
                    stepGranularity: 1,
                  );
                }
                return Center(child: AdaptiveCircularProgressIndicator());
              }),
          VerticalDivider(thickness: 2),
          horizontalSpaceTiny,
          GestureDetector(
            onTap: () {
              if (widget.enableFollowersNavigation) {
                if (_followercount > 0)
                  Navigator.of(context).pushNamed(
                    FollowersScreenWeb.routeName,
                  );
              }
            },
            child: Text(
              'Followers',
              style: _followLabelStyle,
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
                    maxFontSize: 14,
                    maxLines: 1,
                    minFontSize: 10,
                    stepGranularity: 1,
                  );
                }
                return Center(child: AdaptiveCircularProgressIndicator());
              }),
          if (widget.showFeedButton) Spacer(),
          if (widget.showFeedButton)
            FeedButtonWeb(loginResponse: _loginResponse),
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
      width: 75,
      height: 25,
      child: appButton(
          context: context,
          width: 20,
          height: 20,
          titleFontSize: 12,
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
          borderColor: AdaptiveTheme.primaryColor(context),
          borderRadius: 20),
    );
  }
}
