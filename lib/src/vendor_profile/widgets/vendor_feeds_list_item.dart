import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../src/home/feeds/screens/feedDetails.dart';
import '../../../src/models/firestore/feedpost.dart';
import '../../../util/ui_helpers.dart';

import '../../../../adaptive/adaptive_theme.dart';

class VendorFeedsListItem extends StatelessWidget {
  final FeedPost feedPost;

  VendorFeedsListItem(this.feedPost);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 1.0,
      child: ListTile(
        //leading: Image.network(appImageUrl(feedPost.fileObjs!.first.url!)),
        leading: feedPost.fileObjs!.first.type == 'video'
            ? Container(
                width: 70,
                height: 100,
                child: Icon(
                  Icons.movie,
                  size: 60,
                  color: AdaptiveTheme.primaryColor(context),
                ),
              ) // getThumNailImage(feedPost.fileObjs!.first.url!))
            : SizedBox(
                width: 70,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: appImageUrl(feedPost.fileObjs!.first.url!),
                    imageBuilder: (context, imageProvider) => Container(
                      width: 70,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.scaleDown),
                      ),
                    ),
                    // placeholder: (context, url) =>
                    //     Center(child: AdaptiveCircularProgressIndicator()),
                    errorWidget: (context, url, error) => SizedBox(
                      width: 70,
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported_outlined,
                              size: 40,
                              color: AdaptiveTheme.primaryColor(context)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

        isThreeLine: true,
        title: Text(
          feedPost.title!,
          style: TextStyle(
              fontSize: textScale(context) <= 1.0 ? 16 : 14,
              fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              feedPost.description!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: textScale(context) <= 1.0 ? 14 : 12,
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                  FeedDetailsScreen.routeName,
                  arguments: feedPost,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.visibility_outlined,
                      color: AdaptiveTheme.primaryColor(context)),
                  const SizedBox(width: 5),
                  Text(
                    'View',
                    style: TextStyle(
                        fontSize: textScale(context) <= 1.0 ? 14 : 12,
                        color: AdaptiveTheme.primaryColor(context)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
