import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/src/home/child/screens/child_transformation_web.dart';
import '/src/home/landing/widgets/home_page_parents_list_web.dart';
import '/src/home/landing/widgets/home_page_products_list_web.dart';

import '../../../../webviews/webview_support_web.dart';

import '../../feeds/screens/new_feeds_web.dart';
import '/util/dialogs.dart';
import '../../../../helpers/global_variables.dart';
import '../../../../webviews/webview_support.dart';

import '../../../../src/models/b2cparent.dart';
import '../../../../src/models/login_response.dart';
import '../../../../src/providers/auth.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../src/providers/home_static_data.dart';

import '../../../../helpers/connectivity_helper.dart';
import '../../../../helpers/shared_pref_data.dart';
import '../../../../util/marquee_widget.dart';
import '../../../../util/shopify_utils.dart';
import '../../../../util/ui_helpers.dart';

import '../../../models/ad_response.dart';
import '../../../models/firestore/adobj.dart';
import '../../../models/quote_response.dart';

import '../../../models/socialaccesstoken_response.dart';
import '../../../providers/firestore_services.dart';

import '../widgets/ad_carousel.dart';

class HomePageWeb extends StatefulWidget {
  static String routeName = '/web-homepage';
  @override
  _HomePageWebState createState() => _HomePageWebState();
}

class _HomePageWebState extends State<HomePageWeb> {
  QuoteResponse? quoteResponse;
  bool isSwitched = false;
  Future? quoteLoader;
  String? quote;
  String? author;
  var _isInIt = true;
  List<B2CParent>? parentList = [];
  List<AdObj> loadedAds = [];
  late LoginResponse loginResponse;
  ADResponse? _adResponse;
  SocialAdResponse? _socialAccessTokenResponse;
  int? kycStatus;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    loginResponse = Provider.of<Auth>(context, listen: true).loginResponse;
    //getAdd();

    if (_isInIt) {
      //setState(() {});
      _adResponse = Provider.of<Auth>(context, listen: false).adResponse;
      _socialAccessTokenResponse =
          Provider.of<Auth>(context, listen: false).socialAccessTokenResponse;
      loginResponse = Provider.of<Auth>(context, listen: true).loginResponse;
      // kycStatus = Provider.of<Auth>(context, listen: true).kycResponse;
      //quoteLoader = getQuote();

      Provider.of<HomeStaticData>(context, listen: false)
          .getDailyQuote()
          .then((value) {
        setState(() {
          quoteResponse = value;
          if (quoteResponse?.message == 'Success') {
            //print('quote string: ${quoteResponse?.data?.quote}');
            quote = quoteResponse?.data?.quote;
            author = quoteResponse?.data?.author;
          }
          getAdd();
          _isInIt = false;
        });
      });

      //  if (kycStatus != 1) updateKycStatus();
      // Provider.of<HomeStaticDataNew>(context, listen: false)
      //     .fetchAndSetSuggestedParentList(
      //         loginResponse.b2cParent!.parentID, loginResponse.token)
      //     .then((value) {
      //   parentList = Provider.of<HomeStaticDataNew>(context, listen: true)
      //       .suggestedParents;
      //   setState(() {});
      // });
    }

