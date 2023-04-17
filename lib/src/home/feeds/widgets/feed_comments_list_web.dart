import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../../adaptive/adaptive_theme.dart';
import '../../../../helpers/global_variables.dart';
import '../../../../util/app_theme.dart';

import '../../../../util/dialogs.dart';
import '/src/models/login_response.dart';
import '/src/providers/auth.dart';

import '/util/date_util.dart';
import '/util/ui_helpers.dart';

import '/src/models/firestore/feed_comment.dart';
import '/src/providers/firestore_services.dart';

class FeedCommentsListWeb extends StatefulWidget {
  final String feedId;
  final Function commentUpdateHandler;
  FeedCommentsListWeb(
    this.feedId,
    this.commentUpdateHandler,
  );
  @override
  _FeedCommentsListWebState createState() => _FeedCommentsListWebState();
}

class _FeedCommentsListWebState extends State<FeedCommentsListWeb> {
  _refreshView() {
    setState(() {});
    widget.commentUpdateHandler();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreServices.getComments(widget.feedId),
      builder: (context, commentsSnapshot) {
        if (commentsSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: AdaptiveCircularProgressIndicator());
        } else {
          if (commentsSnapshot.data != null) {
            final comments = commentsSnapshot.data!.docs;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    //convert the feed object to local Object
                    DocumentSnapshot comment = comments[index];
                    FeedComment feedComment = FeedComment.fromJson(
                      comment.data() as Map<String, dynamic>,
                      widget.feedId,
                    );
                    //convert the feed object to local Object
                    //return CommentCard(feedComment: feedComment);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CommentCardWeb(feedComment: feedComment),
                        //SizedBox(height: 10),
                        Divider(thickness: 1),
                      ],
                    );
                  },
                ),
                //COMMENTS
                AddComment(feedId: widget.feedId, refreshHandler: _refreshView),
                //COMMENTS
              ],
            );
          } else {
            // final comments = commentsSnapshot.data!.docs;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //COMMENTS
                AddComment(feedId: widget.feedId, refreshHandler: _refreshView),
                //COMMENTS
              ],
            );
          }
        }
      },
    );
  }
}

class AddComment extends StatefulWidget {
  final String feedId;
  final Function refreshHandler;

  AddComment({
    Key? key,
    required this.feedId,
    required this.refreshHandler,
  }) : super(key: key);

  @override
  _AddCommentState createState() => _AddCommentState();
}

class _AddCommentState extends State<AddComment> {
  final _commentFocusNode = FocusNode();
  final _commentController = TextEditingController();
  bool _isLoading = false;
  LoginResponse? _loginResponse;
  var _isInIt = true;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_commentListner);
  }

  _commentListner() {
    setState(() {});
  }

  @override
  void dispose() {
    _commentFocusNode.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
      _isInIt = false;
    }
    super.didChangeDependencies();
  }

  Future<void> _addComment() async {
    setState(() {
      _isLoading = true;
    });
    FeedComment feedComment = await FeedComment(
      feedId: widget.feedId,
      comments: _commentController.text,
      createdAt: DateTime.now(),
      userId: _loginResponse!.b2cParent!.parentID,
      userImage: _loginResponse!.b2cParent!.profileImage,
      userName: _loginResponse!.b2cParent!.name,
    );
    await FirestoreServices.addComment(feedComment);
    widget.refreshHandler();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              cursorHeight: 25,
              inputFormatters: [
                LengthLimitingTextInputFormatter(250),
              ],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              decoration: InputDecoration(
                hintText: 'Type a Message',
                hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w400),
                filled: true,
                fillColor: Colors.white70,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  borderSide: BorderSide(color: Colors.grey.shade500),
                ),
              ),
              textInputAction: TextInputAction.newline,
              focusNode: _commentFocusNode,
              controller: _commentController,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 5,
            ),
          ),
          const SizedBox(width: 10),
          Material(
            shape: const CircleBorder(),
            color: Colors.white,
            child: Ink(
              decoration: ShapeDecoration(
                color: _isLoading
                    ? Colors.white
                    : AdaptiveTheme.primaryColor(context),
                shape: const CircleBorder(),
                shadows: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(5.0, 5.0),
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: _isLoading
                  ? AdaptiveCircularProgressIndicator()
                  : IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
                      iconSize: 25,
                      // color: Colors.white,
                      onPressed:
                          _commentController.text.isEmpty ? null : _addComment),
            ),
          ),
        ],
      ),
    );
  }
}

class CommentCardWeb extends StatelessWidget {
  final FeedComment feedComment;
  const CommentCardWeb({Key? key, required this.feedComment}) : super(key: key);

  get selectedReportOption => null;

  @override
  Widget build(BuildContext context) {
    int selectedReportOption = 0;
    final AutoSizeGroup descGroup = AutoSizeGroup();
    LoginResponse _loginResponse =
        Provider.of<Auth>(context, listen: false).loginResponse;

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
                    child: SizedBox(
                      width: 600,
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Report Comment',
                              style: AppTheme.lightTheme.textTheme.bodyMedium!
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
                                          style: AppTheme
                                              .lightTheme.textTheme.bodyMedium!
                                              .copyWith(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w300),
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
                              'The reported user comments are reviewed by SchoolWizard support team to determine whether the comment violate the community guidelines. Comments will be removed, if finds its violating the guidelines.',
                              minFontSize: 13,
                              maxFontSize: 14,
                              style: AppTheme.lightTheme.textTheme.bodyMedium!
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
                                        .updateCommentReportedStatus(
                                            feedComment.feedId,
                                            selectedReportOption + 1,
                                            feedComment.userId,
                                            _loginResponse.b2cParent!.parentID);

                                    if (retValue == true) {
                                      await Dialogs().ackAlert(
                                          context,
                                          'Report User comments',
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
                  ),
                );
              },
            );
          });
    }

    return Card(
      color: Colors.transparent,
      elevation: 0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getAvatarImage(feedComment.userImage, 40, 40, BoxShape.circle,
              feedComment.userName),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: screenWidth(context) * 0.40,
                child: Text(
                  feedComment.userName!,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      //fontSize: 15,
                      color: Colors.black),
                ),
              ),
              Text(DateUtil.formattedDateExtended_1(feedComment.createdAt!),
                  style: const TextStyle(fontSize: 11, color: Colors.black)),
              const SizedBox(height: 10),
              SizedBox(
                width: screenWidth(context) * 0.40,
                child: Text(
                  feedComment.comments!,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
          Spacer(),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
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
        ],
      ),
    );
  }
}
