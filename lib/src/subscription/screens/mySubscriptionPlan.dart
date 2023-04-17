import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/src/models/login_response.dart';
import '/src/models/parent_subscription.dart';
import '/src/models/subscription_package.dart';
import '/src/providers/subscriptions.dart';
import '/util/date_util.dart';
import '../../../src/subscription/screens/payment_init.dart';
import '../../../src/subscription/screens/subcriptionsPlans.dart';

import '../../../../adaptive/adaptive_custom_appbar.dart';
import '../../../util/dialogs.dart';
import '../../../util/ui_helpers.dart';
import '../../providers/auth.dart';
import 'payment_init_new.dart';

class MySubscriptionPlanScreen extends StatefulWidget {
  static String routeName = '/my-subscription-plan';
  const MySubscriptionPlanScreen({Key? key}) : super(key: key);

  @override
  _MySubscriptionPlanScreenState createState() =>
      _MySubscriptionPlanScreenState();
}

class _MySubscriptionPlanScreenState extends State<MySubscriptionPlanScreen> {
  bool isSwitched = false;
  bool _isInIt = true;
  var _isLoading = false;
  late ParentSubscriptionGroup? _parentSubscription = null;
  @override
  void didChangeDependencies() {
    if (_isInIt) {
      getPackage();
      // setState(() {
      //   _isLoading = true;
      // });

      // var loginResponse =
      //     Provider.of<Auth>(context, listen: false).loginResponse;

      // var parentId = loginResponse.b2cParent!.parentID;
      // var authToken = loginResponse.token;

      // Provider.of<Subscriptions>(context, listen: false)
      //     .listParentSubscription(parentId, authToken)
      //     .then((value) {
      //   setState(() {
      //     _parentSubscription = value;
      //     _isLoading = false;
      //   });
      // }).onError((error, stackTrace) {
      //   Dialogs().ackAlert(context, "Subscription Plan", error.toString());

      //   setState(() {
      //     _isLoading = false;
      //   });
      // });
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

  void getPackage() {
    setState(() {
      _isLoading = true;
    });

    var loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;

    var parentId = loginResponse.b2cParent!.parentID;

    Provider.of<Subscriptions>(context, listen: false)
        .listParentSubscription(parentId)
        .then((value) {
      setState(() {
        _parentSubscription = value;
        _isLoading = false;
      });
    }).onError((error, stackTrace) {
      Dialogs().ackAlert(context, "Subscription Plan", error.toString());

      setState(() {
        _isLoading = false;
      });
    });
    //setState(() {});
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
        title: 'My Subscription',
        showMascot: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                if (_parentSubscription != null)
                  MySubscriptionPackage(
                      _parentSubscription!.currentPlan,
                      false,
                      _parentSubscription!.futurePlan!.isEmpty ? true : false,
                      getPackage),
                if (_parentSubscription != null)
                  if (_parentSubscription!.futurePlan!.isNotEmpty)
                    MySubscriptionPackage(
                        _parentSubscription!.futurePlan!.first,
                        true,
                        false,
                        getPackage),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ParentSubscriptionDetails extends StatefulWidget {
  final ParentSubscription subscriptionPackage;
  final Function expandHandler;
  final bool futurePlan;
  ParentSubscriptionDetails(
    this.subscriptionPackage,
    this.expandHandler,
    this.futurePlan,
  );

  @override
  _ParentSubscriptionDetailsState createState() =>
      _ParentSubscriptionDetailsState();
}

class _ParentSubscriptionDetailsState extends State<ParentSubscriptionDetails> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    List<SubCategoryList> _subCategoryList = [];
    _subCategoryList = widget.subscriptionPackage.subCategoryList
        .where((i) => i.categoryName != '')
        .cast<SubCategoryList>()
        .toList();

    return SingleChildScrollView(
      physics: ScrollPhysics(),
      child: Column(
        children: [
          //HEADER
          MySubscriptionHeader(
            subscriptionPackage: widget.subscriptionPackage,
            futurePlan: widget.futurePlan,
          ),
          //PACKAGE DETAILS
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
            ),
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _subCategoryList.length,
                itemBuilder: (BuildContext context, int i) {
                  return ListTile(
                    title: Text(
                      '${_subCategoryList[i].categoryName}   ${_subCategoryList[i].count}',
                      style: TextStyle(
                          fontSize: textScale(context) <= 1.0 ? 14 : 11),
                    ),
                    trailing: Text(
                      'Unused ${_subCategoryList[i].unusedPlan}',
                      style: TextStyle(
                        fontSize: textScale(context) <= 1.0 ? 14 : 11,
                      ),
                    ),
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
                          fontSize: textScale(context) <= 1.0 ? 14 : 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                splitString(widget.subscriptionPackage.description, '-',
                    textScale(context) <= 1.0 ? 14 : 11),
              ],
            ),
          ),
          //DESCRIPTION
          //BOARDER WITH VIEWMORE BUTTON
          Container(
            color: Colors.grey.shade50,
            height: 70,
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
                        color: hexToColor(widget.subscriptionPackage.colorCode),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        )
                        //borderRadius: BorderRadius.circular(10),
                        ),
                    child: const SizedBox(width: double.infinity, height: 45),
                  ),
                ),
                Positioned.fill(
                  top: -5,
                  child: Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          widget.expandHandler();
                          //_expanded = !_expanded;
                        });
                      },
                      child: Icon(Icons.keyboard_double_arrow_up, size: 30),
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(10),
                          side: BorderSide(color: Colors.white),
                          backgroundColor:
                              hexToColor(widget.subscriptionPackage.colorCode)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          //BOARDER WITH VIEWMORE BUTTON

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class MySubscriptionHeader extends StatelessWidget {
  final ParentSubscription subscriptionPackage;
  final bool futurePlan;
  const MySubscriptionHeader({
    required this.subscriptionPackage,
    required this.futurePlan,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: SizedBox(
        height: 170,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5.0,
                    ),
                  ],
                  color: hexToColor(this.subscriptionPackage.colorCode),
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
                      this.subscriptionPackage.packageName,
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
            if (futurePlan)
              Positioned(
                right: 20,
                top: 20,
                child: Image(
                  image: AssetImage('assets/images/newplan.png'),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            //PRICE
            Positioned(
              left: 150,
              top: 70,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '₹ ${this.subscriptionPackage.price.toInt().toString()}/-',
                  style: TextStyle(
                      color: hexToColor(this.subscriptionPackage.colorCode),
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0),
                ),
              ),
            ),
            //PRICE
            if (!futurePlan)
              Positioned(
                left: 230,
                top: 50,
                child: Image(
                  image: AssetImage('assets/images/currentplan.png'),
                  width: 60,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
            //VALIDITY
            Positioned(
              left: 130,
              top: 110,
              child: Align(
                alignment: Alignment.center,
                child: RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    style: TextStyle(
                        letterSpacing: 0.0,
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                    children: <TextSpan>[
                      if (futurePlan)
                        TextSpan(
                            text: 'Validity ',
                            style: TextStyle(fontWeight: FontWeight.normal)),
                      if (futurePlan)
                        TextSpan(
                            text: this.subscriptionPackage.period.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      if (futurePlan)
                        TextSpan(
                            text: this.subscriptionPackage.period > 1
                                ? ' months'
                                : ' month',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      if (!futurePlan)
                        TextSpan(
                            text: this.subscriptionPackage.remainingDays,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      if (!futurePlan)
                        TextSpan(
                            text: this
                                        .subscriptionPackage
                                        .remainingDays
                                        .toLowerCase() ==
                                    'expired'
                                ? ''
                                : ' remaining',
                            style: TextStyle(fontWeight: FontWeight.normal))
                    ],
                  ),
                ),
              ),
            ),
            //VALIDITY
            //SUBSCRIPTION DATES
            if (!futurePlan)
              Positioned(
                left: 13,
                bottom: 1,
                child: Text(
                  'Activated ${DateUtil.formattedDate(this.subscriptionPackage.startingDate!)}',
                  style: TextStyle(
                      fontSize: textScale(context) <= 1.0 ? 15 : 12,
                      fontWeight: FontWeight.w400),
                ),
              ),
            if (futurePlan)
              Positioned(
                left: 120,
                bottom: 1,
                child: Text(
                  'Activates on ${DateUtil.formattedDate(this.subscriptionPackage.startingDate!)}',
                  style: TextStyle(
                      fontSize: textScale(context) <= 1.0 ? 15 : 12,
                      fontWeight: FontWeight.w400),
                ),
              ),
            if (!futurePlan)
              Positioned(
                right: 10,
                bottom: 1,
                child: Text(
                    'Valid Until ${DateUtil.formattedDate(this.subscriptionPackage.endingDate!)}',
                    style: TextStyle(
                        fontSize: textScale(context) <= 1.0 ? 15 : 12,
                        fontWeight: FontWeight.w400)),
              ),

            //SUBSCRIPTION DATES
          ],
        ),
      ),
    );
  }
}

