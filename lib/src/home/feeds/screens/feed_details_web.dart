import 'package:flutter/material.dart';
import '/src/home/feeds/widgets/feed_comments_list_web.dart';
import '/src/home/feeds/widgets/feed_item_card_web.dart';

import '/src/models/firestore/feedpost.dart';

class FeedDetailsWeb extends StatefulWidget {
  final FeedPost feedPost;
  const FeedDetailsWeb({required this.feedPost, Key? key}) : super(key: key);

  @override
  _FeedDetailsWebState createState() => _FeedDetailsWebState();
}

class _FeedDetailsWebState extends State<FeedDetailsWeb> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    FeedPost feedPost = widget.feedPost;

    _commentUpdate() {
      setState(() {
        feedPost.commentCount = (feedPost.commentCount! + 1);
      });
    }

    return SafeArea(
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Feed',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w700),
              ),
              FeedItemCardWeb(
                feedPost: feedPost,
                showAddComment: false,
                enableProfileNaviagate: false,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 5.0, bottom: 10.0),
                child: Row(
                  children: [
                    Text('Comments',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
              ),
              FeedCommentsListWeb(feedPost.documentId!, _commentUpdate),
            ],
          ),
        ),
      ),
    );
  }
}
