import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../adaptive/adaptive_theme.dart';
import '../../../helpers/route_arguments.dart';
import '../../../src/models/login_response.dart';
import '../../../src/profile/screens/profile_others.dart';
import '../../../src/providers/auth.dart';
import '../../../src/providers/firestore_services.dart';
import '../../../util/app_theme.dart';
import '../../../util/app_theme_cupertino.dart';
import '../screens/profile_others_web.dart';
import '/src/models/firestore/followingparents.dart';
import '/util/ui_helpers.dart';

class FollowersViewItem extends StatefulWidget {
  final FollowingParents followersParents;
  final bool isWeb;

  const FollowersViewItem({
    Key? key,
    required this.followersParents,
    this.isWeb = false,
  }) : super(key: key);
  @override
  State<FollowersViewItem> createState() => _FollowersViewItemState();
}

class _FollowersViewItemState extends State<FollowersViewItem> {
  @override
  Widget build(BuildContext context) {
    LoginResponse _loginResponse =
        Provider.of<Auth>(context, listen: false).loginResponse;
    return GestureDetector(
      onTap: () {
        //
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
          side: BorderSide(color: HexColor.fromHex("#D5D5D5")),
        ),
        elevation: 0,
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SizedBox(
            width: double.infinity,
            //height: 120,
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon(Icons.person, size: 50),
                    InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                              widget.isWeb
                                  ? ProfileOthersScreenWeb.routeName
                                  : ProfileOthersScreen.routeName,
                              arguments: ProfileOthersArgs(
                                  null, widget.followersParents, null));
                        },
                        child: getAvatarImage(
                            widget.followersParents.userImage,
                            50,
                            50,
                            BoxShape.circle,
                            widget.followersParents.userName)),
                    const SizedBox(width: 15),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 100.0),
                            child: Text(
                              '${widget.followersParents.userName}',
                              style: kIsWeb || Platform.isAndroid
                                  ? AppTheme.lightTheme.textTheme.bodySmall!
                                      .copyWith(fontSize: 14)
                                  : AppThemeCupertino
                                      .lightTheme.textTheme.navTitleTextStyle
                                      .copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),

                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // FollowUnFollowAction(
                          //     feedPost: widget.followersParents,
                          //     loginResponse: _loginResponse),
                          // SizedBox(height: 5),
                          ParentBlockUnblockAction(
                              feedPost: widget.followersParents,
                              loginResponse: _loginResponse),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FollowUnFollowAction extends StatefulWidget {
  final FollowingParents feedPost;
  final LoginResponse loginResponse;
  const FollowUnFollowAction({
    Key? key,
    required this.feedPost,
    required this.loginResponse,
  }) : super(key: key);

  @override
  State<FollowUnFollowAction> createState() => _FollowUnFollowActionState();
}

class _FollowUnFollowActionState extends State<FollowUnFollowAction> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirestoreServices.isUserFollower(
            widget.feedPost.userID!, widget.loginResponse.b2cParent!.parentID),
        // initialData: null,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Container(
                width: 110,
                height: 25,
                padding: EdgeInsets.all(3),
                child: appButton(
                    context: context,
                    width: 20,
                    height: 20,
                    title: 'Remove',
                    titleColour: AdaptiveTheme.primaryColor(context),
                    borderColor: AdaptiveTheme.primaryColor(context),
                    onPressed: () {},
                    titleFontSize:
                        10) /*ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary:Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                          color: AdaptiveTheme.primaryColor(context))),
                ),
                onPressed: ()  {},
                child:  Text("Remove",
                  style: TextStyle(
                    fontSize: 10,
                    color: AdaptiveTheme.primaryColor(context),
                  ),),
              ),*/
                );

            /*RoundButton(
                color: AppTheme.primaryColor,
                title: 'Remove',
                onPressed: () {});*/
          } else {
            return Container(
              width: 110,
              height: 30,
              // padding: EdgeInsets.all(3),
              child: appButton(
                  context: context,
                  width: 20,
                  height: 20,
                  title: snap.data!.size > 0 ? 'Remove' : 'Follow Back',
                  titleColour: AdaptiveTheme.primaryColor(context),
                  borderColor: AdaptiveTheme.primaryColor(context),
                  onPressed: () {
                    if (snap.data!.size > 0) {
                      FirestoreServices.doRemoveFollowers(
                          widget.feedPost, widget.loginResponse);
                      setState(() {});
                    } else {
                      FirestoreServices.undoRemove(
                          widget.feedPost, widget.loginResponse);
                      setState(() {});
                    }
                  },
                  titleFontSize: 10),
            );
          }
        },
      ),
    );
  }
}

class ParentBlockUnblockAction extends StatefulWidget {
  final FollowingParents feedPost;
  final LoginResponse loginResponse;
  const ParentBlockUnblockAction({
    Key? key,
    required this.feedPost,
    required this.loginResponse,
  }) : super(key: key);

  @override
  State<ParentBlockUnblockAction> createState() =>
      _ParentBlockUnblockActionState();
}

class _ParentBlockUnblockActionState extends State<ParentBlockUnblockAction> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirestoreServices.isUserBlocked(
            widget.loginResponse.b2cParent!.parentID, widget.feedPost.userID!),
        // initialData: null,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Container(
              width: 110,
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
                  titleFontSize: 10),
            );
          } else {
            return Container(
              width: 110,
              height: 30,
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
                          null,widget.feedPost, widget.loginResponse);
                      setState(() {});
                    } else {
                      FirestoreServices.blockParent(
                          null,widget.feedPost, widget.loginResponse);
                      setState(() {});
                    }
                  },
                  titleFontSize: 10),
            );
          }
        },
      ),
    );
  }
}


//