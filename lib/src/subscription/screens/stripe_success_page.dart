import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../../util/date_util.dart';

import '../../../widgets/web_banner.dart';
import '../../../widgets/web_bottom_bar.dart';
import '/adaptive/adaptive_circular_progressInd.dart';

import '/src/providers/subscriptions.dart';

import '../../../util/app_theme.dart';
import '../../../util/dialogs.dart';
import '../../../util/ui_helpers.dart';
import '../../../widgets/rounded_button.dart';

import '../../models/login_response.dart';
import '../../models/parent_subscription.dart';

import '../../providers/auth.dart';
import 'mySubscriptionPlan.dart';

class StripeSuccessPage extends StatefulWidget {
  static String routeName = '/stripe-success-page';
  //final bool isRenew;
  const StripeSuccessPage({Key? key}) : super(key: key);

  @override
  _StripeSuccessPageState createState() => _StripeSuccessPageState();
}

class _StripeSuccessPageState extends State<StripeSuccessPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSwitched = false;

  late LoginResponse _loginResponse;

  var _isInIt = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      setState(() {
        _isLoading = true;
      });
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
      refreshPayment();
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

  void saveSubscription(
      String subscriptionStatus,
      String packageStatus,
      double transactionAmount,
      DateTime transactionDate,
      ParentSubscriptionGroup? parentSubscription) async {
    try {
      var _inserted = await Provider.of<Subscriptions>(context, listen: false)
          .saveSubscription(
              _loginResponse.b2cParent!.parentID,
              0, // widget.subscriptionPackage.packageId,
              0, //transactionAmount,
              _loginResponse.customerId,
              subscriptionStatus,
              packageStatus,
              DateUtil.formattedDateExtended_2(transactionDate),
              '', // transactionId,
              '', // checkSum,
              '', //mID,
              '' // orderId
              )
          .onError((error, stackTrace) {
        throw error.toString();
      });

      if (_inserted) {
        setState(() {
          _isLoading = false;
        });
        //  await Dialogs().ackSuccessAlert(context, "SUCCESS!!!",
        //         "\n Order Id: $orderId \n Payment Mode: $paymentMode \n Amount: \u{20B9}$transactionAmount");

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
    } catch (e) {
      throw e.toString();
    }
  }

  void refreshPayment() async {
    try {
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
        //Upgrade or renew //TODO :: Renew should be handled
        // if (widget.isRenew) {
        if (0 == 0) {
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
      //Save subscription
      setState(() {
        _isLoading = true;
      });
      saveSubscription(
          _subscriptionStatus, 'paid', 0, DateTime.now(), parentSubscription);
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
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Package Information',
                  style: _textViewStyle,
                ),
              ),
              const SizedBox(height: 10),
              _isLoading == true
                  ? Center(child: AdaptiveCircularProgressIndicator())
                  : Row(
                      children: [
                        RoundButton(
                            title: 'Home',
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.of(context).pushNamed('/');
                                  },
                            color: AppTheme.primaryColor),
                      ],
                    )
            ],
          ),
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
                    'Payment Confirmation',
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
    );
  }
}
