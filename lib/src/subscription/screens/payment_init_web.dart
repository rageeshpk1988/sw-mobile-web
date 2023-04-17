import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../../util/date_util.dart';
import '../../../util/stripe_checkout.dart';
import '../../../widgets/web_banner.dart';
import '../../../widgets/web_bottom_bar.dart';
import '/adaptive/adaptive_circular_progressInd.dart';

import '/src/providers/subscriptions.dart';

import '../../../adaptive/adaptive_theme.dart';

import '../../../util/app_theme.dart';
import '../../../util/dialogs.dart';
import '../../../util/ui_helpers.dart';
import '../../../widgets/rounded_button.dart';

import '../../models/login_response.dart';
import '../../models/parent_subscription.dart';
import '../../models/subscription_package.dart';

import '../../providers/auth.dart';
import 'mySubscriptionPlan.dart';

class PaymentInitScreenWeb extends StatefulWidget {
  final SubscriptionPackage subscriptionPackage;
  final bool isRenew;
  const PaymentInitScreenWeb({
    Key? key,
    required this.subscriptionPackage,
    required this.isRenew,
  }) : super(key: key);

  @override
  _PaymentInitScreenWebState createState() => _PaymentInitScreenWebState();
}

class _PaymentInitScreenWebState extends State<PaymentInitScreenWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSwitched = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _numberFocusNode = FocusNode();
  late LoginResponse _loginResponse;
  //ChecksumResponse? _checksumResponse;
  var _isInIt = true;
  var _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _numberFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      setState(() {
        _isLoading = true;
      });
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
      _nameController.text = _loginResponse.b2cParent!.name;
      _emailController.text = _loginResponse.b2cParent!.emailID;
      _phoneNumberController.text = _loginResponse.mobileNumber;

      setState(() {
        _isLoading = false;
      });
      _isInIt = false;
      super.didChangeDependencies();
    }
  }

  Future<ParentSubscriptionGroup?> verifySubscriptionPackage() async {
    late ParentSubscriptionGroup? parentSubscription;
    var parentId = _loginResponse.b2cParent!.parentID;
    //var authToken = _loginResponse.token;
    try {
      parentSubscription =
          await Provider.of<Subscriptions>(context, listen: false)
              .listParentSubscription(parentId);
      return parentSubscription;
    } catch (e) {
      if (e.toString().indexOf("No subscription found") >= 0 ||
          e.toString().indexOf("No current package subscribed") >= 0) {
        return null;
      }
      throw Exception('Error while verifying the current package');
    }
  }

  //TODO :: NEED TO DISCUSS

  void saveSubscription(
      String subscriptionStatus,
      String packageStatus,
      double transactionAmount,
      DateTime transactionDate,
      ParentSubscriptionGroup? parentSubscription) async {
    var _inserted = await Provider.of<Subscriptions>(context, listen: false)
        .saveSubscription(
            _loginResponse.b2cParent!.parentID,
            widget.subscriptionPackage.packageId,
            transactionAmount,
            _loginResponse.customerId,
            subscriptionStatus,
            packageStatus,
            DateUtil.formattedDateExtended_2(transactionDate),
            null,
            null,
            null,
            null);
    if (_inserted) {
      setState(() {
        _isLoading = false;
      });
      await Dialogs().ackSuccessAlert(
          context,
          "SUCCESS!!!",
          transactionAmount == 0
              ? "Package Subscribed!"
              : "Payment Completed!");

      int count = 0;
      if (parentSubscription == null) {
        Navigator.of(context).popUntil((_) => count++ >= 2);
        Navigator.of(context).pushNamed(MySubscriptionPlanScreen.routeName);
      } else {
        Navigator.of(context).popUntil((_) => count++ >= 2);
        Navigator.of(context)
            .pushReplacementNamed(MySubscriptionPlanScreen.routeName);
      }
    }
  }

  //REDIRECT TO CHECKOUT VOID
  // RETURN BACK TO MY SUBSCRIPTION PAGE
  void redirectToStripCheckout() {
    String unFoldPriceId = 'price_1MawGuSHGXtUJ2HUDN45IbzO';
    redirectToCheckout(
        context, unFoldPriceId, _loginResponse.b2cParent!.emailID);
  }

  void initiatePayment(double newPackagePrice) async {
    try {
      setState(() {
        _isLoading = true;
      });

      //STRIPE CHECKOUT ( if package price is zero then same work flow as in mobile)
      if (newPackagePrice > 0) {
        redirectToStripCheckout();
      } else {
        setState(() {
          _isLoading = true;
        });
        //Verify current plan
        ParentSubscriptionGroup? parentSubscription =
            await verifySubscriptionPackage();
        String _subscriptionStatus = '';

        if (parentSubscription == null) {
          //New subscription
          _subscriptionStatus = 'renew';
        } else {
          //Upgrade or renew
          if (widget.isRenew) {
            _subscriptionStatus = 'renew';
          } else {
            var result = await Dialogs().subscriptionDialog(
                context,
                "Subscription Status",
                "Your current plan is valid for ${parentSubscription.currentPlan.remainingDays}. Please "
                    "choose 'Now' to activate the new plan with immediate effect. Or choose 'After Expiry' to active the plan after the expiry of the current plan");
            if (result == DialogSubscriptionStatus.NOW) {
              _subscriptionStatus = 'upgrade';
            } else {
              _subscriptionStatus = 'renew';
            }
          }
        }
        saveSubscription(
            _subscriptionStatus, 'free', 0, DateTime.now(), parentSubscription);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      await Dialogs().ackAlert(context, "Subscription Status",
          "${e.toString()}.\nPlease Try Again later.");
      //Navigator.pop(context);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _textViewStyle =
        AppTheme.lightTheme.textTheme.bodySmall!.copyWith(fontSize: 15);

    Widget _bodyWidget() {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(10),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Column(
                    children: [
                      TextFormField(
                        style: _textViewStyle,
                        enabled: false,
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: AdaptiveTheme.textFormFieldDecoration(
                            context, 'Name', _numberFocusNode),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        style: _textViewStyle,
                        enabled: false,
                        controller: _emailController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        decoration: AdaptiveTheme.textFormFieldDecoration(
                            context, 'Email', _numberFocusNode),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        style: _textViewStyle,
                        enabled: false,
                        controller: _phoneNumberController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        decoration: AdaptiveTheme.textFormFieldDecoration(
                            context, 'Phone Number', _numberFocusNode),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Package Information',
                  style: _textViewStyle,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5.0,
                      ),
                    ],
                    color: hexToColor(widget.subscriptionPackage.colorCode),
                    // color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.all(10),
                child: SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      children: [
                        Text('${widget.subscriptionPackage.packageName}',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        Spacer(),
                        Row(
                          children: [
                            Text(
                                'Total : \u{20B9}${widget.subscriptionPackage.price}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Spacer(),
                            Text(
                                'Validity: ${widget.subscriptionPackage.period}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal)),
                          ],
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              _isLoading == true
                  ? Center(child: AdaptiveCircularProgressIndicator())
                  : Row(
                      children: [
                        RoundButton(
                            title: 'Skip',
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            color: Colors.grey),
                        Spacer(),
                        RoundButton(
                            title: 'Continue',
                            onPressed: _isLoading
                                ? null
                                : () {
                                    initiatePayment(double.parse(widget
                                        .subscriptionPackage.price
                                        .toString()));
                                  },
                            color: AppTheme.primaryColor),
                      ],
                    )
            ],
          ),
        ),
      );
    }

    return WillPopScope(
        onWillPop: () async {
          if (_isLoading == true) {
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
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
                        'Subscription Payment',
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
                  width: screenWidth(context) *
                      (screenWidth(context) > 800
                          ? 0.50
                          : screenWidth(context) > 400
                              ? 0.70
                              : 0.98),
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
        ));
  }
}