    super.didChangeDependencies();
  }

  void updateADData() async {
    setState(() async {
      _adResponse = await SharedPrefData.getUserADDataPref();
    });
  }

  void updateSocialADData() async {
    setState(() async {
      _socialAccessTokenResponse =
          await SharedPrefData.getUserSocialADDataPref();
    });
  }

  /*void updateKycStatus() async {
    var resultsLoaded = await Provider.of<Auth>(context, listen: false)
        .getApproveStatusKyc(loginResponse.b2cParent!.parentID);
    print("updating kycstatus");
    int? status = await SharedPrefData.getUserKycStatus();
    setState(() {
      kycStatus = status;
    });
  }*/

  getAdd() async {
    var result = await FirestoreServices.getAds();
    setState(() {
      loadedAds = result;
    });
  }

  getQuote() async {
    quoteResponse = await Provider.of<HomeStaticData>(context, listen: false)
        .getDailyQuote();
    if (quoteResponse?.message == 'Success') {
      //print('quote string: ${quoteResponse?.data?.quote}');
      quote = quoteResponse?.data?.quote;
      author = quoteResponse?.data?.author;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    kycStatus = Provider.of<Auth>(context, listen: true).kycResponse;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          //mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            //USER NAME
            Padding(
              padding: const EdgeInsets.fromLTRB(35.0, 8.0, 8.0, 8.0),
              child: Text(
                'Hi ${loginResponse.b2cParent!.name}',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            //USER NAME
            //QUOTE
            Center(
              child: Container(
                width: double.infinity,
                color: Color.fromARGB(120, 252, 232, 240),
                child: Stack(
                  children: [
                    Positioned(
                        left: 15,
                        top: 15,
                        child: Image.asset('assets/images/lg_qt.png')),
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          height: 50,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 36, right: 36),
                            child: MarqueeWidget(
                              direction: Axis.vertical,
                              //animationDuration: Duration(seconds:6),
                              pauseDuration: Duration(seconds: 1),
                              child: quote != null
                                  ? Center(
                                      child: Text(
                                        "\"$quote\"",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.cormorantGaramond(
                                          textStyle: TextStyle(
                                              fontSize: 18,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        "\"Children are like wet cement whatever falls on them makes an impression.\"",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.cormorantGaramond(
                                          textStyle: TextStyle(
                                              fontSize: 18,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        verticalSpaceSmall,
                        Padding(
                          padding: const EdgeInsets.only(left: 36, right: 36),
                          child: author != null
                              ? Text(
                                  "-$author-",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cormorantGaramond(
                                    textStyle: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic),
                                  ),
                                )
                              : Text(
                                  "-Cassandra Clifford-",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cormorantGaramond(
                                    textStyle: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                        ),
                        verticalSpaceSmall,
                        // Image.asset('assets/icons/quote2.png'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            //QUOTE
            //SELECTION GRID
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
              child: SelectionGrid(
                  adResponse: _adResponse,
                  socialAccessTokenResponse: _socialAccessTokenResponse,
                  updateHandler: updateADData,
                  socialUpdateHandler: updateSocialADData),
            ),
            //SELECTION GRID
            //AD CONTAINER
            //if (_isLoading == false)
            if (loadedAds.length > 0)
              Container(
                child: Center(
                  child: Container(
                    width: screenWidth(context) * 0.40,
                    height: screenHeight(context) * 0.20,
                    child: AdCarousel(loadedAds),
                  ),
                ),
              ),
            //AD CONTAINER
            //PARENTS
            // if (mounted)
            HomePageParentsListWeb(),
            //PARENTS
            //PRODUCTS
            HomePageProductsListWeb(), //product list to be passed
            //PRODUCTS
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class SelectionGrid extends StatelessWidget {
  final ADResponse? adResponse;
  final SocialAdResponse? socialAccessTokenResponse;
  final Function? updateHandler;
  final Function? socialUpdateHandler;
  const SelectionGrid(
      {Key? key,
      @required this.adResponse,
      @required this.socialAccessTokenResponse,
      @required this.updateHandler,
      @required this.socialUpdateHandler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> categories = [];
    categories.add("1");
    categories.add("2");
    categories.add("3");
    categories.add("4");
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GridView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        // padding: const EdgeInsets.all(10.0),
        children: categories
            .map(
              (category) => GestureDetector(
                onTap: () {},
                child: SelectionGridItem(
                  category: category,
                  adResponse: adResponse,
                  socialAccessTokenResponse: socialAccessTokenResponse,
                  socialUpdateHandler: socialUpdateHandler,
                  updateHandler: updateHandler,
                ),
              ),
            )
            .toList(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: (200.0 / 200.0),
          crossAxisCount: (screenWidth(context) > 800 ? 4 : 2),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: (screenWidth(context) > 800 ? 250 : 200),
        ),
      ),
    );
  }
}

class SelectionGridItem extends StatefulWidget {
  final ADResponse? adResponse;
  final SocialAdResponse? socialAccessTokenResponse;
  final Function? updateHandler;
  final Function? socialUpdateHandler;
  final String category;
  const SelectionGridItem({
    Key? key,
    required this.category,
    @required this.adResponse,
    @required this.socialAccessTokenResponse,
    @required this.updateHandler,
    @required this.socialUpdateHandler,
  }) : super(key: key);

  static AutoSizeGroup titleGrp = AutoSizeGroup();

  @override
  State<SelectionGridItem> createState() => _SelectionGridItemState();
}

class _SelectionGridItemState extends State<SelectionGridItem> {
  late AssetImage imagePath;
  String infoText = '';
  bool _isPressed = false;
  @override
  void initState() {
    //print('initstate');
    super.initState();
    if (widget.category == '1') {
      imagePath = AssetImage('assets/images/ICON_01_LOOP.gif');
      //imagePath = AssetImage('assets/images/ICON_01-min.gif');
      infoText = "See Your Child's Transformation";
    } else if (widget.category == '2') {
      imagePath = AssetImage('assets/images/ICON_02_LOOP.gif');
      //imagePath = AssetImage('assets/images/ICON_03-min.gif');
      infoText = "Parents' Wall";
    } else if (widget.category == '3') {
      imagePath = AssetImage('assets/images/ICON_03_LOOP.gif');
      //imagePath = AssetImage('assets/images/ICON_02-min.gif');

      infoText = "Products & Services";
    } else {
      imagePath = AssetImage('assets/images/ICON_04_LOOP.gif');
      //imagePath = AssetImage('assets/images/ICON_04-min.gif');
      infoText = "Help & Support";
    }
  }

  @override
  void dispose() {
    //print('dispose');
    imagePath.evict();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LoginResponse _loginResponse =
        Provider.of<Auth>(context, listen: false).loginResponse;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      elevation: 10.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _isPressed
                  ? null
                  : () async {
                      setState(() {
                        _isPressed = true;
                      });
                      switch (widget.category) {
                        case '1':
                          Provider.of<Auth>(context, listen: false)
                              .setInitialChild();
                          if (await ConnectivityHelper.hasInternet(
                                  context,
                                  ChildTransformationScreenWeb.routeName,
                                  null) ==
                              true) {
                            if (_loginResponse.b2cParent!.childDetails!.length <
                                1) {
                              Dialogs()
                                  .noChildPopup(context, null, isWeb: true);
                            } else {
                              Navigator.of(context).pushNamed(
                                ChildTransformationScreenWeb.routeName,
                              );
                            }
                          }
                          break;
                        case '2':
                          if (await ConnectivityHelper.hasInternet(
                                  context, NewFeedScreenWeb.routeName, null) ==
                              true) {
                            Navigator.of(context)
                                .pushNamed(NewFeedScreenWeb.routeName);
                          }
                          break;
                        case '3':
                          var _adResponse =
                              Provider.of<Auth>(context, listen: false)
                                  .adResponse;
                          var _socialAccessTokenResponse =
                              Provider.of<Auth>(context, listen: false)
                                  .socialAccessTokenResponse;
                          ShopifyUtils.launchShopifyCart(
                              context,
                              _adResponse,
                              widget.updateHandler!,
                              widget.socialUpdateHandler!,
                              _socialAccessTokenResponse,
                              web: true);

                          break;
                        case '4':
                          if (kIsWeb) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WebViewSupportWeb(
                                        initialUrl:
                                            GlobalVariables.supportPageUrl,
                                      )),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WebViewSupport(
                                        initialUrl:
                                            GlobalVariables.supportPageUrl,
                                      )),
                            );
                          }

                          break;
                        default:
                      }
                      setState(() {
                        _isPressed = false;
                      });
                    },
              child: Image(
                image: imagePath,
                height: 120,
              ),
            ),
          ),
          const SizedBox(height: 8),
          LimitedBox(
            maxHeight: 100,
            child: AutoSizeText(infoText,
                textAlign: TextAlign.center,
                style: TextStyle(
                    letterSpacing: 0.0,
                    fontSize: screenWidth(context) > 400 ? 16 : 12,
                    fontFamily: "Montserrat",
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
                maxFontSize: screenWidth(context) > 400 ? 16 : 12,
                maxLines: 2,
                minFontSize: screenWidth(context) > 400 ? 13 : 10,
                stepGranularity: 1,
                group: SelectionGridItem.titleGrp),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
