import 'package:flutter/material.dart';
import '/src/home/feeds/widgets/feed_item_card.dart';
import '/src/models/firestore/feedpost.dart';
import '/src/home/feeds/screens/feedDetails.dart';

class FeedViewItem extends StatelessWidget {
  final FeedPost feedPost;
  final bool enableProfileNaviagate;
  FeedViewItem(this.feedPost, this.enableProfileNaviagate);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(FeedDetailsScreen.routeName, arguments: feedPost);
      },
      child: FeedItemCard(
        feedPost: feedPost,
        showAddComment: true,
        enableProfileNaviagate: enableProfileNaviagate,
      ),
    );
  }
}
