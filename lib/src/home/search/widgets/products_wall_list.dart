import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/webviews/webview_shop_web.dart';
import '../../../../adaptive/adaptive_theme.dart';
import '../../../../helpers/constants.dart';
import '../../../../helpers/route_arguments.dart';
import '../../../../webviews/webview_shop.dart';
import '../../../../util/dialogs.dart';
import '../../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../../util/ui_helpers.dart';

import '../../../login/screens/login_with_pass.dart';
import '../../../models/ad_response.dart';

import '../../../models/socialaccesstoken_response.dart';
import '../../../providers/auth.dart';
import '/src/models/firestore/vendor_product.dart';

import '/src/providers/firestore_services.dart';

class ProductsWallList extends StatefulWidget {
  final int? vendorID;
  final String? searchString;
  final List<VendorProduct>? savedProductList;
  ProductsWallList({
    this.vendorID,
    this.searchString,
    this.savedProductList,
  });
  @override
  _ProductsWallListState createState() => _ProductsWallListState();
}

class _ProductsWallListState extends State<ProductsWallList> {
  bool _isAlreadyAdded(String handle) {
    VendorProduct emptyProduct = VendorProduct();
    if (widget.savedProductList!.length > 0) {
      VendorProduct? prod = widget.savedProductList!.firstWhere(
          (element) => element.handle == handle,
          orElse: () => emptyProduct);
      if (prod.handle != null) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  void _loadProductPage(BuildContext context, VendorProduct product) {
    String mobileNumber =
        Provider.of<Auth>(context, listen: false).loginResponse.mobileNumber;

    ADResponse? adResponse =
        Provider.of<Auth>(context, listen: false).adResponse;
    SocialAdResponse? socialAdResponse =
        Provider.of<Auth>(context, listen: false).socialAccessTokenResponse;

    if (adResponse == null && socialAdResponse == null) {
      Navigator.of(context).pushNamed(LoginWithPassword.routeName,
          arguments: LoginWithPasswordArgs(true, mobileNumber, () {}, () {},
              true)); // updateADData, updateSocialADData));
    }

    if (adResponse != null || socialAdResponse != null) {
      String productIdHandler = 'products/${product.handle}';
      String productUrl = adResponse == null
          ? '$SHOPIFY_URL${socialAdResponse!.token}$SHOPIFY_REDIRECT_URL$productIdHandler'
          : '$SHOPIFY_URL${adResponse.idToken}$SHOPIFY_REDIRECT_URL$productIdHandler';
      if (kIsWeb) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewShopifyWeb(
                  initialUrl: Uri.encodeFull(productUrl),
                  updateHandler: () {}, // updateADData,
                  socialUpdateHandler: () {})), // updateSocialADData)),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewShopify(
                  initialUrl: Uri.encodeFull(productUrl),
                  updateHandler: () {}, // updateADData,
                  socialUpdateHandler: () {})), // updateSocialADData)),
        );
      }
      //var abc = Uri.encodeFull(productUrl);

      //UrlLauncher.launchURL(productUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    //final deviceSize = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: StreamBuilder<QuerySnapshot>(
        stream: widget.vendorID == null
            ? FirestoreServices.getProductsWall(widget.searchString!)
            : FirestoreServices.getProductsofVendor(widget.vendorID!),
        builder: (context, prodsSnapshot) {
          if (prodsSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: AdaptiveCircularProgressIndicator());
          } else {
            if (prodsSnapshot.hasData) {
              final prods = prodsSnapshot.data!.docs;
              if (prods.isNotEmpty) {
                return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: prods.length,
                    itemBuilder: (context, index) {
                      //convert the feed object to local Object
                      DocumentSnapshot prod = prods[index];
                      VendorProduct? vendorProduct = VendorProduct.fromJson(
                          prod.data() as Map<String, dynamic>, prod);
                      //convert the feed object to local Object

                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 90,
                          alignment: Alignment.center,
                          child: Card(
                              semanticContainer: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 1.0,
                              child: ListTile(
                                visualDensity: VisualDensity(vertical: 4),
                                leading: GestureDetector(
                                  onTap: (() {
                                    if (widget.vendorID == null) {
                                      if (_isAlreadyAdded(
                                          vendorProduct.handle!)) {
                                        Dialogs().ackInfoAlert(context,
                                            'The Product has been tagged already...');
                                      } else {
                                        Navigator.of(context)
                                            .pop(vendorProduct);
                                      }
                                    } else {
                                      //Call Buy Now screen
                                      _loadProductPage(context, vendorProduct);
                                    }
                                  }),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: 30,
                                      minHeight: 30,
                                      maxWidth: 50,
                                      maxHeight: 50,
                                    ),
                                    child: vendorProduct.images!.isNotEmpty
                                        ? Image.network(
                                            vendorProduct.images![0].img_url!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, Object, error) {
                                              return Image.asset(
                                                "assets/icons/shopify.png",
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            "assets/icons/shopify.png",
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                title: Text(vendorProduct.title!,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize:
                                            textScale(context) <= 1.0 ? 14 : 12,
                                        fontWeight: FontWeight.w500)),
                                trailing: SizedBox(
                                  width: widget.vendorID == null ? 70 : 85,
                                  height: 26,
                                  child: appButton(
                                      context: context,
                                      width: 20,
                                      height: 20,
                                      titleFontSize:
                                          textScale(context) <= 1.0 ? 12 : 10,
                                      title: widget.vendorID == null
                                          ? 'Add'
                                          : 'Buy Now',
                                      titleColour:
                                          AdaptiveTheme.primaryColor(context),
                                      onPressed: () {
                                        if (widget.vendorID == null) {
                                          if (_isAlreadyAdded(
                                              vendorProduct.handle!)) {
                                            Dialogs().ackInfoAlert(context,
                                                'The Product has been tagged already...');
                                          } else {
                                            Navigator.of(context)
                                                .pop(vendorProduct);
                                          }
                                        } else {
                                          //Call Buy Now screen
                                          _loadProductPage(
                                              context, vendorProduct);
                                        }
                                      },
                                      borderColor:
                                          AdaptiveTheme.primaryColor(context),
                                      borderRadius: 20),
                                ),
                              )),
                        ),
                      );
                    });
              } else {
                return const SizedBox();
              }
            } else {
              return const SizedBox();
            }
          }
        },
      ),
    );
  }
}
