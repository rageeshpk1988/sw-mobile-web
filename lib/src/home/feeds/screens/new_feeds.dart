import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../../adaptive/adaptive_custom_appbar.dart';
import '../widgets/feeds_wall_paginated_list.dart';
import '/src/models/socialaccesstoken_response.dart';

import '/src/models/login_response.dart';
import '../../../../helpers/shared_pref_data.dart';

import '../../../providers/auth.dart';

import '/src/models/ad_response.dart';

class NewFeedScreen extends StatefulWidget {
  static String routeName = '/newfeed-home';
  NewFeedScreen({Key? key}) : super(key: key);

  @override
  _NewFeedScreenState createState() => _NewFeedScreenState();
}

class _NewFeedScreenState extends State<NewFeedScreen> {
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
    //print("updating kycstatus");
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
    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      appBar: AdaptiveCustomAppBar(
        title: "Parents' Wall",
        showShopifyHomeButton: false,
        showShopifyCartButton: false,
        showKycButton: false,
        showProfileButton: false,
        showHamburger: true,
        scaffoldKey: scaffoldKey,
        adResponse: _adResponse,
        loginResponse: _loginResponse,
        kycStatus: _approvestatus,
        updateHandler: updateADData,
        socialUpdateHandler: updateSocialADData,
        socialAccessTokenResponse: _socialAccessTokenResponse,
        showMascot: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //FEED BODY
              FeedsWallPaginatedList(enableProfileNaviagate: true),
              //FEED BODY
              const SizedBox(height: 10),
            ],
          ),
        ),
        // ),
      ),
    );
  }
}
