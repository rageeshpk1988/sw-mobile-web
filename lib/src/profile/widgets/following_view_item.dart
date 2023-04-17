import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../adaptive/adaptive_theme.dart';
import '../../../helpers/route_arguments.dart';
import '../../../src/profile/screens/profile_others.dart';
import '../../../src/providers/auth.dart';
import '../../../src/providers/firestore_services.dart';
import '../../../src/models/login_response.dart';
import '../../../util/app_theme.dart';
import '../../../util/app_theme_cupertino.dart';
import '../screens/profile_others_web.dart';
import '/src/models/firestore/followingparents.dart';
import '/util/ui_helpers.dart';

class FollowingViewItem extends StatefulWidget {
  final FollowingParents followingParents;
  final bool isWeb;
  const FollowingViewItem({
    Key? key,
    required this.followingParents,
    this.isWeb = false,
  }) : super(key: key);
  @override
  State<FollowingViewItem> createState() => _FollowingViewItemState();
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
        stream: FirestoreServices.isUserFollowing(
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
                  title: 'Follow',
                  titleColour: AdaptiveTheme.primaryColor(context),
                  borderColor: AdaptiveTheme.primaryColor(context),
                  onPressed: () {},
                  titleFontSize: 10),
              /*ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary:Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                          color: AdaptiveTheme.primaryColor(context))),
                ),
                onPressed: ()  {},
                child:  Text("Follow",
                  style: TextStyle(
                    fontSize: 10,
                    color: AdaptiveTheme.primaryColor(context),
                  ),),
              ),*/
            );

            /*RoundButton(
                color: AppTheme.primaryColor,
                title: 'Follow',
                onPressed: () {});*/
          } else {
            return Container(
                width: 110,
                height: 25,
                padding: EdgeInsets.all(3),
                child: appButton(
                    context: context,
                    width: 20,
                    height: 20,
                    title: snap.data!.size > 0 ? 'Unfollow' : 'Follow',
                    titleColour: AdaptiveTheme.primaryColor(context),
                    borderColor: AdaptiveTheme.primaryColor(context),
                    onPressed: () {
                      if (snap.data!.size > 0) {
                        FirestoreServices.undoFollowNew(
                            widget.feedPost, widget.loginResponse);
                        setState(() {});
                      } else {
                        FirestoreServices.doFollowNew(
                            widget.feedPost, widget.loginResponse);
                        setState(() {});
                      }
                    },
                    titleFontSize: 10));
          }
        },
      ),
    );
  }
}

class _FollowingViewItemState extends State<FollowingViewItem> {
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
                                null, widget.followingParents, null));
                      },
                      child: getAvatarImage(
                          widget.followingParents.userImage,
                          50,
                          50,
                          BoxShape.circle,
                          widget.followingParents.userName),
                    ),
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
                              '${widget.followingParents.userName}',
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
                      child: FollowUnFollowAction(
                          feedPost: widget.followingParents,
                          loginResponse: _loginResponse),
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
//