import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../helpers/constants.dart';
import '../../../../helpers/route_arguments.dart';
import '../../../../webviews/webview_shop.dart';

import '../../../../src/providers/shopify_products.dart';

import '../../../../adaptive/adaptive_theme.dart';
import '../../../../webviews/webview_shop_web.dart';
import '../../../../widgets/rounded_button.dart';

import '../../../login/screens/login_with_pass_web.dart';
import '../../../models/ad_response.dart';
import '../../../models/socialaccesstoken_response.dart';
import '../../../providers/auth.dart';

class HomePageProductsListWeb extends StatefulWidget {
  @override
  State<HomePageProductsListWeb> createState() =>
      _HomePageProductsListWebState();
}

class _HomePageProductsListWebState extends State<HomePageProductsListWeb> {
  var _isInIt = true;
  var _isLoading = false;
  List<ShopifyProduct> _productList = [];
  var dummyImage = 'assets/icons/shopify.png';
  final _listController = ScrollController();

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

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
      _isInIt = false;
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  void _loadProductPage(BuildContext context, String product) {
    String mobileNumber =
        Provider.of<Auth>(context, listen: false).loginResponse.mobileNumber;

    ADResponse? adResponse =
        Provider.of<Auth>(context, listen: false).adResponse;
    SocialAdResponse? socialAdResponse =
        Provider.of<Auth>(context, listen: false).socialAccessTokenResponse;

    if (adResponse == null && socialAdResponse == null) {
      Navigator.of(context).pushNamed(LoginWithPasswordWeb.routeName,
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
      width: 160,
      child: Card(
        elevation: 2.0,
        child: Column(
          // alignment: WrapAlignment.center,
          children: <Widget>[
            const SizedBox(height: 10),
            if (product.image != null)
              ClipRRect(
                child: GestureDetector(
                  onTap: () {
                    //card navigation to go here
                  },
                  child: CachedNetworkImage(
                      imageUrl: product.image!,
                      imageBuilder: (context, imageProvider) => Container(
                            width: 110,
                            height: 130,
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
                              width: 110,
                              height: 130,
                            ),
                          ),
                      errorWidget: (context, url, error) => Image.asset(
                            dummyImage,
                            width: 110,
                            height: 130,
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
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
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
                      overflow: TextOverflow.clip),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 100,
                    child: RoundButton(
                        color: AdaptiveTheme.secondaryColor(context),
                        title: 'Buy Now',
                        onPressed: () {
                          _loadProductPage(context, product.handle!);
                        }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowHeading(BuildContext context, String heading) {
    return Padding(
      padding: EdgeInsets.only(left: 8.0, right: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            heading,
            style: TextStyle(
                letterSpacing: 0.0,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black),
            textAlign: TextAlign.left,
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                if (_listController.offset > 0) {
                  _listController.animateTo(_listController.offset - 300,
                      duration: Duration(milliseconds: 1000),
                      curve: Curves.fastOutSlowIn);
                }
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(5.0),
                shape: BoxShape.rectangle,
              ),
              child: Icon(Icons.arrow_back_outlined,
                  size: 20, color: AdaptiveTheme.secondaryColor(context)),
            ),
          ),
          const SizedBox(width: 3),
          GestureDetector(
            onTap: () {
              setState(() {
                _listController.animateTo(_listController.offset + 300,
                    duration: Duration(milliseconds: 1000),
                    curve: Curves.fastOutSlowIn);
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(5.0),
                shape: BoxShape.rectangle,
              ),
              child: Icon(Icons.arrow_forward_outlined,
                  size: 20, color: AdaptiveTheme.secondaryColor(context)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int maxItems = 0;

    maxItems = _productList.length;

    return _productList.length < 1
        ? const SizedBox()
        : Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Column(
              children: [
                _rowHeading(context, 'New Products & Services'),
                const SizedBox(height: 5),
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    controller: _listController,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: 100, //_productList.length,
                    itemBuilder: (BuildContext context, int i) {
                      if (i >= maxItems) {
                        return _buildCard(context, _productList[2]);
                      } else {
                        return _buildCard(context, _productList[i]);
                      }
                    },
                  ),
                ),
              ],
            ),
          );
  }
}
