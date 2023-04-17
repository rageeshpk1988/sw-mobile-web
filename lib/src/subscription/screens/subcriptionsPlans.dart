import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../../adaptive/adaptive_custom_appbar.dart';

import '../widgets/subscription_package_item.dart';
import '/src/models/subscription_package.dart';
import '/src/providers/auth.dart';
import '/src/providers/subscriptions.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  static String routeName = '/subscription-plans';

  Future<List<SubscriptionPackage>> _refreshSubscriptionPlans(
      BuildContext context) async {
    // var loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
    int parentId = Provider.of<Auth>(context, listen: false)
        .loginResponse
        .b2cParent!
        .parentID;
    return await Provider.of<Subscriptions>(context, listen: false)
        .fetchSubscriptionPackages(parentId);
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
        loginResponse: null,
        updateHandler: null,
        title: 'Subscription Plans',
        showMascot: true,
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            FutureBuilder(
              future: _refreshSubscriptionPlans(context),
              builder: (BuildContext context, AsyncSnapshot snapshot) =>
                  snapshot.connectionState == ConnectionState.waiting
                      ? Center(child: AdaptiveCircularProgressIndicator())
                      : snapshot.data != null
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data.length,
                              itemBuilder: (ctx, i) =>
                                  SubscriptionPackageItem(snapshot.data[i]),
                            )
                          : Center(
                              child: const Text(
                                  'Subscription plans are not available!'),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
