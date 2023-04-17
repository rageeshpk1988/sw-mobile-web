import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/webviews/webview_shop_web.dart';
import '../../../../helpers/constants.dart';
import '../../../../helpers/route_arguments.dart';
import '../../../../webviews/webview_shop.dart';
import '../../../../src/providers/shopify_products.dart';

import '../../../../adaptive/adaptive_custom_appbar.dart';
import '../../../../adaptive/adaptive_theme.dart';
import '../../../../widgets/rounded_button.dart';
import '../../../login/screens/login_with_pass.dart';
import '../../../models/ad_response.dart';
import '../../../models/socialaccesstoken_response.dart';
import '../../../providers/auth.dart';

class ProductTilesScreen extends StatelessWidget {
  static String routeName = '/product-tiles';

  @override
  Widget build(BuildContext context) {
    List<ShopifyProduct> productList =
        ModalRoute.of(context)!.settings.arguments as List<ShopifyProduct>;
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
        title: 'New Products & Services',
        showMascot: true,
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: const EdgeInsets.all(10.0),
                itemCount: productList.length,
                itemBuilder: (ctx, i) => ProductItem(productList[i]),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1 / 1,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    mainAxisExtent: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//this is for grid items
class ProductItem extends StatelessWidget {
  final ShopifyProduct product;
  ProductItem(this.product);
  final dummyImage = 'assets/icons/shopify.png';

  void _loadProductPage(BuildContext context, String product) {
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
      String productIdHandler = 'products/${product}';
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

      //UrlLauncher.launchURL(productUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 150,
      child: Wrap(
        alignment: WrapAlignment.center,
        children: <Widget>[
          ClipRRect(
            child: GestureDetector(
              onTap: () {
                //_cardNavigate(context, hospital);
              },
              child: CachedNetworkImage(
                  imageUrl: product.image ?? "",
                  imageBuilder: (context, imageProvider) => Container(
                        width: 130,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                  placeholder: (context, url) => Center(
                        child: Image.asset(
                          dummyImage,
                          width: 130,
                          height: 120,
                        ),
                      ),
                  errorWidget: (context, url, error) => Image.asset(
                        dummyImage,
                        width: 130,
                        height: 120,
                      )),
            ),
          ),
          // SizedBox(height: 30),
          Column(
            children: [
              const SizedBox(height: 20),
              Text(product.title!,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis),
              SizedBox(
                width: 150,
                child: RoundButton(
                    color: AdaptiveTheme.secondaryColor(context),
                    title: 'Buy Now',
                    onPressed: () {
                      _loadProductPage(context, product.handle!);
                    }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
