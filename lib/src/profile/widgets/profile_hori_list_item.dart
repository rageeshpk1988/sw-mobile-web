import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../helpers/route_arguments.dart';

import '../../../helpers/connectivity_helper.dart';

import '../../../util/app_theme_cupertino.dart';
import '../../vendor_profile/screens/vendor_profile.dart';
import '/src/models/firestore/followingparents.dart';

import '/util/ui_helpers.dart';

class BasicProfileItemWidget extends StatefulWidget {
  final FollowingParents followingParents;

  const BasicProfileItemWidget({Key? key, required this.followingParents})
      : super(key: key);

  @override
  State<BasicProfileItemWidget> createState() => _BasicProfileItemWidgetState();
}

class _BasicProfileItemWidgetState extends State<BasicProfileItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      //width: 130,
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  child: getAvatarImage(widget.followingParents.userImage, 60,
                      60, BoxShape.circle, widget.followingParents.userName)),
              const SizedBox(height: 10),
              SizedBox(
                width: 80,
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${widget.followingParents.userName}',
                          style: kIsWeb || Platform.isAndroid
                              ? Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)
                              : AppThemeCupertino
                                  .lightTheme.textTheme.navTitleTextStyle
                                  .copyWith(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
