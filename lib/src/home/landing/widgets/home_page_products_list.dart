import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/webviews/webview_shop_web.dart';
import '../../../../helpers/constants.dart';
import '../../../../helpers/route_arguments.dart';
import '../../../../webviews/webview_shop.dart';
import '../../../../src/home/landing/screens/product_tiles_screen.dart';

import '../../../../src/providers/shopify_products.dart';

import '../../../../adaptive/adaptive_theme.dart';
import '../../../../widgets/rounded_button.dart';
import '../../../login/screens/login_with_pass.dart';
import '../../../models/ad_response.dart';
import '../../../models/socialaccesstoken_response.dart';
import '../../../providers/auth.dart';

class HomePageProductsList extends StatefulWidget {
  @override
  State<HomePageProductsList> createState() => _HomePageProductsListState();
}

class _HomePageProductsListState extends State<HomePageProductsList> {
  var _isInIt = true;
  var _isLoading = false;
  List<ShopifyProduct> _productList = [];
  var dummyImage = 'assets/icons/shopify.png';
  @override
  void didChangeDependencies() {
    if (_isInIt) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ShopifyProducts>(context, listen: false)
          .fetchAndSetShopifyProducts()
          .then((_) {
        setState(() {
          _isLoading = false;
          _productList = Provider.of<ShopifyProducts>(context, listen: false)
              .shopifyProducts;
        });
      });
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

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

  Widget _buildCard(BuildContext context, ShopifyProduct product) {
    return Container(
      width: 180,
      child: Card(
        elevation: 1.0,
        child: Wrap(
          alignment: WrapAlignment.center,
          children: <Widget>[
            if (product.image != null)
              ClipRRect(
                child: GestureDetector(
                  onTap: () {
                    //card navigation to go here
                  },
                  child: CachedNetworkImage(
                      imageUrl: product.image!,
                      imageBuilder: (context, imageProvider) => Container(
                            width: 130,
                            height: 150,
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
                              width: 140,
                              height: 160,
                            ),
                          ),
                      errorWidget: (context, url, error) => Image.asset(
                            dummyImage,
                            width: 140,
                            height: 160,
                          )),
                ),
              ),
            // SizedBox(height: 30),
            if (product.image == null)
              Center(
                child: Image.asset(
                  dummyImage,
                  width: 110,
                  height: 130,
                ),
              ),
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
      ),
    );
  }

  Widget _rowHeading(BuildContext context, String heading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            heading,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black),
            textAlign: TextAlign.left,
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.arrow_forward_outlined),
            iconSize: 25,
            color: AdaptiveTheme.secondaryColor(context),
            onPressed: () {
              Navigator.of(context).pushNamed(ProductTilesScreen.routeName,
                  arguments: _productList);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int maxItmes = 5;

    if (_productList.length < maxItmes) {
      maxItmes = _productList.length;
    }
    return _productList.length < 1
        ? const SizedBox()
        : Column(
            children: [
              _rowHeading(context, 'New Products & Services'),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: maxItmes + 1,
                  itemBuilder: (BuildContext context, int i) {
                    if (i == maxItmes) {
                      return const SizedBox();
                    } else {
                      return _buildCard(context, _productList[i]);
                    }
                  },
                ),
              ),
            ],
          );
  }
}
