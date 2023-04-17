import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../helpers/route_arguments.dart';

import '../../../helpers/connectivity_helper.dart';

import '../../vendor_profile/screens/vendor_profile.dart';
import '/src/models/firestore/followingparents.dart';

import '/util/ui_helpers.dart';

class ProfileHorizontalListItemWeb extends StatefulWidget {
  final FollowingParents followingParents;

  const ProfileHorizontalListItemWeb({Key? key, required this.followingParents})
      : super(key: key);

  @override
  State<ProfileHorizontalListItemWeb> createState() =>
      _ProfileHorizontalListItemWebState();
}

class _ProfileHorizontalListItemWebState
    extends State<ProfileHorizontalListItemWeb> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(5.0)),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
                onTap: () async {
                  if (await ConnectivityHelper.hasInternet<ProfileOthersArgs>(
                          context,
                          VendorProfileScreen.routeName,
                          ProfileOthersArgs(
                              null, widget.followingParents, null)) ==
                      true) {
                    Navigator.of(context)
                        .pushNamed(VendorProfileScreen.routeName,
                            arguments: ProfileOthersArgs(
                              null,
                              widget.followingParents,
                              null,
                            ));
                  }
                },
                child: getAvatarImage(widget.followingParents.userImage, 60, 60,
                    BoxShape.circle, widget.followingParents.userName)),
            const SizedBox(width: 10),
            SizedBox(
              width: 150,
              child: Flexible(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${widget.followingParents.userName}',
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w700),
                    maxLines: 3,
                    //textAlign: TextAlign.start,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
