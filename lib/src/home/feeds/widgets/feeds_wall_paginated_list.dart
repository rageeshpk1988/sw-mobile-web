import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../../adaptive/adaptive_theme.dart';
import '../../../../helpers/connectivity_helper.dart';

import '../../../providers/auth.dart';
import '/src/home/feeds/screens/new_feeds.dart';
import '/src/providers/firestore_services.dart';
import '/widgets/rounded_button.dart';

import '/src/home/feeds/widgets/feed_view_item.dart';
import '/src/home/new_post/new_post.dart';
import '/src/models/firestore/feedpost.dart';

class FeedsWallPaginatedList extends StatefulWidget {
  final int? userId;
  final bool enableProfileNaviagate;
  final bool followerFeeds;
  const FeedsWallPaginatedList({
    Key? key,
    this.userId,
    required this.enableProfileNaviagate,
    this.followerFeeds = false,
  }) : super(key: key);

  @override
  _FeedsWallPaginatedListState createState() => _FeedsWallPaginatedListState();
}

class _FeedsWallPaginatedListState extends State<FeedsWallPaginatedList> {
  ScrollController _scrollController = ScrollController();
  final StreamController<List<DocumentSnapshot>> _feedsController =
      StreamController<List<DocumentSnapshot>>.broadcast();
  List<List<DocumentSnapshot>> _allPagedResults = [<DocumentSnapshot>[]];
  static const int feedLimit = 20;
  DocumentSnapshot? _lastDocument;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              (_scrollController.position.maxScrollExtent) &&
          !_scrollController.position.outOfRange) {
        _getFeeds();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _feedsController.close();
    super.dispose();
  }

  Stream<List<DocumentSnapshot>> listenToFeedsRealTime() {
    _getFeeds();
    return _feedsController.stream;
    // return _feedsController.stream.asBroadcastStream();
  }

  Stream<List<DocumentSnapshot>> refreshData() {
    _lastDocument = null;
    _allPagedResults = [];
    setState(() {
      _getFeeds();
    });
    return _feedsController.stream;
  }

  void _getFeeds() {
    var pageFeedQuery = null;
    if (widget.userId == null) {
      pageFeedQuery = FirestoreServices.getFeedsWall2(feedLimit);
    } else {
      pageFeedQuery =
          FirestoreServices.getUserFeeds2(feedLimit, widget.userId!);
    }
    if (_lastDocument != null) {
      pageFeedQuery = pageFeedQuery.startAfterDocument(_lastDocument!);
    }
    if (!_hasMoreData) return;
    var currentRequestIndex = _allPagedResults.length;

    pageFeedQuery.snapshots().listen(
      (snapshot) {
        if (snapshot.docs.isNotEmpty) {
          var generalFeeds = snapshot.docs.toList();
          var pageExists = currentRequestIndex < _allPagedResults.length;
          if (pageExists) {
            _allPagedResults[currentRequestIndex] = generalFeeds;
          } else {
            _allPagedResults.add(generalFeeds);
          }
          var allFeeds = _allPagedResults.fold<List<DocumentSnapshot>>(
              <DocumentSnapshot>[],
              (initialValue, pageItems) => initialValue..addAll(pageItems));

          //Adding to the stream
          // _feedsController.add(allFeeds);
          _feedsController.sink.add(allFeeds);

          if (currentRequestIndex == _allPagedResults.length - 1) {
            _lastDocument = snapshot.docs.last;
          }
          _hasMoreData = generalFeeds.length == feedLimit;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    int loggedInParent = Provider.of<Auth>(context, listen: false)
        .loginResponse
        .b2cParent!
        .parentID;

    Widget _buildErrorViewWidget() {
      return Container(
        width: deviceSize.width,
        height: deviceSize.height * 0.90,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/b2c_splash_logo3.png',
              height: 130,
            ),
            const SizedBox(height: 10),
            Text('Feed Fetch Error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 25)),
            const SizedBox(height: 10),
            Text(
              'Unable to fetch the feed data. Try again...',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 65,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: RoundButton(
                    title: 'Home',
                    onPressed: () {
                      Navigator.of(context).pushNamed(NewFeedScreen.routeName);
                    },
                    color: AdaptiveTheme.primaryColor(context)),
              ),
            ),
          ],
        ),
      );
    }

    Widget _headerBar() {
      //int? kycstatus = Provider.of<Auth>(context,listen: true).kycResponse;
      return //HEADER ICONS
          Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () async {
                  //TODO:: THIS SHOULD BE ENABLED LATER
                  // if (_approvestatus != 1) {
                  //   Dialogs().ackAlert(context, 'New Post',
                  //       'You KYC is not approved yet...');
                  // } else {
                  //   Navigator.of(context)
                  //       .pushNamed(NewPostScreen.routeName);
                  // }

                  if (await ConnectivityHelper.hasInternet(
                          context, NewPostScreen.routeName, null) ==
                      true) {
                    Navigator.of(context).pushNamed(NewPostScreen.routeName);
                  }
                },
                icon: Image.asset(
                  'assets/icons/parent_wall_creat.png',
                ),
              ),
              //Text('New Post')
            ],
          ),
          // ignore: todo
          // TODO:: SEARCH IS DESIABLED IN THE FIRST VERSION
          // Spacer(),
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     IconButton(
          //       onPressed: () async {
          //         if (await ConnectivityHelper.hasInternet(
          //                 context, FeedSearchScreen.routeName, null) ==
          //             true) {
          //           Navigator.of(context).pushNamed(FeedSearchScreen.routeName);
          //         }
          //       },
          //       icon: Icon(SwIcons.parent_wall_search),
          //     ),
          //     //Text('Search')
          //   ],
          // ),
        ],
      );

      //HEADER ICONS
    }

    return Column(
      children: [
        _headerBar(),
        const SizedBox(height: 10),
        Container(
          child: StreamBuilder<List<DocumentSnapshot>>(
            stream: listenToFeedsRealTime(),
            builder: (ctx, feedSnapshot) {
              if (feedSnapshot.hasError) {
                return _buildErrorViewWidget();
              }
              if (feedSnapshot.connectionState == ConnectionState.waiting ||
                  feedSnapshot.connectionState == ConnectionState.none) {
                // if (feedSnapshot.hasData) {
                return Center(child: AdaptiveCircularProgressIndicator());
                //} else {
                // return SizedBox();
                // if (_lastDocument == null && widget.userId != null) {
                //   //return SizedBox();
                //   if (_feedsController.stream.isBroadcast == true) {
                //     return _buildNewPostWidget();
                //   } else {
                //     return SizedBox();
                //   }
                //   // _buildNewPostWidget();
                // } else {
                //   return SizedBox();
                // }
                //}
              } else {
                if (feedSnapshot.hasData) {
                  final feedDocs = feedSnapshot.data!;
                  if (feedDocs.isNotEmpty) {
                    return Container(
                      height: 700,
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await Future<void>.delayed(Duration(seconds: 2));
                          refreshData();
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          shrinkWrap: true,
                          itemCount: feedDocs.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot feed = feedDocs[index];
                            FeedPost feedPost = FeedPost.fromJson(
                                feed.data() as Map<String, dynamic>, feed);

                            return StreamBuilder<QuerySnapshot>(
                              stream: FirestoreServices.isUserBlocked(
                                  loggedInParent, feedPost.postedUserID!),
                              builder: (ctx, snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox();
                                } else {
                                  return Column(
                                    children: [
                                      //Text(feedDocs[index].id),
                                      // if (index == 0 && widget.userId == null)
                                      //   _headerBar(),
                                      // if (index == 0 && widget.userId == null)
                                      //   SizedBox(height: 10),
                                      if (snap.data!.size == 0)
                                        FeedViewItem(
                                          feedPost,
                                          widget.enableProfileNaviagate,
                                        ),
                                      const SizedBox(height: 10),
                                      if (index == feedDocs.length - 1)
                                        const SizedBox(height: 100),
                                    ],
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox();
                    // _buildNewPostWidget();
                  }
                } else {
                  return const SizedBox();
                  // _buildNewPostWidget();
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
