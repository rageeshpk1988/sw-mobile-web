import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:algolia/algolia.dart';
import '../../../../adaptive/adaptive_custom_appbar.dart';
import '../../../../adaptive/adaptive_theme.dart';
import '../../../../src/models/firestore/feedpost.dart';
import '../../../../util/app_theme.dart';
import '../../../../util/app_theme_cupertino.dart';

class FeedSearchScreen extends StatefulWidget {
  static String routeName = '/feed-search';
  const FeedSearchScreen({Key? key}) : super(key: key);

  @override
  _FeedSearchScreenState createState() => _FeedSearchScreenState();
}

class _FeedSearchScreenState extends State<FeedSearchScreen> {
  bool isSwitched = false;
  final _searchController = TextEditingController();
  String _searchString = '';
  List<FeedPost> feedPosts = [];
  List<AlgoliaObjectSnapshot> _searchResults = [];
  bool _searching = false;
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //algolia search
  _search() async {
    setState(() {
      _searching = true;
    });
    Algolia algolia = Algolia.init(applicationId: '', apiKey: '');
    AlgoliaQuery query =
        algolia.instance.index('Posts'); //index name to be changed
    query = query.query(_searchString);
    _searchResults = (await query.getObjects()).hits;
    setState(() {
      _searching = false;
    });
  }
  //MeiliSearch search commented
  // Future<void> _searchedFeeds(String searchString) async {
  //   var client = MeiliSearchClient('http://127.0.0.1:7700', 'masterKey');

  //   // An index is where the documents are stored.
  //   var index = client.index('collectionNamehere');

  //   var result = await index.search(searchString);
  //   //print(result.hits);
  //   if (result.hits != null) {
  //     for (Map<String, dynamic> dt in result.hits!) {
  //       FeedPost post = FeedPost.fromJson(dt, null);
  //       feedPosts.add(post);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    TextStyle? _inputStyle = kIsWeb || Platform.isAndroid
        ? AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontWeight: FontWeight.w400)
        : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
            .copyWith(fontWeight: FontWeight.w400);

    void _setSearchString() {
      setState(() {
        _searchString = _searchController.text;
        _search();
        //_searchedFeeds(_searchString);
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
        title: 'Feeds Search',
        showMascot: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  style: _inputStyle,
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    focusColor: AdaptiveTheme.primaryColor(context),
                    focusedBorder: AdaptiveTheme.underlineInputBorder(context),
                    suffixIcon: IconButton(
                      onPressed: _setSearchString,
                      icon: Icon(
                        Icons.search,
                        color: AdaptiveTheme.primaryColor(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _searching == true
                    ? Center(
                        child: const Text('Searching, please wait...'),
                      )
                    : _searchResults.length == 0
                        ? Center(
                            child: const Text('No results found.'),
                          )
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (BuildContext ctx, int index) {
                              AlgoliaObjectSnapshot snapshot =
                                  _searchResults[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text((index + 1).toString()),
                                ),
                                title: Text(snapshot.data['title']),
                                subtitle: Text(snapshot.data['postedBy']),
                              );
                            })
                // if (feedPosts.isNotEmpty)
                //   SearchedWallList(
                //       feedPosts: feedPosts, enableProfileNaviagate: false)
                // FeedsWallList(
                //     searchString: _searchString,
                //     enableProfileNaviagate: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
