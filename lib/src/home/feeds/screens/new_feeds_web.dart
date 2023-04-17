import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '/src/home/feeds/widgets/feeds_wall_paginated_list_web.dart';
import '/src/models/child.dart';
import '/src/profile/screens/add_child_web.dart';
import '/src/profile/widgets/new_feeds_header_section_web.dart';

import '/src/vendor_profile/screens/vendor_profile_web.dart';

import '../../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../../adaptive/adaptive_theme.dart';
import '../../../../helpers/connectivity_helper.dart';
import '../../../../helpers/route_arguments.dart';
import '../../../../util/app_theme.dart';
import '../../../../util/ui_helpers.dart';
import '../../../../widgets/web_banner.dart';
import '../../../../widgets/web_bottom_bar.dart';

import '../../../models/firestore/followingparents.dart';

import '../../../providers/firestore_services.dart';

import '/src/models/socialaccesstoken_response.dart';

import '/src/models/login_response.dart';
import '../../../../helpers/shared_pref_data.dart';

import '../../../providers/auth.dart';

import '/src/models/ad_response.dart';

class NewFeedScreenWeb extends StatefulWidget {
  static String routeName = '/web-newfeed-home';
  NewFeedScreenWeb({Key? key}) : super(key: key);

  @override
  _NewFeedScreenWebState createState() => _NewFeedScreenWebState();
}

