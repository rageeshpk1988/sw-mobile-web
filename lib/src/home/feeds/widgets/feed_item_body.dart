//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../helpers/route_arguments.dart';

import '../../../vendor_profile/screens/vendor_profile.dart';
import '/src/models/login_response.dart';
import '/src/profile/screens/profile.dart';
import '/src/profile/screens/profile_others.dart';
import '/src/providers/auth.dart';

import '/src/models/firestore/feedpost.dart';
import '/util/date_util.dart';
import '/util/expandable_text.dart';
import '/util/ui_helpers.dart';
import 'file_carousel.dart';

class FeedItemBody extends StatefulWidget {
  final FeedPost feedPost;
  final bool showAddComment;
  final bool enableProfileNaviagate;
  const FeedItemBody({
    Key? key,
    required this.feedPost,
    required this.showAddComment,
    required this.enableProfileNaviagate,
  }) : super(key: key);

  @override
  State<FeedItemBody> createState() => _FeedItemBodyState();
}

void _share(BuildContext ctx, FeedPost feedPost) {
  final RenderBox box = ctx.findRenderObject() as RenderBox;

  String textToShare =
      'Your friend has shared the following details from SchoolWizard App.'
      '\n\n${feedPost.title}'
      '\n\n${feedPost.description}';
  if (feedPost.fileObjs!.isNotEmpty) {
    textToShare = '$textToShare'
        '\n\nClick below link to view the media file.';
    feedPost.fileObjs!.forEach((element) {
      if (element.type == 'image')
        textToShare = '$textToShare\n\n${appImageUrl(element.url!)}';
      else {
        textToShare = '$textToShare\n\n${appVideoUrl(element.url!)}';
      }
    });
  }
  Share.share(textToShare,
      subject: 'SchoolWizard App.',
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
}

class _FeedItemBodyState extends State<FeedItemBody> {
  @override
  Widget build(BuildContext context) {
    final LoginResponse _loginResponse =
        Provider.of<Auth>(context, listen: false).loginResponse;

    Widget _buildTimeDifference() {
      DateTime today = DateTime.now();
      if (DateUtil.calculateDifference(widget.feedPost.updatedAt!) ==
          0) //means today
      {
        var diff = today.difference(widget.feedPost.updatedAt!).inHours;
        if (diff > 1) {
          return Text('$diff Hrs.', style: TextStyle(fontSize: 12));
        } else {
          return Text('$diff Hr.', style: TextStyle(fontSize: 12));
        }
      } else
        return Container();
    }

    return SizedBox(
      width: double.infinity,
      //height: 360,
      child: Column(
        children: [
          //HEADER
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: !widget.enableProfileNaviagate
                    ? () {}
                    : () {
                        if (widget.feedPost.postedUserID ==
                            _loginResponse.b2cParent!.parentID) {
                          Navigator.of(context)
                              .pushNamed(ProfileScreen.routeName);
                        } else {
                          if (widget.feedPost.postedBy == 'Vendor') {
                            Navigator.of(context).pushNamed(
                                VendorProfileScreen.routeName,
                                arguments: ProfileOthersArgs(
                                    widget.feedPost, null, null));
                          } else {
                            Navigator.of(context).pushNamed(
                                ProfileOthersScreen.routeName,
                                arguments: ProfileOthersArgs(
                                    widget.feedPost, null, null));
                          }
                        }
                      },
                child: getAvatarImage(widget.feedPost.profileImage, 45, 45,
                    BoxShape.circle, widget.feedPost.postedUserName),
              ),
              const SizedBox(width: 5),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      '${widget.feedPost.postedUserName!.length > 14 ? widget.feedPost.postedUserName!.substring(0, 14) + ' ...' : widget.feedPost.postedUserName} ',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                      DateUtil.formattedDateExtended_1(
                          widget.feedPost.createdAt!),
                      style: const TextStyle(fontSize: 11)),
                ],
              ),
              Spacer(),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () {
                      _share(context, widget.feedPost);
                    },
                    icon: Icon(
                      Icons.share_outlined,
                      color: Color(0xff8C0A95),
                    ),
                  ),
                  _buildTimeDifference(),
                ],
              )
            ],
          ),
          //HEADER
          //TITLE AND DESCRIPTION
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.feedPost.title!,
              style: TextStyle(
                  fontSize: textScale(context) <= 1.0 ? 17 : 13,
                  fontWeight: FontWeight.w600),
              //textAlign: TextAlign.justify,
            ),
          ),
          const SizedBox(height: 5),
          ExpandableText(widget.feedPost.description!, 150, true),
          const SizedBox(height: 5),
          //TITLE AND DESCRIPTION
          //IMAGE AND VIDEO
          if (widget.feedPost.fileObjs!.isNotEmpty)
            //FileCarousel(widget.feedPost.fileObjs),
            FileCarousel(widget.feedPost.fileObjs),
          if (widget.feedPost.fileObjs!.isEmpty)
            Image.asset(
              'assets/images/b2c_splash_logo1.png',
              height: 200,
            ),
          //IMAGE AND VIDEO
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
