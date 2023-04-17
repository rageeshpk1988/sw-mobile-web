import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '/src/profile/widgets/profile_header_section_web.dart';

import '../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../src/profile/widgets/following_view_item.dart';

import '../../../adaptive/adaptive_theme.dart';
import '../../../util/app_theme.dart';

import '../../../util/sw_icons_icons.dart';
import '../../../widgets/web_banner.dart';
import '../../../widgets/web_bottom_bar.dart';
import '/src/models/firestore/followingparents.dart';
import '/src/models/login_response.dart';
import '/src/providers/auth.dart';
import '/util/ui_helpers.dart';

class FollowingScreenWeb extends StatefulWidget {
  static String routeName = '/web-following';
  const FollowingScreenWeb({Key? key}) : super(key: key);

  @override
  _FollowingScreenWebState createState() => _FollowingScreenWebState();
}

class _FollowingScreenWebState extends State<FollowingScreenWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _searchController = TextEditingController();
  LoginResponse? _loginResponse;
  Future? resultsLoaded;
  List _allResults = [];
  List _resultsList = [];
  var _isInIt = true;
  var _isLoading = false;

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

  void refreshPage() {
    setState(() {
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _bodyWidget() {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                //HEADER SECTION
                SizedBox(
                    width: 400,
                    child: ProfileHeaderSectionWeb(refreshPage, false, false)),
                //HEADER SECTION
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Following(${_resultsList.length})',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                  Spacer(),
                  //SEARCH BOX
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 400,
                        child: Material(
                          elevation: 10,
                          shadowColor: Colors.grey.shade100,
                          child: TextField(
                            style: AppTheme.lightTheme.textTheme.bodyMedium!
                                .copyWith(
                                    fontSize: 16, fontWeight: FontWeight.w300),
                            controller: _searchController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(width: 2)),
                                focusColor: AdaptiveTheme.primaryColor(context),
                                /*focusedBorder:
                                          AdaptiveTheme.underlineInputBorder(context),*/
                                suffixIcon: new SizedBox(
                                  height: 30,
                                  child: Icon(
                                    SwIcons.parent_wall_search,
                                    color: AdaptiveTheme.primaryColor(context),
                                  ),
                                ),
                                hintText: '  Search'),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(15),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  //SEARCH BOX
                ],
              ),
            ),
            verticalSpaceMedium,
            _resultsList.isEmpty
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            'No Data Found',
                            style: AppTheme.lightTheme.textTheme.bodyMedium!
                                .copyWith(
                                    fontSize: 16, fontWeight: FontWeight.w300),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(10.0),
                            itemCount: _resultsList.length,
                            itemBuilder: (ctx, index) {
                              //convert the followings object to local Object
                              DocumentSnapshot followings = _resultsList[index];
                              FollowingParents followingParents =
                                  FollowingParents.fromJson(followings.data()
                                      as Map<String, dynamic>);
                              //convert the followings object to local Object
                              return Column(
                                children: [
                                  FollowingViewItem(
                                    followingParents: followingParents,
                                    isWeb: true,
                                  ),
                                ],
                              );
                            },
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1 / 1,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20,
                                    mainAxisExtent: 100),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      endDrawer: WebBannerDrawer(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            WebBanner(
              showMenu: true,
              showHomeButton: true,
              showProfileButton: true,
              scaffoldKey: scaffoldKey,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50.0, top: 40),
              child: Row(
                children: [
                  Text(
                    'Following',
                    style: TextStyle(
                        letterSpacing: 0.0,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            Container(
              width: screenWidth(context) * 0.90,
              height: screenHeight(context) * 0.98,
              child: _isLoading == false
                  ? _bodyWidget()
                  : Center(child: AdaptiveCircularProgressIndicator()),
            ),
            WebBottomBar(),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
//