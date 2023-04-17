import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '/src/models/login_response.dart';
import '/src/models/referral.dart';
import '/src/providers/referraldetail.dart';
import '/util/notify_user.dart';
import '/util/ui_helpers.dart';
import 'package:share_plus/share_plus.dart';

import '../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../adaptive/adaptive_theme.dart';
import '../../../helpers/route_arguments.dart';
import '../../../util/app_theme.dart';

import '../../../util/dialogs.dart';
import '../../../widgets/web_banner.dart';
import '../../../widgets/web_bottom_bar.dart';
import '../../providers/auth.dart';
import '../widgets/referral_detail_item.dart';

class ReferFriendWeb extends StatefulWidget {
  static String routeName = '/web-refer-friend';
  const ReferFriendWeb({Key? key}) : super(key: key);

  @override
  _ReferFriendWebState createState() => _ReferFriendWebState();
}

class _ReferFriendWebState extends State<ReferFriendWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSwitched = false;
  final _referralCodeController = TextEditingController();
  final _referralFocusNode = FocusNode();
  var _isInIt = true;
  var _isLoading = false;
  Referral? _referral;
  LoginResponse? _loginResponse;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      setState(() {
        _isLoading = true;
      });
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
      loadReferralData();
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _referralCodeController.dispose();
    _referralFocusNode.dispose();
    super.dispose();
  }

  void loadReferralData() async {
    await Provider.of<ReferralDetail>(context, listen: false)
        .fetchReferralCode(_loginResponse!.b2cParent!.parentID)
        .then((value) {
      setState(() {
        _referral = value;
        _referralCodeController.text = value!.referralCode!;
        _isLoading = false;
      });
    }).onError((error, stackTrace) {
      Dialogs().ackAlert(context, "Error", error.toString());
    });
  }

  void share() {
    final RenderBox box = context.findRenderObject() as RenderBox;
    String textToShare =
        "I'm inviting you to use SchoolWizard, a scientifically-driven technique that analyses and enhances a child's inherent capabilities. Here's my code (${_referral!.referralCode}) which you can enter during signing up for the application."
        '\n\n Download now from:'
        '\n\n App Store:'
        '\n\n https://apps.apple.com/in/app/schoolwizard/id1596416463'
        '\n\n Play Store:'
        '\n\n https://play.google.com/store/apps/details?id=com.zoftsolutions.schoolwizard';
    Share.share(textToShare,
        subject: 'SchoolWizard App.',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  @override
  Widget build(BuildContext context) {
    // final referralArgs =
    //     ModalRoute.of(context)?.settings.arguments as ReferralArgs?;
    TextStyle _textViewStyle = AppTheme.lightTheme.textTheme.bodySmall!
        .copyWith(fontSize: 13, fontWeight: FontWeight.w300);

    Widget _responsiveHeader() {
      List<Widget> _items = [
        Container(
          margin: const EdgeInsets.all(10.0),
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
              border: Border.all(color: AdaptiveTheme.primaryColor(context)),
              borderRadius: BorderRadius.circular(5.0)),
          height: 100,
          width: 150,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icons/download.png', width: 50, height: 50),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(_referral?.count != null ? "${_referral!.count}" : "0",
                        style: AppTheme.lightTheme.textTheme.bodySmall!
                            .copyWith(
                                fontSize: 21, fontWeight: FontWeight.w700)),
                    Text("Downloads",
                        style: AppTheme.lightTheme.textTheme.bodySmall!
                            .copyWith(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
              border: Border.all(color: AdaptiveTheme.primaryColor(context)),
              borderRadius: BorderRadius.circular(5.0)),
          height: 100,
          width: 150,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/subscribers.png',
                  width: 50,
                  height: 50,
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                        _referral?.subscribedCount != null
                            ? "${_referral!.subscribedCount}"
                            : "0",
                        style: AppTheme.lightTheme.textTheme.bodySmall!
                            .copyWith(
                                fontSize: 21, fontWeight: FontWeight.w700)),
                    Text("Subscribed",
                        style: AppTheme.lightTheme.textTheme.bodySmall!
                            .copyWith(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ];
      if (screenWidth(context) < 400) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _items[0],
            verticalSpaceTiny,
            _items[1],
          ],
        );
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _items[0],
            _items[1],
          ],
        );
      }
    }

    Widget _responsivebody() {
      List<Widget> _items = [
        SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(13)),
            width: screenWidth(context) < 400
                ? screenWidth(context) * 0.95
                : screenWidth(context) * 0.50,
            height: screenWidth(context) < 400
                ? screenHeight(context) * 0.9
                : screenHeight(context) * 0.6,
            child: Card(
              elevation: 5.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth(context) < 400
                              ? screenWidth(context) * 0.45
                              : screenWidth(context) * 0.30,
                          height: 26,
                          child: TextFormField(
                            style: _textViewStyle,
                            enabled: false,
                            controller: _referralCodeController,
                            textInputAction: TextInputAction.next,
                            decoration: AdaptiveTheme.textFormFieldDecoration(
                                context, '', _referralFocusNode),
                          ),
                        ),
                        horizontalSpaceTiny,
                        appButton(
                            context: context,
                            width: 72,
                            height: 21,
                            title: "Copy",
                            titleColour: AdaptiveTheme.primaryColor(context),
                            borderColor: AdaptiveTheme.primaryColor(context),
                            titleFontSize: 12,
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                      text: _referralCodeController.text))
                                  .then((value) {
                                NotifyUser().showSnackBar(
                                    "Code copied to clipboard", context);
                              });
                            })
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Details",
                      style: AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    verticalSpaceMedium,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: AppTheme.lightTheme.textTheme.bodyMedium!
                              .copyWith(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            "To get started, copy and share your application invite link anywhere via email, Facebook, Instagram, Twitter, WhatsApp, or SMS so they can download the SchoolWizard application from the Play Store or App Store.",
                            style: AppTheme.lightTheme.textTheme.bodyMedium!
                                .copyWith(
                                    fontSize: 14, fontWeight: FontWeight.w400),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                    verticalSpaceMedium,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: AppTheme.lightTheme.textTheme.bodyMedium!
                              .copyWith(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            "Furthermore, they can use the referral code to sign up directly through the SchoolWizard app or via their Google or Facebook accounts.",
                            style: AppTheme.lightTheme.textTheme.bodyMedium!
                                .copyWith(
                                    fontSize: 14, fontWeight: FontWeight.w400),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                    verticalSpaceMedium,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: AppTheme.lightTheme.textTheme.bodyMedium!
                              .copyWith(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            "When a referee (Friend) downloads the SchoolWizard app and subscribes to a package, a Xoxo link will be sent to the referrer. Upon creating an account in Xoxoday, the user will receive an Amazon voucher.",
                            style: AppTheme.lightTheme.textTheme.bodyMedium!
                                .copyWith(
                                    fontSize: 14, fontWeight: FontWeight.w400),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 30,
                          child: TextButton.icon(
                              label: Text('Refer friend now'),
                              onPressed: () {
                                share();
                              },
                              icon: Icon(Icons.arrow_right_alt_outlined)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          child: Container(
            padding: screenWidth(context) < 400
                ? EdgeInsets.fromLTRB(16.0, 0, 16.0, 0)
                : null,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(13)),
            width: screenWidth(context) < 400
                ? screenWidth(context) * 0.95
                : screenWidth(context) * 0.40,
            height: screenWidth(context) < 400
                ? screenHeight(context) * 0.9
                : screenHeight(context) * 0.6,
            child: Card(
              elevation: 5.0,
              child: ReferralsView(
                ReferralDetailArgs: ReferralDetailArgs(_referral!),
              ),
            ),
          ),
        )
      ];
      if (screenWidth(context) < 400) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _items[0],
            verticalSpaceTiny,
            _items[1],
          ],
        );
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _items[0],
            _items[1],
          ],
        );
      }
    }

    Widget _bodyWidget() {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                decoration: BoxDecoration(
                    color: Colors.grey.shade50, //  hexToColor("#FFF3F8"),
                    borderRadius: BorderRadius.circular(13)),
                height: screenWidth(context) < 400 ? 270 : 94,
                width: screenWidth(context) * 0.89,
                child: Center(child: _responsiveHeader()),
              ),
            ),
            const SizedBox(height: 30),
            _responsivebody()
          ],
        ),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      endDrawer: WebBannerDrawer(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            WebBanner(
              showMenu: true,
              showHomeButton: true,
              showProfileButton: true,
              scaffoldKey: scaffoldKey,
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: (screenWidth(context) > 800
                      ? 85
                      : screenWidth(context) > 400
                          ? 50
                          : 25),
                  top: 40),
              child: Row(
                children: [
                  Text(
                    'Refer a Friend',
                    style: TextStyle(
                        letterSpacing: 0.0,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: screenWidth(context) * 0.90,
              //height: screenHeight(context) * 0.98,
              child: _isLoading == false
                  ? _bodyWidget()
                  : Center(child: AdaptiveCircularProgressIndicator()),
            ),
            SizedBox(height: 10),
            WebBottomBar(),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class ReferralsView extends StatefulWidget {
  final ReferralDetailArgs;
  const ReferralsView({
    this.ReferralDetailArgs,
    Key? key,
  }) : super(key: key);

  @override
  _ReferralsViewState createState() => _ReferralsViewState();
}

class _ReferralsViewState extends State<ReferralsView> {
  var _isInIt = true;
  //var _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInIt) {}
    _isInIt = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final referralArgs = widget.ReferralDetailArgs;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  color: Colors.black,
                ),
                const SizedBox(width: 10),
                Text(
                  'Subscribed Parents (${referralArgs.referral.referralDetailDto!.length})',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                )
              ],
            ),
            referralArgs.referral.referralDetailDto!.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: Colors.grey,
                              size: 40,
                            ),
                            Text(
                              'No Data Found',
                              style: AppTheme.lightTheme.textTheme.bodyMedium!
                                  .copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount:
                            referralArgs.referral.referralDetailDto!.length,
                        itemBuilder: (context, index) {
                          //convert the followings object to local Object
                          ReferralDetailDto referralDetailDto =
                              referralArgs.referral.referralDetailDto![index];
                          //convert the followings object to local Object

                          return Column(
                            children: [
                              ReferralDetailViewItem(
                                referral: referralDetailDto,
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        }),
                  ),
          ],
        ),
      ),
    );
  }
}
