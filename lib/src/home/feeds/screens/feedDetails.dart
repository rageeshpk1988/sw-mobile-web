import 'package:flutter/material.dart';
import '../../../../adaptive/adaptive_custom_appbar.dart';
import '/src/home/feeds/widgets/feed_item_card.dart';

import '/src/home/feeds/widgets/feed_comments_list.dart';

import '/src/models/firestore/feedpost.dart';

class FeedDetailsScreen extends StatefulWidget {
  static String routeName = '/feed-details';
  const FeedDetailsScreen({Key? key}) : super(key: key);

  @override
  _FeedDetailsScreenState createState() => _FeedDetailsScreenState();
}

class _FeedDetailsScreenState extends State<FeedDetailsScreen> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    FeedPost feedPost = ModalRoute.of(context)!.settings.arguments as FeedPost;

    _commentUpdate() {
      setState(() {
        feedPost.commentCount = (feedPost.commentCount! + 1);
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AdaptiveCustomAppBar(
        showShopifyHomeButton: false,
        showShopifyCartButton: false,
        showKycButton: false,
        showProfileButton: false,
        showHamburger: false,
        scaffoldKey: null,
        adResponse: null,
        loginResponse: null,
        updateHandler: null,
        title: 'Feed',
        showMascot: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FeedItemCard(
                  feedPost: feedPost,
                  showAddComment: false,
                  enableProfileNaviagate: false,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0, bottom: 10.0),
                  child: Text('Comments',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
                FeedCommentsList(feedPost.documentId!, _commentUpdate),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
