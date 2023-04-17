import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:loop_page_view/loop_page_view.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';
import 'package:provider/provider.dart';
import '../../../../src/home/feeds/screens/new_feeds.dart';
import '../../../../src/providers/firestore_services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../adaptive/adaptive_theme.dart';
import '../../../../helpers/connectivity_helper.dart';
import '../../../../helpers/constants.dart';
import '../../../../helpers/route_arguments.dart';
import '../../../../webviews/webview_shop.dart';

import '../../../../webviews/webview_shop_web.dart';
import '../../../invite_friend/screens/refer_friend.dart';
import '../../../models/firestore/adobj.dart';

import '../../../login/screens/login_with_pass.dart';
import '../../../models/ad_response.dart';
import '../../../models/firestore/vendor_from_ads.dart';
import '../../../models/socialaccesstoken_response.dart';
import '../../../providers/auth.dart';
import '../../../subscription/screens/subcriptionsPlans.dart';
import '../../../vendor_profile/screens/vendor_profile.dart';
import '../../child/screens/child_transformation.dart';

class AdCarousel extends StatefulWidget {
  final List<AdObj>? adObjs;
  AdCarousel(this.adObjs);

  @override
  State<AdCarousel> createState() => _AdCarouselState();
}

class _AdCarouselState extends State<AdCarousel> {
  final LoopPageController _pageController = LoopPageController(initialPage: 0);
  int _currentPage = 0;
  final ValueNotifier<int> _pageNotifier = ValueNotifier<int>(0);
  late Timer _timer;
  bool end = false;
  @override
  void initState() {
    super.initState();
    if (mounted)
      _timer = Timer.periodic(Duration(seconds: 6), (Timer timer) {
        _currentPage++;
        if (_pageController.hasClients)
          _pageController.animateJumpToPage(
            _currentPage,
            duration: Duration(milliseconds: 100),
            curve: Curves.bounceIn,
          );
      });
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

  @override
  void dispose() {
    _pageController.dispose();
    _pageNotifier.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Widget _buildImageItem(AdObj adObj) {
      return ClipRRect(
        //borderRadius: BorderRadius.circular(5.0),
        child: GestureDetector(
          onTap: () async {
            // var command = 'subscription-plan';
            switch (adObj.pageType) {
              case 'vendor':
                Map<String, dynamic>? result =
                    await FirestoreServices.getVendorProfileAd(adObj.vendorId!);
                if (result != null) {
                  AdVendorProfile profile = AdVendorProfile.fromJson(result);
                  if (profile.userName != null) {
                    if (await ConnectivityHelper.hasInternet<ProfileOthersArgs>(
                            context,
                            VendorProfileScreen.routeName,
                            ProfileOthersArgs(null, null, profile)) ==
                        true) {
                      Navigator.of(context).pushNamed(
                          VendorProfileScreen.routeName,
                          arguments: ProfileOthersArgs(null, null, profile));
                    }
                  }
                }

                break;
              case 'in-app':
                switch (adObj.inAppPage) {
                  case 'child-transformation':
                    if (await ConnectivityHelper.hasInternet(
                            context, NewFeedScreen.routeName, null) ==
                        true) {
                      Navigator.of(context)
                          .pushNamed(ChildTransformationScreen.routeName);
                    }
                    break;
                  case 'subscription-plan':
                    Navigator.of(context).pushNamed(
                      SubscriptionPlansScreen.routeName,
                    );
                    break;
                  case 'refer-a-friend':
                    Navigator.of(context).pushNamed(
                      ReferFriend.routeName,
                    );
                    break;
                  case 'parents-wall':
                    if (await ConnectivityHelper.hasInternet(
                            context, NewFeedScreen.routeName, null) ==
                        true) {
                      Navigator.of(context).pushNamed(NewFeedScreen.routeName);
                    }
                    break;
                  default:
                    null;
                }
                ;
                break;
              case 'product':
                _loadProductPage(context, adObj.productHandle!);
                break;
              case 'external':
                if (adObj.url != null) {
                  await launchUrl(Uri.parse(adObj.url!));
                  //await launch(adObj.url!);
                }
                break;
              default:
                null;
            }
          },
          child: CachedNetworkImage(
            imageUrl: adObj.imageUrl!,
            imageBuilder: (context, imageProvider) => Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                image: DecorationImage(image: imageProvider, fit: BoxFit.fill),
              ),
            ),
            // placeholder: (context, url) =>
            //     Center(child: AdaptiveCircularProgressIndicator()),
            errorWidget: (context, url, error) => SizedBox(
              width: 351,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported_outlined,
                      size: 100, color: AdaptiveTheme.primaryColor(context)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget _buildCarouselItem(AdObj adObj) {
      return Card(
        elevation: 0.0,
        child: Stack(
          // alignment: WrapAlignment.center,
          children: <Widget>[
            _buildImageItem(adObj),
            /*Positioned(
              right: 20,
              top: 25,
              child: Container(
                height: 18,
                width: 59,
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xffFF8C54),
                        borderRadius: BorderRadius.all(Radius.circular(4.0))),
                    child: new Center(
                      child: new Text(
                        "Ad",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    )),
              ),
            ),*/
            //if (fileObj.type == 'video') _buildVideoItem(fileObj),
            const SizedBox(height: 5),
          ],
        ),
      );
    }

    return SizedBox(
      width: size.width * 0.90,
      height: 150,
      child: Stack(
        //mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: LoopPageView.builder(
                  allowImplicitScrolling: false,
                  physics: widget.adObjs!.length > 1
                      ? AlwaysScrollableScrollPhysics()
                      : NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  controller: _pageController,
                  itemCount: widget.adObjs!.length,
                  itemBuilder: (BuildContext context, int i) {
                    return _buildCarouselItem(widget.adObjs![i]);
                  },
                  onPageChanged: (index) {
                    setState(() {
                      _pageNotifier.value = index;
                      _currentPage = index;
                    });
                  },
                ),
              ),
            ],
          ),
          if (widget.adObjs!.length > 1)
            Positioned(
              child: Align(
                alignment: Alignment(0, 0.9),
                child: CirclePageIndicator(
                  selectedBorderColor: Colors.white,
                  borderColor: Colors.white,
                  borderWidth: 3,
                  size: 8,
                  selectedSize: 8,
                  dotColor: Colors.white,
                  selectedDotColor: AdaptiveTheme.primaryColor(context),
                  // borderColor: Colors.black,
                  // selectedBorderColor: Colors.purple,
                  currentPageNotifier: _pageNotifier,
                  itemCount: widget.adObjs!.length,
                ),
              ),
            )
        ],
      ),
    );
  }
}
