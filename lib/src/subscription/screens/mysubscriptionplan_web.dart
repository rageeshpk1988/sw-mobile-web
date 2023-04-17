import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/src/subscription/screens/subscriptionplans_web.dart';
import '../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../widgets/web_banner.dart';
import '../../../widgets/web_bottom_bar.dart';
import '/src/models/login_response.dart';
import '/src/models/parent_subscription.dart';
import '/src/models/subscription_package.dart';
import '/src/providers/subscriptions.dart';
import '/util/date_util.dart';
import '../../../src/subscription/screens/payment_init.dart';

import '../../../util/dialogs.dart';
import '../../../util/ui_helpers.dart';
import '../../providers/auth.dart';

class MySubscriptionPlanScreenWeb extends StatefulWidget {
  static String routeName = '/web-my-subscription-plan';
  const MySubscriptionPlanScreenWeb({Key? key}) : super(key: key);

  @override
  _MySubscriptionPlanScreenWebState createState() =>
      _MySubscriptionPlanScreenWebState();
}

class _MySubscriptionPlanScreenWebState
    extends State<MySubscriptionPlanScreenWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSwitched = false;
  bool _isInIt = true;
  var _isLoading = false;
  late ParentSubscriptionGroup? _parentSubscription = null;
  bool _selectedFuturePlan = false;
  @override
  void didChangeDependencies() {
    if (_isInIt) {
      getPackage();
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
    Widget _responsiveBody() {
      List<Widget> _items = [
        SizedBox(
          width: screenWidth(context) < 800
              ? screenWidth(context) * 0.95
              : screenWidth(context) * 0.45,
          child: SingleChildScrollView(
            child: _parentSubscription != null
                ? screenWidth(context) < 800
                    ? Column(
                        children: [
                          const SizedBox(height: 30),
                          SizedBox(
                            width: screenWidth(context),
                            height: screenWidth(context) < 400 ? 350 : 380,
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: 1,
                                itemBuilder: (ctx, index) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: screenWidth(context) < 400
                                            ? screenWidth(context) * 0.90
                                            : screenWidth(context) * 0.50,
                                        child: GestureDetector(
                                          onTap: () {
                                            _selectedFuturePlan = false;
                                            setState(() {});
                                          },
                                          child: MySubscriptionPackage(
                                              _parentSubscription!.currentPlan,
                                              false,
                                              _parentSubscription!
                                                      .futurePlan!.isEmpty
                                                  ? true
                                                  : false,
                                              getPackage),
                                        ),
                                      ),
                                      if (_parentSubscription!
                                          .futurePlan!.isNotEmpty)
                                        SizedBox(
                                          width: screenWidth(context) < 400
                                              ? screenWidth(context) * 0.90
                                              : screenWidth(context) * 0.50,
                                          child: GestureDetector(
                                            onTap: () {
                                              _selectedFuturePlan = true;
                                              setState(() {});
                                            },
                                            child: MySubscriptionPackage(
                                                _parentSubscription!
                                                    .futurePlan!.first,
                                                true,
                                                false,
                                                getPackage),
                                          ),
                                        )
                                    ],
                                  );
                                }),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          GestureDetector(
                            onTap: () {
                              _selectedFuturePlan = false;
                              setState(() {});
                            },
                            child: MySubscriptionPackage(
                                _parentSubscription!.currentPlan,
                                false,
                                _parentSubscription!.futurePlan!.isEmpty
                                    ? true
                                    : false,
                                getPackage),
                          ),
                          if (_parentSubscription!.futurePlan!.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _selectedFuturePlan = true;
                                setState(() {});
                              },
                              child: MySubscriptionPackage(
                                  _parentSubscription!.futurePlan!.first,
                                  true,
                                  false,
                                  getPackage),
                            ),
                        ],
                      )
                : Center(
                    child: const Text('Subscriptions are not available!'),
                  ),
          ),
        ),
        SizedBox(
          width: screenWidth(context) < 800
              ? screenWidth(context) * 0.95
              : screenWidth(context) * 0.43,
          child: Column(
            children: [
              const SizedBox(height: 30),
              ParentSubscriptionDetails(
                  _selectedFuturePlan
                      ? _parentSubscription!.futurePlan!.first
                      : _parentSubscription!.currentPlan,
                  _selectedFuturePlan),
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
                      ? 80.0
                      : screenWidth(context) > 400
                          ? 45.0
                          : 30.0),
                  top: 40),
              child: Row(
                children: [
                  Text(
                    'My Subscription',
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
              height: screenWidth(context) > 400
                  ? screenHeight(context) * 0.98
                  : null,
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

class ParentSubscriptionDetails extends StatefulWidget {
  final ParentSubscription subscriptionPackage;

  final bool futurePlan;
  ParentSubscriptionDetails(
    this.subscriptionPackage,
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
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            shape: BoxShape.rectangle,
            border: Border.all(
              color: hexToColor(widget.subscriptionPackage.colorCode),
            )),
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
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: Text(
                        'Unused ${_subCategoryList[i].unusedPlan}',
                        style: TextStyle(
                          fontSize: 14,
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
            // //BOARDER WITH VIEWMORE BUTTON
            // Container(
            //   color: Colors.grey.shade50,
            //   height: 70,
            //   child: Stack(
            //     children: [
            //       Align(
            //         alignment: Alignment.bottomCenter,
            //         child: Container(
            //           decoration: BoxDecoration(
            //               boxShadow: [
            //                 BoxShadow(
            //                   color: Colors.grey,
            //                   blurRadius: 5.0,
            //                 ),
            //               ],
            //               color:
            //                   hexToColor(widget.subscriptionPackage.colorCode),
            //               borderRadius: BorderRadius.only(
            //                 bottomLeft: Radius.circular(10),
            //                 bottomRight: Radius.circular(10),
            //               )
            //               //borderRadius: BorderRadius.circular(10),
            //               ),
            //           child: const SizedBox(width: double.infinity, height: 45),
            //         ),
            //       ),
            //       Positioned.fill(
            //         top: -5,
            //         child: Align(
            //           alignment: Alignment.center,
            //           child: ElevatedButton(
            //             onPressed: () {
            //               setState(() {
            //                 widget.expandHandler();
            //                 //_expanded = !_expanded;
            //               });
            //             },
            //             child: Icon(Icons.keyboard_double_arrow_up, size: 30),
            //             style: ElevatedButton.styleFrom(
            //                 shape: CircleBorder(),
            //                 padding: EdgeInsets.all(10),
            //                 side: BorderSide(color: Colors.white),
            //                 backgroundColor: hexToColor(
            //                     widget.subscriptionPackage.colorCode)),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // //BOARDER WITH VIEWMORE BUTTON
            const SizedBox(height: 20),
          ],
        ),
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
        height: futurePlan ? 180 : 200,
        child: Column(
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
            const SizedBox(height: 10),
            //PRICE
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '₹ ${this.subscriptionPackage.price.toInt().toString()}/-',
                    style: TextStyle(
                        color: hexToColor(this.subscriptionPackage.colorCode),
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0),
                  ),
                ),
                if (!futurePlan)
                  Image(
                    image: AssetImage('assets/images/currentplan.png'),
                    width: 60,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                if (futurePlan)
                  Image(
                    image: AssetImage('assets/images/newplan.png'),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
              ],
            ),
            //PRICE

            //VALIDITY
            Align(
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
            //VALIDITY
            //SUBSCRIPTION DATES
            Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, right: 8.0, bottom: 0.0, top: 8.0),
              child: Row(
                mainAxisAlignment: screenWidth(context) > 800
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  if (!futurePlan)
                    Text(
                      'Activated ${DateUtil.formattedDate(this.subscriptionPackage.startingDate!)}',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                  if (futurePlan)
                    Text(
                      'Activates on ${DateUtil.formattedDate(this.subscriptionPackage.startingDate!)}',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                  if (!futurePlan) const Spacer(),
                  if (!futurePlan)
                    Text(
                        'Valid Until ${DateUtil.formattedDate(this.subscriptionPackage.endingDate!)}',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                ],
              ),
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
  bool _isLoading = false;

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
            description: widget.subscriptionPackage.description);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PaymentInitScreen(
                    subscriptionPackage: packageSelected,
                    isRenew: true,
                  )),
        );
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
        mainAxisSize: MainAxisSize.min,
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
                MySubscriptionHeader(
                  subscriptionPackage: widget.subscriptionPackage,
                  futurePlan: widget.futurePlan,
                ),
                //HEADER
                //const SizedBox(height: 10),
                //RENEW and CHANGE PLAN BUTTON
                if (!widget.futurePlan)
                  if (widget.planUpgradeOption)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                      child: SizedBox(
                        height: screenWidth(context) > 800 ? 35 : 40,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 110,
                              //height: screenWidth(context) > 800 ? 35 : 30,
                              child: appButton(
                                  context: context,
                                  width: double.infinity,
                                  height: screenWidth(context) > 400 ? 35 : 30,
                                  titleFontSize:
                                      screenWidth(context) > 400 ? 16 : 14,
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
                              //height: screenWidth(context) > 800 ? 35 : 30,
                              child: appButton(
                                  context: context,
                                  width: double.infinity,
                                  height: screenWidth(context) > 400 ? 35 : 30,
                                  titleFontSize:
                                      screenWidth(context) > 400 ? 16 : 14,
                                  title: 'Change Plan',
                                  titleColour: hexToColor(
                                      widget.subscriptionPackage.colorCode),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SubscriptionPlansScreenWeb()),
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
                          height: screenWidth(context) > 800 ? 35 : 40,
                          child: appButton(
                              context: context,
                              width: double.infinity,
                              height: screenWidth(context) > 400 ? 35 : 30,
                              titleFontSize:
                                  screenWidth(context) > 400 ? 16 : 14,
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
                if (!widget.futurePlan) const SizedBox(height: 10),

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
                    ],
                  ),
                ),
                //BOARDER WITH VIEWMORE BUTTON
              ],
            ),
          ),
        ],
      ),
    );
  }
}