class MySubscriptionPackage extends StatefulWidget {
  final ParentSubscription subscriptionPackage;
  final bool futurePlan;
  final bool planUpgradeOption;
  final Function refreshParentHandler;
  MySubscriptionPackage(
    this.subscriptionPackage,
    this.futurePlan,
    this.planUpgradeOption,
    this.refreshParentHandler,
  );
  @override
  _MySubscriptionPackageState createState() => _MySubscriptionPackageState();
}

class _MySubscriptionPackageState extends State<MySubscriptionPackage> {
  var _expanded = false;
  bool _isLoading = false;
  void expandAndCollapse() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  Future<void> _activateNow() async {
    setState(() {
      _isLoading = true;
    });
    LoginResponse loginResponse =
        Provider.of<Auth>(context, listen: false).loginResponse;
    var parentId = loginResponse.b2cParent!.parentID;
    //var authToken = loginResponse.token;
    try {
      var _inserted = await Provider.of<Subscriptions>(context, listen: false)
          .activateSubscription(parentId);
      if (_inserted) {
        setState(() {
          _isLoading = false;
        });

        await Dialogs()
            .ackSuccessAlert(context, 'SUCCESS!!!', 'Plan Activated!');
        widget.refreshParentHandler();
        // Navigator.of(context).pop();
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      await Dialogs().ackAlert(context, 'An error occured', error.toString());
    }
  }

  Future<void> _renewPackage() async {
    setState(() {
      _isLoading = true;
    });
    // LoginResponse loginResponse =
    //     Provider.of<Auth>(context, listen: false).loginResponse;
    var packageId = widget.subscriptionPackage.packageId;
    // var authToken = loginResponse.token;
    try {
      var _deletedStatus =
          await Provider.of<Subscriptions>(context, listen: false)
              .packageStatus(packageId);
      if (_deletedStatus == false) {
        setState(() {
          _isLoading = false;
        });

        SubscriptionPackage packageSelected = SubscriptionPackage(
            period: widget.subscriptionPackage.period.toString(),
            packageName: widget.subscriptionPackage.packageName,
            packageId: widget.subscriptionPackage.packageId,
            price: widget.subscriptionPackage.price,
            colorCode: widget.subscriptionPackage.colorCode,
            packageRate: widget.subscriptionPackage.price,
            description: widget.subscriptionPackage.description,
            consumableId: widget.subscriptionPackage.consumableId);
        if (Platform.isIOS) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PaymentInitScreenNew(
                      subscriptionPackage: packageSelected,
                      isRenew: true,
                    )),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PaymentInitScreen(
                      subscriptionPackage: packageSelected,
                      isRenew: true,
                    )),
          );
        }
      } else {
        await Dialogs().ackInfoAlert(context,
            'The package is currently discontinued! Please change your plan.');
        // Navigator.of(context).pop();
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      await Dialogs().ackAlert(context, 'An error occured', error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 10),
      child: Column(
        children: [
          if (!_expanded)
            Container(
              child: Column(
                children: <Widget>[
                  //HEADER
                  MySubscriptionHeader(
                    subscriptionPackage: widget.subscriptionPackage,
                    futurePlan: widget.futurePlan,
                  ),
                  //HEADER
                  const SizedBox(height: 10),
                  //RENEW and CHANGE PLAN BUTTON
                  if (!widget.futurePlan)
                    if (widget.planUpgradeOption)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 110,
                              child: appButton(
                                  context: context,
                                  width: double.infinity,
                                  height: 35,
                                  titleFontSize:
                                      textScale(context) <= 1.0 ? 16 : 11,
                                  title: 'Renew Plan',
                                  titleColour: hexToColor(
                                      widget.subscriptionPackage.colorCode),
                                  onPressed: _renewPackage,
                                  borderColor: hexToColor(
                                      widget.subscriptionPackage.colorCode),
                                  borderRadius: 20),
                            ),
                            Spacer(),
                            SizedBox(
                              width: 110,
                              child: appButton(
                                  context: context,
                                  width: double.infinity,
                                  height: 35,
                                  titleFontSize:
                                      textScale(context) <= 1.0 ? 16 : 11,
                                  title: 'Change Plan',
                                  titleColour: hexToColor(
                                      widget.subscriptionPackage.colorCode),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SubscriptionPlansScreen()),
                                    ).then((value) {
                                      widget.refreshParentHandler();
                                      setState(() {});
                                    });
                                  },
                                  borderColor: hexToColor(
                                      widget.subscriptionPackage.colorCode),
                                  borderRadius: 20),
                            ),
                          ],
                        ),
                      ),
                  //RENEW and CHANGE PLAN BUTTON
                  //ACTIVATE NOW BUTTON
                  if (widget.futurePlan)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 130,
                            child: appButton(
                                context: context,
                                width: double.infinity,
                                height: 35,
                                titleFontSize:
                                    textScale(context) <= 1.0 ? 16 : 11,
                                title: 'Activate Now',
                                titleColour: hexToColor(
                                    widget.subscriptionPackage.colorCode),
                                onPressed: _activateNow,
                                borderColor: hexToColor(
                                    widget.subscriptionPackage.colorCode),
                                borderRadius: 20),
                          ),
                        ],
                      ),
                    ),

                  //ACTIVATE NOW BUTTON
                  const SizedBox(height: 10),
                  //BOARDER WITH VIEWMORE BUTTON
                  Container(
                    color: Colors.grey.shade50,
                    height: 70,
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
                            child: const SizedBox(
                                width: double.infinity, height: 45),
                          ),
                        ),
                        Positioned.fill(
                          top: -5,
                          child: Align(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _expanded = !_expanded;
                                });
                              },
                              child: Icon(Icons.keyboard_double_arrow_down,
                                  size: 30),
                              style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(10),
                                  side: BorderSide(color: Colors.white),
                                  backgroundColor: hexToColor(
                                      widget.subscriptionPackage.colorCode)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //BOARDER WITH VIEWMORE BUTTON
                  const SizedBox(height: 10),
                ],
              ),
            ),
          if (_expanded)
            ParentSubscriptionDetails(widget.subscriptionPackage,
                expandAndCollapse, widget.futurePlan)
        ],
      ),
    );
  }
}
