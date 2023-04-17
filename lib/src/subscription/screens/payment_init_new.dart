import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:provider/provider.dart';
import '../../../util/notify_user.dart';
import '/adaptive/adaptive_circular_progressInd.dart';

import '/src/models/checksum_response.dart';
import '/src/providers/subscriptions.dart';
import '/util/app_theme_cupertino.dart';
import '/util/date_util.dart';

import '../../../adaptive/adaptive_theme.dart';
import '../../../helpers/global_variables.dart';
import '../../../util/app_theme.dart';
import '../../../util/dialogs.dart';
import '../../../util/ui_helpers.dart';
import '../../../widgets/rounded_button.dart';

import '../../../../adaptive/adaptive_custom_appbar.dart';
import '../../models/login_response.dart';
import '../../models/parent_subscription.dart';
import '../../models/subscription_package.dart';
import '../../models/transaction_response.dart';
import '../../providers/auth.dart';
import '../../providers/payment_gateway.dart';
import 'mySubscriptionPlan.dart';

class PaymentInitScreenNew extends StatefulWidget {
  final SubscriptionPackage subscriptionPackage;
  final bool isRenew;
  const PaymentInitScreenNew({
    Key? key,
    required this.subscriptionPackage,
    required this.isRenew,
  }) : super(key: key);

  @override
  _PaymentInitScreenNewState createState() => _PaymentInitScreenNewState();
}

class _PaymentInitScreenNewState extends State<PaymentInitScreenNew> {
  bool isSwitched = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _numberFocusNode = FocusNode();
  late LoginResponse _loginResponse;
  ChecksumResponse? _checksumResponse;
  var _isInIt = true;
  var _isLoading = false;

  // new variables for in app purchase
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = <ProductDetails>[];




