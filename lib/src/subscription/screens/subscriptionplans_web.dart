import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '/src/subscription/screens/payment_init_web.dart';

import '../../../../adaptive/adaptive_circular_progressInd.dart';

import '../../../util/ui_helpers.dart';
import '../../../widgets/web_banner.dart';
import '../../../widgets/web_bottom_bar.dart';

import '/src/models/subscription_package.dart';
import '/src/providers/auth.dart';
import '/src/providers/subscriptions.dart';

class SubscriptionPlansScreenWeb extends StatefulWidget {
  static String routeName = '/web-subscription-plans';

  @override
  State<SubscriptionPlansScreenWeb> createState() =>
      _SubscriptionPlansScreenWebState();
}

class _SubscriptionPlansScreenWebState
    extends State<SubscriptionPlansScreenWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  late SubscriptionPackage? selectedPackage = null;
  List<SubscriptionPackage> subscriptionPackages = [];
  bool _isInIt = true;
  var _isLoading = false;
  @override
  void didChangeDependencies() {
    if (_isInIt) {
      setState(() {
        _isLoading = true;
      });
      int parentId = Provider.of<Auth>(context, listen: false)
          .loginResponse
          .b2cParent!
          .parentID;
      Provider.of<Subscriptions>(context, listen: false)
          .fetchSubscriptionPackages(parentId)
          .then((value) {
        setState(() {
          subscriptionPackages = value;
          selectedPackage = subscriptionPackages[0];
          _isLoading = false;
        });
      });
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Widget _responsiveBody() {
      List<Widget> _items = [
        SizedBox(
          width: screenWidth(context) < 800
              ? screenWidth(context) * 0.95
              : screenWidth(context) * 0.45,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _isLoading
                    ? Center(child: AdaptiveCircularProgressIndicator())
                    : subscriptionPackages.length > 0
                        ? screenWidth(context) < 800
                            ? SizedBox(
                                height: screenWidth(context) < 400 ? 200 : 250,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    //physics: NeverScrollableScrollPhysics(),
                                    itemCount: subscriptionPackages.length,
                                    itemBuilder: (ctx, index) {
                                      return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedPackage =
                                                  subscriptionPackages[index];
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width:
                                                    screenWidth(context) < 400
                                                        ? screenWidth(context) *
                                                            0.70
                                                        : screenWidth(context) *
                                                            0.50,
                                                child:
                                                    SubscriptionPackageItemWeb(
                                                        subscriptionPackages[
                                                            index]),
                                              ),
                                              const SizedBox(width: 10),
                                            ],
                                          ));
                                    }),
                              )
                            : GridView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(10.0),
                                itemCount: subscriptionPackages.length,
                                itemBuilder: (ctx, index) {
                                  return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedPackage =
                                              subscriptionPackages[index];
                                        });
                                      },
                                      child: SubscriptionPackageItemWeb(
                                          subscriptionPackages[index]));
                                },
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 1 / 1,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 1,
                                        mainAxisExtent: 210),
                              )
                        : Center(
                            child: const Text(
                                'Subscription plans are not available!'),
                          ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: screenWidth(context) < 800
              ? screenWidth(context) * 0.85
              : screenWidth(context) * 0.43,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              if (selectedPackage != null)
                SubscriptionPackageDetails(selectedPackage!),
            ],
          ),
        )
      ];
      if (screenWidth(context) < 800) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: screenWidth(context) < 400
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            _items[0],
            _items[1],
            const SizedBox(height: 10),
          ],
        );
      } else {
        return Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _items[0],
                const Spacer(),
                _items[1],
              ],
            ),
            const SizedBox(height: 10),
          ],
        );
      }
    }

    Widget _bodyWidget() {
      return _responsiveBody();
    }

    return Scaffold(
      key: scaffoldKey,
      endDrawer: WebBannerDrawer(),
      backgroundColor: Colors.white,
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
              padding: EdgeInsets.only(
                  left: (screenWidth(context) > 800
                      ? 65.0
                      : screenWidth(context) > 400
                          ? 25.0
                          : 20.0),
                  top: 40),
              child: Row(
                children: [
                  Text(
                    'Subscription Plans',
                    style: TextStyle(
                        letterSpacing: 0.0,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            Padding(
              padding: screenWidth(context) < 800
                  ? EdgeInsets.only(left: 20)
                  : const EdgeInsets.only(left: 50.0, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: screenWidth(context) * 0.90,
                    child: _bodyWidget(),
                  ),
                ],
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

class SubscriptionPackageDetails extends StatefulWidget {
  final SubscriptionPackage subscriptionPackage;

  SubscriptionPackageDetails(
    this.subscriptionPackage,
  );

  @override
  _SubscriptionPackageDetailsState createState() =>
      _SubscriptionPackageDetailsState();
}

class _SubscriptionPackageDetailsState
    extends State<SubscriptionPackageDetails> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    List<PackageSubCategory> _subCategoryList = [];
    _subCategoryList = widget.subscriptionPackage.subcatergoryList!
        .where((i) => i.name != '')
        .toList();

    return SingleChildScrollView(
      physics: ScrollPhysics(),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            shape: BoxShape.rectangle,
            border: Border.all(
              color: hexToColor(widget.subscriptionPackage.colorCode),
            )),
        child: Column(
          children: [
            //SizedBox(height: 20),
            //PACKAGE NAME TITLE
            Container(
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5.0,
                    ),
                  ],
                  color: hexToColor(widget.subscriptionPackage.colorCode),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  )
                  //borderRadius: BorderRadius.circular(10),
                  ),
              child: SizedBox(
                width: double.infinity,
                height: 45,
                child: Column(
                  children: [
                    Spacer(),
                    Text(
                      widget.subscriptionPackage.packageName,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
            //PACKAGE NAME TITLE
            const SizedBox(height: 10),
            //PRICE AND VALIDITY
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              alignment: Alignment.center,
              child: SizedBox(
                width: double.infinity,
                height: 80,
                child: Column(
                  children: [
                    Spacer(),
                    Text(
                      '₹ ${widget.subscriptionPackage.price.toInt().toString()}/-',
                      style: TextStyle(
                          color:
                              hexToColor(widget.subscriptionPackage.colorCode),
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                    Spacer(),
                    Text(
                      widget.subscriptionPackage.period,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                      textAlign: TextAlign.center,
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
            //PRICE AND VALIDITY

            //PACKAGE DETAILS
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
              ),
              alignment: Alignment.center,
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 2.0, right: 16.0, bottom: 16.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _subCategoryList.length,
                  itemBuilder: (BuildContext context, int i) {
                    return ListTile(
                      title: Text(_subCategoryList[i].name,
                          style: TextStyle(fontSize: 14)),
                      trailing: Text(_subCategoryList[i].quantity.toString(),
                          style: TextStyle(fontSize: 14)),
                    );
                  },
                ),
              ),
            ),
            //PACKAGE DETAILS
            const SizedBox(height: 10),
            //DESCRIPTION
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Features',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  splitString(widget.subscriptionPackage.description, '-', 14),
                ],
              ),
            ),
            //DESCRIPTION

            //UNLOCK BUTTON
            Container(
              width: double.infinity,
              height: 55,
              color: Colors.grey.shade50,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: screenWidth(context) < 800
                      ? screenWidth(context) < 400
                          ? screenWidth(context) * 0.40
                          : screenWidth(context) * 0.20
                      : screenWidth(context) * 0.10,
                  height: screenHeight(context) * 0.04,
                  child: appButton(
                      context: context,
                      width: double.infinity,
                      height: 40,
                      titleFontSize: 16,
                      title: 'Unlock the Plan',
                      titleColour:
                          hexToColor(widget.subscriptionPackage.colorCode),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentInitScreenWeb(
                              subscriptionPackage: widget.subscriptionPackage,
                              isRenew: false,
                            ),
                          ),
                        );
                      },
                      borderColor:
                          hexToColor(widget.subscriptionPackage.colorCode),
                      borderRadius: 20),
                ),
              ),
            ),
            //UNLOCK BUTTON
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class SubscriptionPackageItemWeb extends StatefulWidget {
  final SubscriptionPackage subscriptionPackage;
  SubscriptionPackageItemWeb(
    this.subscriptionPackage,
  );
  @override
  _SubscriptionPackageItemWebState createState() =>
      _SubscriptionPackageItemWebState();
}

class _SubscriptionPackageItemWebState
    extends State<SubscriptionPackageItemWeb> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              shape: BoxShape.rectangle,
              border: Border.all(
                color: hexToColor(widget.subscriptionPackage.colorCode),
              )),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              //HEADER
              Container(
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5.0,
                      ),
                    ],
                    color: hexToColor(widget.subscriptionPackage.colorCode),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    )
                    //borderRadius: BorderRadius.circular(10),
                    ),
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: Column(
                    children: [
                      Spacer(),
                      Text(
                        widget.subscriptionPackage.packageName,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
              //HEADER
              const SizedBox(height: 20),
              //PRICE
              SizedBox(
                width: 320,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '₹ ${widget.subscriptionPackage.price.toInt().toString()}/-',
                    style: TextStyle(
                        color: hexToColor(widget.subscriptionPackage.colorCode),
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0),
                  ),
                ),
              ),
              //PRICE
              const SizedBox(height: 20),
              //VALIDITY
              SizedBox(
                width: 320,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    widget.subscriptionPackage.period,
                    style: TextStyle(
                        color: hexToColor(widget.subscriptionPackage.colorCode),
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                ),
              ),
              //VALIDITY
              const SizedBox(height: 5),
              //UNLOCK BUTTON
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: screenWidth(context) < 800
                      ? screenWidth(context) < 400
                          ? screenWidth(context) * 0.40
                          : screenWidth(context) * 0.20
                      : screenWidth(context) * 0.10,
                  height: screenHeight(context) * 0.04,
                  child: appButton(
                      context: context,
                      width: double.infinity,
                      height: 40,
                      titleFontSize: 14,
                      title: 'Unlock the Plan',
                      titleColour:
                          hexToColor(widget.subscriptionPackage.colorCode),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentInitScreenWeb(
                              subscriptionPackage: widget.subscriptionPackage,
                              isRenew: false,
                            ),
                          ),
                        );
                      },
                      borderColor:
                          hexToColor(widget.subscriptionPackage.colorCode),
                      borderRadius: 20),
                ),
              ),
              //UNLOCK BUTTON
              //SizedBox(height: 10),

              //BOARDER WITH VIEWMORE BUTTON
              Container(
                color: Colors.grey.shade50,
                height: 40,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5.0,
                              ),
                            ],
                            color: hexToColor(
                                widget.subscriptionPackage.colorCode),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            )
                            //borderRadius: BorderRadius.circular(10),
                            ),
                        child:
                            const SizedBox(width: double.infinity, height: 30),
                      ),
                    ),
                  ],
                ),
              ),
              //BOARDER WITH VIEWMORE BUTTON
            ],
          ),
        ),
      ],
    );
  }
}