class _NewFeedScreenWebState extends State<NewFeedScreenWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var _isInIt = true;
  //String? _mobileNumber;
  ADResponse? _adResponse;
  LoginResponse? _loginResponse;
  SocialAdResponse? _socialAccessTokenResponse;
  int? _approvestatus;
  var resultsLoaded;

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
      // _mobileNumber =
      //     Provider.of<Auth>(context, listen: false).loginResponse.mobileNumber;
      _adResponse = Provider.of<Auth>(context, listen: false).adResponse;
      _socialAccessTokenResponse =
          Provider.of<Auth>(context, listen: false).socialAccessTokenResponse;
      _approvestatus = Provider.of<Auth>(context, listen: false).kycResponse;

      //Get the KYC status
      // Provider.of<User>(context, listen: false)
      //     .getapproveStatus(_loginResponse!.b2cParent!.parentID)
      //     .then((value) {
      //   setState(() {
      //     _approvestatus = value;
      //   });
      // });

      // resultsLoaded = getapproveStatusKyc(
      //     _loginResponse!.b2cParent!.parentID); // changes where made here
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

  void updateADData() async {
    setState(() async {
      _adResponse = await SharedPrefData.getUserADDataPref();
    });
  }

  void updateKycStatus() async {
    resultsLoaded = await Provider.of<Auth>(context, listen: false)
        .getApproveStatusKyc(_loginResponse!.b2cParent!.parentID);
    print("updating kycstatus");
    int? status = await SharedPrefData.getUserKycStatus();
    setState(() {
      _approvestatus = status;
    });
  }

  void updateSocialADData() async {
    setState(() async {
      _socialAccessTokenResponse =
          await SharedPrefData.getUserSocialADDataPref();
    });
  }

  // getapproveStatusKyc(int parentID) async {
  //   //changes where made here
  //   int? kycStatus;
  //   kycStatus = await Provider.of<User>(context, listen: false)
  //       .getapproveStatus(parentID);
  //   //print(kycStatus);
  //   // setState(() {
  //   _approvestatus = kycStatus;
  //   // });
  //   return kycStatus;
  // }
  @override
  Widget build(BuildContext context) {
    Widget _bodyWidget() {
      return FeedsWallPaginatedListWeb(enableProfileNaviagate: true);
    }

    Widget _vendorsView() {
      Widget _emptyVendors() {
        return SizedBox(
          child: Text(
            'No vendors data found...',
            style: TextStyle(fontSize: 14),
          ),
        );
      }

      LoginResponse _loginResponse =
          Provider.of<Auth>(context, listen: false).loginResponse;

      return SizedBox(
        width: screenWidth(context) * 0.20,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 5.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'My Vendors',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                //VENDORS DETAILS
                SingleChildScrollView(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirestoreServices.getFollowingVendors(
                        _loginResponse.b2cParent!.parentID),
                    builder: (context, vendorSnapshot) {
                      if (vendorSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Container(
                          //height: screenWidth(context) * 0.40,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                  child: AdaptiveCircularProgressIndicator()),
                            ],
                          ),
                        );
                      } else {
                        if (vendorSnapshot.hasData) {
                          final vendors = vendorSnapshot.data!.docs;
                          if (vendors.isNotEmpty) {
                            return GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(10.0),
                              itemCount: vendors.length + 5,
                              itemBuilder: (ctx, index) {
                                //convert the followings object to local Object
                                if (index > vendors.length - 1) {
                                  //TODO:: REPLICATE DATE TO BE REMOVED
                                  index = 0;
                                }
                                DocumentSnapshot followings = vendors[index];
                                FollowingParents followingVendors =
                                    FollowingParents.fromJson(followings.data()
                                        as Map<String, dynamic>);
                                //convert the followings object to local Object
                                return Container(
                                  //padding: EdgeInsets.all(10),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                            onTap: () async {
                                              if (await ConnectivityHelper
                                                      .hasInternet<
                                                              ProfileOthersArgs>(
                                                          context,
                                                          VendorProfileScreenWeb
                                                              .routeName,
                                                          ProfileOthersArgs(
                                                              null,
                                                              followingVendors,
                                                              null)) ==
                                                  true) {
                                                Navigator.of(context).pushNamed(
                                                    VendorProfileScreenWeb
                                                        .routeName,
                                                    arguments:
                                                        ProfileOthersArgs(
                                                      null,
                                                      followingVendors,
                                                      null,
                                                    ));
                                              }
                                            },
                                            child: getAvatarImage(
                                                followingVendors.userImage,
                                                30,
                                                30,
                                                BoxShape.rectangle,
                                                followingVendors.userName)),
                                        const SizedBox(height: 5),
                                        SizedBox(
                                          width: 40,
                                          child: Flexible(
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                '${followingVendors.userName}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayMedium!
                                                    .copyWith(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                maxLines: 1,
                                                //textAlign: TextAlign.start,
                                                overflow: TextOverflow.fade,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      childAspectRatio: 10 / 5,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 1,
                                      mainAxisExtent:
                                          screenHeight(context) * 0.090),
                            );
                          } else {
                            return _emptyVendors();
                          }
                        } else {
                          return _emptyVendors();
                        }
                      }
                    },
                  ),
                ),
                //VENDORS DETAILS
              ],
            ),
          ),
        ),
      );
    }

    Widget _kidsView() {
      TextStyle _headerStyle(double fontSize, FontWeight fontWeight) {
        return AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontSize: fontSize, fontWeight: fontWeight);
      }

      return SizedBox(
        width: screenWidth(context) * 0.20,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 5.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Kids',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                //CHILD DETAILS
                GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  // padding: const EdgeInsets.all(10.0),
                  itemCount:
                      _loginResponse!.b2cParent!.childDetails!.length + 5,
                  itemBuilder: (ctx, index) {
                    if (index >
                        _loginResponse!.b2cParent!.childDetails!.length - 1) {
                      //TODO:: REPLICATE DATE TO BE REMOVED
                      index = 0;
                    }
                    Child child =
                        _loginResponse!.b2cParent!.childDetails![index];
                    return SizedBox(
                      width: screenWidth(context) * 0.05,
                      // height: screenHeight(context) * 0.1,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              getAvatarImage(child.imageUrl, 30, 30,
                                  BoxShape.circle, child.name),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    child.name,
                                    style: _headerStyle(14, FontWeight.w500),
                                  ),
                                  Text(
                                    '${child.schoolName!}',
                                    style: _headerStyle(11, FontWeight.w300),
                                  ),
                                  Text(
                                    '${child.className} ${child.division}',
                                    style: _headerStyle(11, FontWeight.w300)
                                        .copyWith(
                                            color: AdaptiveTheme.secondaryColor(
                                                context)),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Divider(),
                        ],
                      ),
                    );
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 10 / 5,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 1,
                      mainAxisExtent: screenHeight(context) * 0.090),
                ),
                //CHILD DETAILS
                Padding(
                  padding: const EdgeInsets.only(left: 7.0, right: 7.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                          AddChildScreenWeb.routeName,
                          arguments: () {});
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Add Child',
                          style: AppTheme.lightTheme.textTheme.titleMedium!
                              .copyWith(
                                  fontSize: 14,
                                  color: HexColor.fromHex("#ED247C"),
                                  fontWeight: FontWeight.w600),
                        ),

                        ///  const SizedBox(width: 5),
                        Icon(
                          Icons.add,
                          size: 20,
                          color: HexColor.fromHex("#ED247C"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget _followersView() {
      // TextStyle _headerStyle(double fontSize, FontWeight fontWeight) {
      //   return AppTheme.lightTheme.textTheme.bodySmall!
      //       .copyWith(fontSize: fontSize, fontWeight: fontWeight);
      // }

      return SizedBox(
        width: screenWidth(context) * 0.20,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 5.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Followers',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FollowersListOnWebParentsWall(),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      endDrawer: WebBannerDrawer(),
      backgroundColor: Colors.white,
      key: scaffoldKey,
      body: SingleChildScrollView(
        //physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            WebBanner(
              showMenu: true,
              showHomeButton: true,
              showProfileButton: true,
              scaffoldKey: scaffoldKey,
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: (screenWidth(context) > 800 ? 70.0 : 20.0), top: 40),
              child: Row(
                children: [
                  Text(
                    "Parents' Wall",
                    style: TextStyle(
                        letterSpacing: 0.0,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: screenWidth(context) *
                  (screenWidth(context) > 800 ? 0.90 : 0.98),
              child: Padding(
                padding: EdgeInsets.only(
                    left: (screenWidth(context) > 800 ? 1.0 : 10.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: screenWidth(context) *
                              (screenWidth(context) > 800 ? 0.60 : 0.90),
                          child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              elevation: 5.0,
                              child:
                                  NewFeedsHeaderSectionWeb(() {}, true, true)),
                        ),
                        Container(
                          width: screenWidth(context) *
                              (screenWidth(context) > 800 ? 0.60 : 0.90),
                          constraints: BoxConstraints(
                            maxHeight: double.infinity,
                          ),
                          child: SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: _bodyWidget(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    if (screenWidth(context) > 800)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _kidsView(),
                          _vendorsView(),
                          _followersView(),
                        ],
                      )
                  ],
                ),
              ),
            ),
            WebBottomBar(),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class FollowersListOnWebParentsWall extends StatefulWidget {
  const FollowersListOnWebParentsWall({Key? key}) : super(key: key);

  @override
  _FollowersListOnWebParentsWallState createState() =>
      _FollowersListOnWebParentsWallState();
}

class _FollowersListOnWebParentsWallState
    extends State<FollowersListOnWebParentsWall> {
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
      for (var followersSnapshot in _allResults) {
        var title = FollowingParents.fromSnapshot(followersSnapshot)
            .userName!
            .trim()
            .toLowerCase()
            .replaceAll(' ', '');

        if (title.contains(
            _searchController.text.trim().toLowerCase().replaceAll(' ', ''))) {
          showResults.add(followersSnapshot);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }
    setState(() {
      _resultsList = showResults;
    });
  }

  getFollowersParentsSearch(int ParentID) async {
    var data = await FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc("$ParentID")
        .collection("followers")
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
          getFollowersParentsSearch(_loginResponse!.b2cParent!.parentID);
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
    Widget _followerItem(FollowingParents followersParents) {
      return SizedBox(
        //width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            getAvatarImage(followersParents.userImage, 30, 30, BoxShape.circle,
                followersParents.userName),
            SizedBox(
              width: 40,
              child: Flexible(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${followersParents.userName}',
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w700),
                    maxLines: 1,
                    //textAlign: TextAlign.start,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _resultsList.isEmpty
              ? Column(
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
                )
              : SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
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
                          itemCount: _resultsList.length + 5,
                          itemBuilder: (ctx, index) {
                            if (index > _resultsList.length - 1) {
                              //TODO:: REPLICATE DATE TO BE REMOVED
                              index = 0;
                            }
                            //convert the followings object to local Object
                            DocumentSnapshot followers = _resultsList[index];
                            FollowingParents followersParents =
                                FollowingParents.fromJson(
                                    followers.data() as Map<String, dynamic>);
                            //convert the followings object to local Object

                            return _followerItem(followersParents);
                          },
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 10 / 5,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 1,
                                  mainAxisExtent:
                                      screenHeight(context) * 0.090),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}


//
