import 'package:flutter/material.dart';
import '/src/home/feeds/widgets/feed_item_card_web.dart';

import '/src/models/firestore/feedpost.dart';

class FeedViewItemWeb extends StatelessWidget {
  final FeedPost feedPost;
  final bool enableProfileNaviagate;
  FeedViewItemWeb(this.feedPost, this.enableProfileNaviagate);

  @override
  Widget build(BuildContext context) {
    return FeedItemCardWeb(
      feedPost: feedPost,
      showAddComment: true,
      enableProfileNaviagate: enableProfileNaviagate,
    );
  }
}