  @override
  void initState() {
    if (Platform.isIOS) {
      final Stream<List<PurchaseDetails>> purchaseUpdated =
          _inAppPurchase.purchaseStream;
      _subscription =
          purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {
        _subscription.cancel();
      }, onError: (Object error) {
        // handle error here.
      });
      initStoreInfo();
    }
    super.initState();
  }


  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      NotifyUser()
          .showSnackBar("Store not available, please try later", context);
      setState(() {
        _products = <ProductDetails>[];
      });
      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(PaymentQueueDelegate());
    }

    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(
            [widget.subscriptionPackage.consumableId!].toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _products = productDetailResponse.productDetails;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _products = productDetailResponse.productDetails;
      });
      return;
    }

    //final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _products = productDetailResponse.productDetails;
    });
  }


  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    setState(() {
      _isLoading = true;
    });
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        NotifyUser().showSnackBar("Purchase loading, please wait", context);
        //showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          setState(() {
            _isLoading = false;
          });
          Dialogs().ackAlert(context, "Error", "There was an error in loading the purchase, please try again");
        }else if(purchaseDetails.status == PurchaseStatus.canceled){
          setState(() {
            _isLoading = false;
          });
          Dialogs().ackAlert(context, "Error", "Purchase cancelled");
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          await _inAppPurchase.completePurchase(purchaseDetails);
          NotifyUser().showSnackBar("Verifying purchase, please wait", context);
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            NotifyUser()
                .showSnackBar("Completing purchase, please wait", context);
            initiatePaymentIOS(
                double.parse(widget.subscriptionPackage.price.toString()),
                purchaseDetails);
            // deliverProduct(purchaseDetails);
          } else {
            setState(() {
              _isLoading = false;
            });
            Dialogs().ackAlert(context, "Error", "Invalid Purchase");
            return;
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  

  @override
  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _numberFocusNode.dispose();
    super.dispose();
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    //TODO: Wire the new verify api here;

    bool status = await Provider.of<PaymentGateway>(context, listen: false)
        .verifyReceipt(purchaseDetails.verificationData.serverVerificationData);

    return status;
    // return Future<bool>.value(true);
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
    var authToken = _loginResponse.token;
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
      String? transactionId,
      String? orderId,
      String? paymentMode,
      String? checkSum,
      String? mID,
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
            transactionId,
            checkSum,
            mID,
            orderId);
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
  }

  Future<TransactionResponse?> startPaymentTransaction() async {
    late TransactionResponse? result = null;
    try {
      _checksumResponse =
          await Provider.of<PaymentGateway>(context, listen: false)
              .checksum(_loginResponse, widget.subscriptionPackage.packageId);

      var response = await AllInOneSdk.startTransaction(
          GlobalVariables.paytmMid,
          _checksumResponse!.orderId,
          widget.subscriptionPackage.price.toString(),
          _checksumResponse!.txnToken,
          GlobalVariables.paytmCallBackUrl,
          false,
          false);

      result = TransactionResponse.fromJson(response!);

      return result;
    } catch (e) {
      if (e is PlatformException) {
        var errMsg = e.message!;

        throw Exception('PayTM Service error! \n\n$errMsg');
      } else {
        //throw Exception(e.toString());
        throw Exception('Error while connecting to PayTM Service!');
      }
    }
  }

  void initiatePayment(double newPackagePrice) async {
    TransactionResponse? payTmResponse;
    try {
      setState(() {
        _isLoading = true;
      });
      //Verify current plan
      ParentSubscriptionGroup? parentSubscription =
          await verifySubscriptionPackage();

      //PAYTM Transaction
      if (newPackagePrice > 0) {
        payTmResponse = await startPaymentTransaction();
      }

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
      //Save subscription
      setState(() {
        _isLoading = true;
      });
      if (newPackagePrice > 0) {
        saveSubscription(
            _subscriptionStatus,
            newPackagePrice > 0 ? 'paid' : 'free',
            double.parse(payTmResponse!.txnamount!),
            payTmResponse.txndate,
            payTmResponse.txnid,
            payTmResponse.orderid,
            payTmResponse.paymentmode,
            payTmResponse.checksumhash,
            payTmResponse.mid,
            parentSubscription);
      } else {
        saveSubscription(_subscriptionStatus, 'free', 0, DateTime.now(), null,
            null, null, null, null, parentSubscription);
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

  // for iOS
  void initiatePaymentIOS(
      double newPackagePrice, PurchaseDetails purchaseDetails) async {
    //TransactionResponse? payTmResponse;
    try {
      setState(() {
        _isLoading = true;
      });
      //Verify current plan
      ParentSubscriptionGroup? parentSubscription =
          await verifySubscriptionPackage();

      //PAYTM Transaction not needed
      /*if (newPackagePrice > 0) {
        payTmResponse = await startPaymentTransaction();
      }*/

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
      //Save subscription
      setState(() {
        _isLoading = true;
      });
      if (newPackagePrice > 0) {
        saveSubscription(
            _subscriptionStatus,
            newPackagePrice > 0 ? 'paid' : 'free',
            newPackagePrice,
            DateTime.now(),
            purchaseDetails.purchaseID,
            null,
            "Apple",
            null,
            null,
            parentSubscription);
      } else {
        saveSubscription(_subscriptionStatus, 'free', 0, DateTime.now(), null,
            null, null, null, null, parentSubscription);
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
    TextStyle _textViewStyle = kIsWeb || Platform.isAndroid
        ? AppTheme.lightTheme.textTheme.bodySmall!.copyWith(fontSize: 15)
        : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
            .copyWith(fontSize: 15, fontWeight: FontWeight.w500);
    return WillPopScope(
      onWillPop: () async {
        if (_isLoading == true) {
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
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
          title: 'Payment Gateway',
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
                                    : () async {
                                        if (Platform.isIOS) {
                                          late PurchaseParam purchaseParam;

                                          purchaseParam = PurchaseParam(
                                            productDetails: _products[0],
                                          );

                                          _inAppPurchase
                                              .buyConsumable(
                                                  purchaseParam: purchaseParam,
                                                  autoConsume: true)
                                              .onError(
                                                  (error, stackTrace) async {
                                            var paymentWrapper =
                                                SKPaymentQueueWrapper();
                                            var transactions =
                                                await paymentWrapper
                                                    .transactions();
                                            transactions
                                                .forEach((transaction) async {
                                              await paymentWrapper
                                                  .finishTransaction(
                                                      transaction);
                                            });
                                            return false;
                                          });
                                        } else {
                                          initiatePayment(double.parse(widget
                                              .subscriptionPackage.price
                                              .toString()));
                                        }
                                      },
                                color: AppTheme.primaryColor),
                          ],
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
/// Example implementation of the
/// [`SKPaymentQueueDelegate`](https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate?language=objc).
///
/// The payment queue delegate can be implementated to provide information
/// needed to complete transactions.
class PaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
