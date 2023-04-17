import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../src/profile/widgets/following_view_item.dart';

import '../../../adaptive/adaptive_custom_appbar.dart';
import '../../../adaptive/adaptive_theme.dart';
import '../../../util/app_theme.dart';
import '../../../util/app_theme_cupertino.dart';
import '../../../util/sw_icons_icons.dart';
import '/src/models/firestore/followingparents.dart';
import '/src/models/login_response.dart';
import '/src/providers/auth.dart';
import '/util/ui_helpers.dart';

class FollowingScreen extends StatefulWidget {
  static String routeName = '/following';
  const FollowingScreen({Key? key}) : super(key: key);

  @override
  _FollowingScreenState createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  TextEditingController _searchController = TextEditingController();
  LoginResponse? _loginResponse;
  Future? resultsLoaded;
  List _allResults = [];
  List _resultsList = [];
  var _isInIt = true;
  //var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    searchResultsList();
  }

  searchResultsList() {
    var showResults = [];

    if (_searchController.text != "") {
      for (var followingSnapshot in _allResults) {
        var title = FollowingParents.fromSnapshot(followingSnapshot)
            .userName!
            .trim()
            .toLowerCase()
            .replaceAll(' ', '');
        // print(_searchController.text.trim().toLowerCase().replaceAll(' ', ''));
        if (title.contains(
            _searchController.text.trim().toLowerCase().replaceAll(' ', ''))) {
          showResults.add(followingSnapshot);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }
    setState(() {
      _resultsList = showResults;
    });
  }

  getFollowingParentsSearch(int ParentID) async {
    //print(ParentID);
    var data = await FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc("$ParentID")
        . // "40964" - use this to get data
        collection("following")
        .where('userType', isEqualTo: "parent")
        .get();
    setState(() {
      _allResults = data.docs;
    });
    searchResultsList();
    return "complete";
  }

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
      resultsLoaded =
          getFollowingParentsSearch(_loginResponse!.b2cParent!.parentID);
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
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
        updateHandler: null,
        loginResponse: null,
        title: 'Following',
        showMascot: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  style: Platform.isIOS
                      ? AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
                          .copyWith(fontSize: 16, fontWeight: FontWeight.w300)
                      : AppTheme.lightTheme.textTheme.bodyMedium!
                          .copyWith(fontSize: 16, fontWeight: FontWeight.w300),
                  controller: _searchController,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(top: 10.0),
                      border: InputBorder.none,
                      focusColor: AdaptiveTheme.primaryColor(context),
                      /*focusedBorder:
                          AdaptiveTheme.underlineInputBorder(context),*/
                      icon: new Padding(
                        padding: const EdgeInsets.only(
                            top: 15, left: 0, right: 0, bottom: 0),
                        child: new SizedBox(
                          height: 30,
                          child: Icon(
                            SwIcons.parent_wall_search,
                            color: AdaptiveTheme.primaryColor(context),
                          ),
                        ),
                      ),
                      hintText: 'Search'),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(15),
                  ],
                ),
                verticalSpaceMedium,
                _resultsList.isEmpty
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                'No Data Found',
                                style: Platform.isIOS
                                    ? AppThemeCupertino
                                        .lightTheme.textTheme.navTitleTextStyle
                                        .copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w300)
                                    : AppTheme.lightTheme.textTheme.bodyMedium!
                                        .copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w300),
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _resultsList.length,
                            itemBuilder: (context, index) {
                              //convert the followings object to local Object
                              DocumentSnapshot followings = _resultsList[index];
                              FollowingParents followingParents =
                                  FollowingParents.fromJson(followings.data()
                                      as Map<String, dynamic>);
                              //convert the followings object to local Object
                              return Column(
                                children: [
                                  FollowingViewItem(
                                      followingParents: followingParents),
                                  const SizedBox(height: 10),
                                ],
                              );
                            }),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
//