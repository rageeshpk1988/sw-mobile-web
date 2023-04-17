import 'dart:io';
import 'package:flutter/foundation.dart';
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

import '../../../../adaptive/adaptive_custom_appbar.dart';
import '../../../util/app_theme_cupertino.dart';
import '../../../util/dialogs.dart';
import '../../providers/auth.dart';
import 'refer_friend_detail.dart';

class ReferFriend extends StatefulWidget {
  static String routeName = '/refer-friend';
  const ReferFriend({Key? key}) : super(key: key);

  @override
  _ReferFriendState createState() => _ReferFriendState();
}

class _ReferFriendState extends State<ReferFriend> {
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
    final referralArgs =
        ModalRoute.of(context)?.settings.arguments as ReferralArgs?;
    TextStyle _textViewStyle = kIsWeb || Platform.isAndroid
        ? AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontSize: 13, fontWeight: FontWeight.w300)
        : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
            .copyWith(fontSize: 13, fontWeight: FontWeight.w300);
    return Scaffold(
        appBar: AdaptiveCustomAppBar(
          title: 'Refer a Friend',
          showMascot: true,
          showShopifyHomeButton: false,
          showShopifyCartButton: false,
          showKycButton: false,
          showProfileButton: false,
          showHamburger: false,
          scaffoldKey: null,
          adResponse: null,
          loginResponse: null,
          updateHandler: null,
          disableBackButton:
              referralArgs?.showBackButton == null ? true : false,
        ),
        // appBar: AppBar(
        //   title: Image.asset('assets/images/sw_appbar_logo.png', height: 25),
        //   centerTitle: false,
        // ),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading == false
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                      decoration: BoxDecoration(
                          color: hexToColor("#FFF3F8"),
                          borderRadius: BorderRadius.circular(13)),
                      height: 94,
                      width: double.infinity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/referral_friend_mob.png",
                            height: 40,
                            width: 40,
                          ),
                          Spacer(),
                          SizedBox(
                            height: 100,
                            width: 100,
                            child: Card(
                              margin: EdgeInsets.all(8.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        _referral?.count != null
                                            ? "${_referral!.count}"
                                            : "0",
                                        style: kIsWeb || Platform.isAndroid
                                            ? AppTheme
                                                .lightTheme.textTheme.bodySmall!
                                                .copyWith(
                                                    fontSize: 21,
                                                    fontWeight: FontWeight.w700)
                                            : AppThemeCupertino.lightTheme
                                                .textTheme.navTitleTextStyle
                                                .copyWith(
                                                    fontSize: 21,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                    Text("Downloads",
                                        style: kIsWeb || Platform.isAndroid
                                            ? AppTheme
                                                .lightTheme.textTheme.bodySmall!
                                                .copyWith(fontSize: 10)
                                            : AppThemeCupertino.lightTheme
                                                .textTheme.navTitleTextStyle
                                                .copyWith(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w300)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            height: 100,
                            width: 100,
                            child: Card(
                              margin: EdgeInsets.all(8.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        _referral?.subscribedCount != null
                                            ? "${_referral!.subscribedCount}"
                                            : "0",
                                        style: kIsWeb || Platform.isAndroid
                                            ? AppTheme
                                                .lightTheme.textTheme.bodySmall!
                                                .copyWith(
                                                    fontSize: 21,
                                                    fontWeight: FontWeight.w700)
                                            : AppThemeCupertino.lightTheme
                                                .textTheme.navTitleTextStyle
                                                .copyWith(
                                                    fontSize: 21,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                    Text("Subscribed",
                                        style: kIsWeb || Platform.isAndroid
                                            ? AppTheme
                                                .lightTheme.textTheme.bodySmall!
                                                .copyWith(fontSize: 10)
                                            : AppThemeCupertino.lightTheme
                                                .textTheme.navTitleTextStyle
                                                .copyWith(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w300)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          _referral!.referralDetailDto!.isNotEmpty
                              ? GestureDetector(
                                  onTap: _referral!
                                          .referralDetailDto!.isNotEmpty
                                      ? () {
                                          Navigator.of(context).pushNamed(
                                              ReferralDetailScreen.routeName,
                                              arguments: ReferralDetailArgs(
                                                  _referral!));
                                        }
                                      : null,
                                  child: CircleAvatar(
                                    backgroundColor:
                                        HexColor.fromHex("#FFE5EA"),
                                    child: Icon(
                                      Icons.arrow_forward,
                                      color: HexColor.fromHex("#FF6F95"),
                                    ),
                                  ))
                              : SizedBox(width: 30),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 250,
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
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Details",
                      style: kIsWeb || Platform.isAndroid
                          ? AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            )
                          : AppThemeCupertino
                              .lightTheme.textTheme.navTitleTextStyle
                              .copyWith(
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
                          style: kIsWeb || Platform.isAndroid
                              ? AppTheme.lightTheme.textTheme.bodyMedium!
                                  .copyWith(
                                      fontSize: 12, fontWeight: FontWeight.w300)
                              : AppThemeCupertino
                                  .lightTheme.textTheme.navTitleTextStyle
                                  .copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            "To get started, copy and share your application invite link anywhere via email, Facebook, Instagram, Twitter, WhatsApp, or SMS so they can download the SchoolWizard application from the Play Store or App Store.",
                            style: kIsWeb || Platform.isAndroid
                                ? AppTheme.lightTheme.textTheme.bodyMedium!
                                    .copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300)
                                : AppThemeCupertino
                                    .lightTheme.textTheme.navTitleTextStyle
                                    .copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300),
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
                          style: kIsWeb || Platform.isAndroid
                              ? AppTheme.lightTheme.textTheme.bodyMedium!
                                  .copyWith(
                                      fontSize: 12, fontWeight: FontWeight.w300)
                              : AppThemeCupertino
                                  .lightTheme.textTheme.navTitleTextStyle
                                  .copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            "Furthermore, they can use the referral code to sign up directly through the SchoolWizard app or via their Google or Facebook accounts.",
                            style: kIsWeb || Platform.isAndroid
                                ? AppTheme.lightTheme.textTheme.bodyMedium!
                                    .copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300)
                                : AppThemeCupertino
                                    .lightTheme.textTheme.navTitleTextStyle
                                    .copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300),
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
                          style: kIsWeb || Platform.isAndroid
                              ? AppTheme.lightTheme.textTheme.bodyMedium!
                                  .copyWith(
                                      fontSize: 12, fontWeight: FontWeight.w300)
                              : AppThemeCupertino
                                  .lightTheme.textTheme.navTitleTextStyle
                                  .copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            "When a referee (Friend) downloads the SchoolWizard app and subscribes to a package, a Xoxo link will be sent to the referrer. Upon creating an account in Xoxoday, the user will receive an Amazon voucher.",
                            style: kIsWeb || Platform.isAndroid
                                ? AppTheme.lightTheme.textTheme.bodyMedium!
                                    .copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300)
                                : AppThemeCupertino
                                    .lightTheme.textTheme.navTitleTextStyle
                                    .copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: appButton(
                        context: context,
                        width: 20,
                        height: 20,
                        title: 'Refer friend now',
                        titleFontSize: 16,
                        titleColour: AdaptiveTheme.primaryColor(context),
                        onPressed: () {
                          share();
                        },
                        borderColor: AdaptiveTheme.primaryColor(context),
                      ),
                    ),
                  ],
                )
              : Center(child: AdaptiveCircularProgressIndicator()),
        ))));
  }
}
