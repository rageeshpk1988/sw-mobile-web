import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../src/vendor_profile/widgets/vendor_feeds_list_item.dart';
import '../../../../adaptive/adaptive_circular_progressInd.dart';

import '/src/models/firestore/feedpost.dart';
import '/src/providers/firestore_services.dart';

class VendorFeedsList extends StatefulWidget {
  final int? vendorId;

  VendorFeedsList({this.vendorId});
  @override
  _VendorFeedsListState createState() => _VendorFeedsListState();
}

class _VendorFeedsListState extends State<VendorFeedsList> {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreServices.getUserFeeds(widget.vendorId!),
      builder: (context, feedsSnapshot) {
        if (feedsSnapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: deviceSize.height * 0.70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(child: AdaptiveCircularProgressIndicator()),
              ],
            ),
          );
        } else {
          if (feedsSnapshot.hasData) {
            final feeds = feedsSnapshot.data!.docs;
            if (feeds.isNotEmpty) {
              return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: feeds.length,
                  itemBuilder: (context, index) {
                    //convert the feed object to local Object
                    DocumentSnapshot feed = feeds[index];
                    FeedPost feedPost = FeedPost.fromJson(
                      feed.data() as Map<String, dynamic>,
                      feed,
                    );
                    //convert the feed object to local Object
                    return VendorFeedsListItem(feedPost);
                  });
            } else {
              return const SizedBox();
            }
          } else {
            return const SizedBox();
          }
        }
      },
    );
  }
}
