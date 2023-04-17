import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '/helpers/global_variables.dart';
import '/util/dialogs.dart';
import '../../../../adaptive/adaptive_theme.dart';
import '../../../../src/home/feeds/widgets/product_carousel.dart';

import '../../../../util/app_theme_cupertino.dart';
import '../../../../util/ui_helpers.dart';
import 'feed_item_body.dart';
import '/src/home/feeds/screens/feedDetails.dart';
import '/src/models/firestore/feed_like.dart';
import '/src/models/login_response.dart';
import '/src/providers/auth.dart';
import '/src/providers/firestore_services.dart';
import '/src/models/firestore/feedpost.dart';
import '/util/app_theme.dart';

class FeedItemCard extends StatefulWidget {
  final FeedPost feedPost;
  final bool showAddComment;
  final bool enableProfileNaviagate;
  const FeedItemCard({
    Key? key,
    required this.feedPost,
    required this.showAddComment,
    required this.enableProfileNaviagate,
  }) : super(key: key);

  @override
  State<FeedItemCard> createState() => _FeedItemCardState();
}

class _FeedItemCardState extends State<FeedItemCard> {
  LoginResponse? _loginResponse;
  var _isInIt = true;
  late FeedLike feedLike;
  bool _activeLikeState = false;
  int selectedReportOption = 0;
  @override
  void didChangeDependencies() {
    if (_isInIt) {
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
      feedLike = FeedLike(
        feedId: widget.feedPost.documentId!,
        createdAt: DateTime.now(),
        userId: _loginResponse!.b2cParent!.parentID,
        userImage: _loginResponse!.b2cParent!.profileImage,
        userName: _loginResponse!.b2cParent!.name,
      );
      _isInIt = false;
    }

    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    selectedReportOption = 0;
  }

  // setSelectedReportOption(int index) {
  //   setState(() {
  //     selectedReportOption = index;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final AutoSizeGroup descGroup = AutoSizeGroup();

