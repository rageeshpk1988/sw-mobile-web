import 'dart:io';

import 'package:flutter/material.dart';
import '../../../src/subscription/widgets/subscription_package_details.dart';

import '../screens/payment_init.dart';
import '../screens/payment_init_new.dart';
import '/src/models/subscription_package.dart';
import '/util/ui_helpers.dart';

class SubscriptionPackageItem extends StatefulWidget {
  final SubscriptionPackage subscriptionPackage;
  SubscriptionPackageItem(
    this.subscriptionPackage,
  );
  @override
  _SubscriptionPackageItemState createState() =>
      _SubscriptionPackageItemState();
}

class _SubscriptionPackageItemState extends State<SubscriptionPackageItem> {
  var _expanded = false;

  void expandAndCollapse() {
    setState(() {
      _expanded = !_expanded;
    });
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
                            color: hexToColor(
                                widget.subscriptionPackage.colorCode),
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
                            color: hexToColor(
                                widget.subscriptionPackage.colorCode),
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                      ),
                    ),
                  ),
                  //VALIDITY
                  const SizedBox(height: 20),
                  //UNLOCK BUTTON
                  Container(
                    width: double.infinity,
                    height: 55,
                    color: Colors.grey.shade50,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: 180,
                        child: appButton(
                            context: context,
                            width: double.infinity,
                            height: 40,
                            titleFontSize: textScale(context) <= 1.0 ? 16 : 11,
                            title: 'Unlock the Plan',
                            titleColour: hexToColor(
                                widget.subscriptionPackage.colorCode),
                            onPressed: () {
                              if(Platform.isIOS){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentInitScreenNew(
                                      subscriptionPackage:
                                      widget.subscriptionPackage,
                                      isRenew: false,
                                    ),
                                  ),
                                );
                              }else{
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentInitScreen(
                                      subscriptionPackage:
                                      widget.subscriptionPackage,
                                      isRenew: false,
                                    ),
                                  ),
                                );
                              }

                            },
                            borderColor: hexToColor(
                                widget.subscriptionPackage.colorCode),
                            borderRadius: 20),
                      ),
                    ),
                  ),
                  //UNLOCK BUTTON
                  //SizedBox(height: 10),

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
            SubscriptionPackageDetails(
                widget.subscriptionPackage, expandAndCollapse)
        ],
      ),
    );
  }
}
