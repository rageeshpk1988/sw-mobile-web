import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:provider/provider.dart';

import '/src/profile/widgets/profile_header_section_web.dart';
import '../../../widgets/web_banner.dart';
import '../../../widgets/web_bottom_bar.dart';

import '../../../src/models/firestore/followingparents.dart';

import '../../../adaptive/adaptive_circular_progressInd.dart';

import '../widgets/profile_hori_list_item_web.dart';
import '/src/providers/firestore_services.dart';

import '../../../src/providers/auth.dart';
import '../../../src/models/login_response.dart';
import '../../../src/profile/widgets/child_list_item.dart';

import '../../../util/ui_helpers.dart';

class ProfileScreenWeb extends StatefulWidget {
  const ProfileScreenWeb({Key? key}) : super(key: key);
  static String routeName = '/web-profile';

  @override
  _ProfileScreenWebState createState() => _ProfileScreenWebState();
}

class _ProfileScreenWebState extends State<ProfileScreenWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  LoginResponse? _loginResponse;
  var _isInIt = true;
  Future? vendorsLoaded;
  var _isLoading = false;
  @override
  void didChangeDependencies() {
    if (_isInIt) {
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
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
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeaderSectionWeb(refreshPage, true, true),
              verticalSpaceMedium,
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  children: [
                    Text(
                      'Kids(${_loginResponse!.b2cParent!.childDetails!.length})',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              //CHILD DETAILS
              GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                //padding: const EdgeInsets.all(10.0),
                itemCount: _loginResponse!.b2cParent!.childDetails!.length + 10,
                itemBuilder: (ctx, index) {
                  if (index >
                      _loginResponse!.b2cParent!.childDetails!.length - 1)
                    index = 0;
                  return Column(
                    children: [
                      ChildListItem(
                        _loginResponse!.b2cParent!.childDetails![index],
                        refreshPage,
                        true,
                        editButtonSizePercentage: screenWidth(context) > 800
                            ? 0.02
                            : screenWidth(context) > 400
                                ? 0.05
                                : 0.08,
                      ),
                    ],
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth(context) > 800
                        ? 3
                        : screenWidth(context) > 400
                            ? 2
                            : 1,
                    childAspectRatio: 1 / 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 2,
                    mainAxisExtent: 90),
              ),

              //CHILD DETAILS
              verticalSpaceMedium,
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  'My Vendors',
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ),
              verticalSpaceSmall,
              ProfileMyVendorsSection(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      endDrawer: WebBannerDrawer(),
      body: SizedBox(
        height: screenHeight(context),
        child: SingleChildScrollView(
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
                      "Parent's Profile",
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
      ),
    );
  }
}

class ProfileMyVendorsSection extends StatelessWidget {
  const ProfileMyVendorsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final deviceSize = MediaQuery.of(context).size;
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

    return Card(
      elevation: 0.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //height: screenWidth(context) * 0.40,
          SingleChildScrollView(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreServices.getFollowingVendors(
                  _loginResponse.b2cParent!.parentID),
              builder: (context, vendorSnapshot) {
                if (vendorSnapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    //height: screenWidth(context) * 0.40,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(child: AdaptiveCircularProgressIndicator()),
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
                        itemCount: vendors.length + 10,
                        itemBuilder: (ctx, index) {
                          //convert the followings object to local Object
                          if (index > vendors.length - 1) {
                            //TODO:: REPLICATE DATE TO BE REMOVED
                            index = 0;
                          }
                          DocumentSnapshot followings = vendors[index];
                          FollowingParents followingVendors =
                              FollowingParents.fromJson(
                                  followings.data() as Map<String, dynamic>);
                          //convert the followings object to local Object

                          return ProfileHorizontalListItemWeb(
                              followingParents: followingVendors);
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1 / 1,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            mainAxisExtent: 100),
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
        ],
      ),
    );
  }
}