    Future _reportAbuse() {
      return showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (BuildContext context, setState) {
                return Dialog(
                  insetPadding: EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(12.0, 25.0, 12.0, 25.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Report Post',
                            style: kIsWeb || Platform.isAndroid
                                ? AppTheme.lightTheme.textTheme.bodyMedium!
                                    .copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400)
                                : AppThemeCupertino
                                    .lightTheme.textTheme.navTitleTextStyle
                                    .copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: ListView.separated(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount:
                                  GlobalVariables.reportAbuseOptions.length,
                              itemBuilder: (BuildContext context, int index) {
                                return SizedBox(
                                  height: 20,
                                  child: Row(
                                    children: [
                                      Radio(
                                        splashRadius: 15,
                                        activeColor: Colors.black,
                                        value: index,
                                        groupValue: selectedReportOption,
                                        onChanged: (val) {
                                          setState(() {
                                            selectedReportOption = val as int;
                                            //setSelectedReportOption(val);
                                          });
                                        },
                                      ),
                                      AutoSizeText(
                                        GlobalVariables
                                            .reportAbuseOptions[index],
                                        minFontSize: 15,
                                        maxFontSize: 16,
                                        style: kIsWeb || Platform.isAndroid
                                            ? AppTheme.lightTheme.textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w300)
                                            : AppThemeCupertino.lightTheme
                                                .textTheme.navTitleTextStyle
                                                .copyWith(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w300),
                                        maxLines: 1,
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        stepGranularity: 1,
                                        group: descGroup,
                                      ),

                                      /*Text(
                                      'Agree',
                                      style: new TextStyle(
                                          fontSize: 11.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600),
                                    )*/
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const Divider(),
                            ),
                          ),
                          SizedBox(height: 30),
                          AutoSizeText(
                            'The reported user posts are reviewed by SchoolWizard support team to determine whether the post violate the community guidelines. Post will be removed, if finds its violating the guidelines.',
                            minFontSize: 13,
                            maxFontSize: 14,
                            style: kIsWeb || Platform.isAndroid
                                ? AppTheme.lightTheme.textTheme.bodyMedium!
                                    .copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300)
                                : AppThemeCupertino
                                    .lightTheme.textTheme.navTitleTextStyle
                                    .copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300),
                            maxLines: 6,
                            softWrap: true,
                            textAlign: TextAlign.left,
                            stepGranularity: 1,
                            group: descGroup,
                          ),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              appButton(
                                context: context,
                                width: 100,
                                height: 28,
                                titleFontSize: 14,
                                title: 'Cancel',
                                titleColour:
                                    AdaptiveTheme.secondaryColor(context),
                                borderColor:
                                    AdaptiveTheme.secondaryColor(context),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              horizontalSpaceSmall,
                              appButton(
                                context: context,
                                width: 100,
                                height: 30,
                                titleFontSize: 14,
                                title: 'Report',
                                titleColour:
                                    AdaptiveTheme.primaryColor(context),
                                borderColor:
                                    AdaptiveTheme.primaryColor(context),
                                onPressed: () async {
                                  var retValue = await FirestoreServices
                                      .updateReportedStatus(
                                          widget.feedPost.documentId!,
                                          selectedReportOption + 1);

                                  if (retValue == true) {
                                    await Dialogs().ackAlert(
                                        context,
                                        'Report Post',
                                        'Your request has been submitted successfully!');
                                  }
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          });
    }

    return Card(
      margin: const EdgeInsets.all(6.0),
      elevation: 8,
      shadowColor: Colors.grey,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          //border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: SizedBox(
          width: double.infinity,
          //height: 360,
          child: Column(
            children: [
              //HEADER AND BODY
              FeedItemBody(
                feedPost: widget.feedPost,
                showAddComment: widget.showAddComment,
                enableProfileNaviagate: widget.enableProfileNaviagate,
              ),
              //HEADER AND BODY
              const SizedBox(height: 10),
              //TAGGED PRODUCT LISTING
              if (widget.feedPost.productList != null)
                if (widget.feedPost.productList!.isNotEmpty)
                  //FileCarousel(widget.feedPost.fileObjs),
                  ProductCarousel(widget.feedPost.productList),
              //TAGGED PRODUCT LISTING
              const SizedBox(height: 10),
              Divider(thickness: 0.2, color: Color(0xff707070)),
              //FOOTER
              Row(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirestoreServices.isUserLiked(feedLike),
                    // initialData: null,
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return IconButton(
                          onPressed: () {},
                          icon: _activeLikeState
                              ? SvgPicture.asset(
                                  'assets/icons/parent_wall_like.svg')
                              : SvgPicture.asset(
                                  'assets/icons/parent_wall_unlike.svg'),
                          /*Icon(
                            _activeLikeState
                                ? SwIcons.parent_wall_like__1_
                                : SwIcons.parent_wall_like,
                            color: AppTheme.primaryColor,
                          ),*/
                        );
                      } else {
                        if (snap.data!.size > 0)
                          _activeLikeState = true;
                        else
                          _activeLikeState = false;
                        return IconButton(
                          color: AppTheme.primaryColor,
                          icon: snap.data!.size > 0
                              ? SvgPicture.asset(
                                  'assets/icons/parent_wall_like.svg')
                              : SvgPicture.asset(
                                  'assets/icons/parent_wall_unlike.svg'),
                          /*Icon(snap.data!.size > 0
                                  ? SwIcons.parent_wall_like__1_
                                  : SwIcons.parent_wall_like),*/
                          onPressed: () async {
                            if (snap.data!.size > 0) {
                              //toggle
                              _activeLikeState = false;
                              /*setState(() {
                                if (!widget.showAddComment) {
                                  //if calling from details view
                                  if (widget.feedPost.likeCount != null) {
                                    widget.feedPost.likeCount =
                                        (widget.feedPost.likeCount! - 1);
                                  } else {
                                    widget.feedPost.likeCount == 0;
                                  }
                                }
                              });*/
                              FirestoreServices.undoLike(feedLike);
                            } else {
                              _activeLikeState = true;
                              /* setState(() {
                                if (!widget.showAddComment) {
                                  //if calling from details view
                                  if (widget.feedPost.likeCount != null) {
                                    widget.feedPost.likeCount =
                                        (widget.feedPost.likeCount! + 1);
                                  } else {
                                    widget.feedPost.likeCount == 1;
                                  }
                                }
                              });*/
                              FirestoreServices.doLike(feedLike);
                            }
                          },
                        );
                      }
                    },
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirestoreServices.likedCount(feedLike),
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return Text('Like',
                              style: TextStyle(fontWeight: FontWeight.w600));
                        } else {
                          if (snap.hasData) {
                            return Text(
                              snap.data!.size > 0
                                  ? snap.data!.size == 1
                                      ? '${snap.data!.size}'
                                      : '${snap.data!.size}'
                                  : 'Like',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            );
                          } else {
                            return Text('Like',
                                style: TextStyle(fontWeight: FontWeight.w600));
                          }
                        }
                      },
                    ),
                    /*Text(
                      widget.feedPost.likeCount! > 0
                          ? widget.feedPost.likeCount == 1
                              ? '${widget.feedPost.likeCount}'
                              : '${widget.feedPost.likeCount}'
                          : 'Like',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    )*/
                  ),
                  //Spacer(),
                  if (widget.enableProfileNaviagate &&
                      widget.feedPost.postedBy != "Vendor")
                    IconButton(
                      onPressed: () async {
                        selectedReportOption = 0;
                        await _reportAbuse();
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/reportabuse.svg',
                        width: 15,
                        height: 15,
                      ),
                    ),
                  Spacer(),
                  StreamBuilder<QuerySnapshot>(
                      stream: FirestoreServices.commentCount(feedLike),
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return Row(
                            children: [
                              Text(
                                'Comment',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              if (widget.showAddComment)
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                        FeedDetailsScreen.routeName,
                                        arguments: widget.feedPost);
                                  },
                                  icon: SvgPicture.asset(
                                      'assets/icons/no_comments.svg'),
                                  /*Icon(widget.feedPost.commentCount! > 0
                          ? SwIcons.parent_wall_comments__1_
                          : SwIcons.parent_wall_comments)*/
                                  // color: Colors.grey,
                                ),
                              if (!widget.showAddComment)
                                // if (widget.feedPost.commentCount! > 0)
                                IconButton(
                                  onPressed: null,
                                  icon: SvgPicture.asset(
                                      'assets/icons/no_comments.svg'),
                                  //color: Colors.grey,
                                ),
                            ],
                          );
                        } else {
                          if (snap.hasData) {
                            return Row(
                              children: [
                                Text(
                                  snap.data!.size > 0
                                      ? snap.data!.size == 1
                                          ? '${snap.data!.size}'
                                          : '${snap.data!.size}'
                                      : widget.showAddComment
                                          ? 'Comment'
                                          : '',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                if (widget.showAddComment)
                                  IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                          FeedDetailsScreen.routeName,
                                          arguments: widget.feedPost);
                                    },
                                    icon: snap.data!.size > 0
                                        ? SvgPicture.asset(
                                            'assets/icons/parent_wall_comments.svg')
                                        : SvgPicture.asset(
                                            'assets/icons/no_comments.svg'),
                                    /*Icon(widget.feedPost.commentCount! > 0
                          ? SwIcons.parent_wall_comments__1_
                          : SwIcons.parent_wall_comments)*/
                                    // color: Colors.grey,
                                  ),
                                if (!widget.showAddComment)
                                  if (snap.data!.size > 0)
                                    IconButton(
                                      onPressed: null,
                                      icon: SvgPicture.asset(
                                          'assets/icons/parent_wall_comments.svg'),
                                      //color: Colors.grey,
                                    ),
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                Text(
                                  'Comment',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                if (widget.showAddComment)
                                  IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                          FeedDetailsScreen.routeName,
                                          arguments: widget.feedPost);
                                    },
                                    icon: SvgPicture.asset(
                                        'assets/icons/no_comments.svg'),
                                    /*Icon(widget.feedPost.commentCount! > 0
                          ? SwIcons.parent_wall_comments__1_
                          : SwIcons.parent_wall_comments)*/
                                    // color: Colors.grey,
                                  ),
                                if (!widget.showAddComment)
                                  // if (widget.feedPost.commentCount! > 0)
                                  IconButton(
                                    onPressed: null,
                                    icon: SvgPicture.asset(
                                        'assets/icons/no_comments.svg'),
                                    //color: Colors.grey,
                                  ),
                              ],
                            );
                          }
                        }
                      }),
                  //TO -Delete
                  /*Text(
                    widget.feedPost.commentCount! > 0
                        ? widget.feedPost.commentCount == 1
                        ? '${widget.feedPost.commentCount}'
                        : '${widget.feedPost.commentCount}'
                        : widget.showAddComment
                        ? 'Comment'
                        : '',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (widget.showAddComment)
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                            FeedDetailsScreen.routeName,
                            arguments: widget.feedPost);
                      },
                      icon: widget.feedPost.commentCount! > 0
                          ? SvgPicture.asset(
                          'assets/icons/parent_wall_comments.svg')
                          : SvgPicture.asset('assets/icons/no_comments.svg'),
                      */ /*Icon(widget.feedPost.commentCount! > 0
                          ? SwIcons.parent_wall_comments__1_
                          : SwIcons.parent_wall_comments)*/ /*
                      // color: Colors.grey,
                    ),
                  if (!widget.showAddComment)
                    if (widget.feedPost.commentCount! > 0)
                      IconButton(
                        onPressed: null,
                        icon: SvgPicture.asset(
                            'assets/icons/parent_wall_comments.svg'),
                        //color: Colors.grey,
                      ),*/
                  //To-Delete
                ],
              ),
              //FOOTER
            ],
          ),
        ),
      ),
    );
  }
}
