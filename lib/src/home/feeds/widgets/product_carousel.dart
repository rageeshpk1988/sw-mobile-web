import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../adaptive/adaptive_theme.dart';
import '../../../../webviews/webview_shop_web.dart';
import '/helpers/constants.dart';
import '/helpers/route_arguments.dart';
import '../../../../webviews/webview_shop.dart';
import '/src/login/screens/login_with_pass.dart';
import '/src/models/ad_response.dart';
import '/src/models/socialaccesstoken_response.dart';
import '/src/providers/auth.dart';

import '/src/models/firestore/productlist.dart';

import '../../../../util/ui_helpers.dart';

class ProductCarousel extends StatefulWidget {
  final List<Product>? productLists;
  ProductCarousel(this.productLists);

  @override
  State<ProductCarousel> createState() => _ProductCarouselState();
}

class _ProductCarouselState extends State<ProductCarousel> {
  void _loadProductPage(BuildContext context, Product product) {
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
      String productIdHandler = 'products/${product.productHandler}';
      String productUrl = adResponse == null
          ? '$SHOPIFY_URL${socialAdResponse!.token}$SHOPIFY_REDIRECT_URL$productIdHandler'
          : '$SHOPIFY_URL${adResponse.idToken}$SHOPIFY_REDIRECT_URL$productIdHandler';
      //var abc = Uri.encodeFull(productUrl);
      if(kIsWeb){
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewShopifyWeb(
                  initialUrl: Uri.encodeFull(productUrl),
                  updateHandler: () {}, // updateADData,
                  socialUpdateHandler: () {})), // updateSocialADData)),
        );
      }else{
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewShopify(
                  initialUrl: Uri.encodeFull(productUrl),
                  updateHandler: () {}, // updateADData,
                  socialUpdateHandler: () {})), // updateSocialADData)),
        );
      }


      //UrlLauncher.launchURL(productUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Widget _buildImageItem(Product product) {
      return Row(
        children: [
          Container(
            height: 70,
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey),
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                elevation: 10.0,
                child: ClipRect(
                  child: GestureDetector(
                    onTap: () {
                      _loadProductPage(context, product);
                    },
                    child: CachedNetworkImage(
                      imageUrl: appImageUrl(product.productImage!),
                      imageBuilder: (context, imageProvider) => Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.fill),
                        ),
                      ),
                      // placeholder: (context, url) =>
                      //     Center(child: AdaptiveCircularProgressIndicator()),
                      errorWidget: (context, url, error) => SizedBox(
                        width: 60,
                        height: 60,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported_outlined,
                                size: 40,
                                color: AdaptiveTheme.primaryColor(context)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),
        ],
      );
    }

    return SizedBox(
      width: size.width * 0.90,
      height: 60,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: widget.productLists!.length,
              itemBuilder: (BuildContext context, int i) {
                return _buildImageItem(widget.productLists![i]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
