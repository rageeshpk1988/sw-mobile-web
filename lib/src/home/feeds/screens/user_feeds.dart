import 'package:flutter/material.dart';
import '../../../../helpers/route_arguments.dart';
import '../widgets/feeds_wall_paginated_list.dart';

import '../../../../adaptive/adaptive_custom_appbar.dart';

class UserFeedsScreen extends StatelessWidget {
  static String routeName = '/userfeeds';

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // int userId = ModalRoute.of(context)!.settings.arguments as int;
    UserFeedsArgs args =
        ModalRoute.of(context)!.settings.arguments as UserFeedsArgs;

    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      appBar: AdaptiveCustomAppBar(
        showShopifyHomeButton: false,
        showShopifyCartButton: false,
        showKycButton: false,
        showProfileButton: false,
        showHamburger: false,
        scaffoldKey: scaffoldKey,
        adResponse: null,
        loginResponse: null,
        kycStatus: null,
        updateHandler: () {},
        title: 'Feeds',
        showMascot: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              //FEED BODY
              FeedsWallPaginatedList(
                userId: args.userId,
                enableProfileNaviagate: false,
                followerFeeds: args.followerFeeds,
              ),
              //FEED BODY
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
