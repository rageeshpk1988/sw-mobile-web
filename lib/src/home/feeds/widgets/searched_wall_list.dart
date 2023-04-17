import 'package:flutter/material.dart';

import '/src/home/feeds/widgets/feed_view_item.dart';

import '/src/models/firestore/feedpost.dart';

class SearchedWallList extends StatelessWidget {
  final List<FeedPost> feedPosts;
  final bool enableProfileNaviagate;

  SearchedWallList({
    required this.feedPosts,
    required this.enableProfileNaviagate,
  });

  @override
  Widget build(BuildContext context) {
    //  final deviceSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: feedPosts.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              FeedViewItem(
                feedPosts[index],
                enableProfileNaviagate,
              ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}
