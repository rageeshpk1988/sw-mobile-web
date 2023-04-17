import 'dart:io';

import 'package:flutter/material.dart';
import '../../../src/models/subscription_package.dart';
import '../screens/payment_init.dart';
import '../screens/payment_init_new.dart';
import '/util/ui_helpers.dart';

class SubscriptionPackageDetails extends StatefulWidget {
  final SubscriptionPackage subscriptionPackage;
  final Function expandHandler;
  SubscriptionPackageDetails(
    this.subscriptionPackage,
    this.expandHandler,
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
              // image: DecorationImage(
              //   colorFilter: ColorFilter.mode(Colors.black12, BlendMode.color),
              //   image: AssetImage('assets/images/package_card.png'),
              //   fit: BoxFit.cover,
              // ),
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
                        color: hexToColor(widget.subscriptionPackage.colorCode),
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
                        style: TextStyle(
                            fontSize: textScale(context) <= 1.0 ? 14 : 11)),
                    trailing: Text(_subCategoryList[i].quantity.toString(),
                        style: TextStyle(
                            fontSize: textScale(context) <= 1.0 ? 14 : 11)),
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
                    titleColour:
                        hexToColor(widget.subscriptionPackage.colorCode),
                    onPressed: () {
                      if(Platform.isIOS)
                        {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentInitScreenNew(
                                subscriptionPackage: widget.subscriptionPackage,
                                isRenew: false,
                              ),
                            ),
                          );
                        }else{
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentInitScreen(
                              subscriptionPackage: widget.subscriptionPackage,
                              isRenew: false,
                            ),
                          ),
                        );
                      }

                    },
                    borderColor:
                        hexToColor(widget.subscriptionPackage.colorCode),
                    borderRadius: 20),
              ),
            ),
          ),
          //UNLOCK BUTTON
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
