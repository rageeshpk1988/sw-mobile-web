import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pretty_gauge/pretty_gauge.dart';
import 'package:provider/provider.dart';
import '../../../../webviews/webview_assessment.dart';
import '../../../../src/models/child.dart';
import '../../../../util/dialogs.dart';

import '../../../../helpers/route_arguments.dart';
import '../../../../src/models/child_recomendation.dart';
import '../../../../src/models/login_response.dart';
import '../../../../src/providers/child_recomendations.dart';
import '../../../../adaptive/adaptive_theme.dart';
import '../../../../util/app_theme.dart';
import '../../../../util/app_theme_cupertino.dart';
import '../../../../util/dash_divider.dart';

import '../../../../adaptive/adaptive_custom_appbar.dart';
import '../../../../util/date_util.dart';
import '../../../../util/ui_helpers.dart';
import '../../../models/getquestion_request.dart';
import '../../../models/parent_subscription.dart';
import '../../../providers/auth.dart';
import '../../../providers/subscriptions.dart';
import '../../../subscription/screens/mySubscriptionPlan.dart';
import '../../../subscription/screens/subcriptionsPlans.dart';
import 'child_skillsummary.dart';

class ChildRecomendationsScreen extends StatefulWidget {
  static String routeName = '/child-recomendations';
  ChildRecomendationsScreen({Key? key}) : super(key: key);

  @override
  _ChildRecomendationsScreenScreenState createState() =>
      _ChildRecomendationsScreenScreenState();
}

class _ChildRecomendationsScreenScreenState
    extends State<ChildRecomendationsScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  late List<ChildSuggestion> _suggestions = [];
  late LoginResponse _loginResponse;
  var _isInIt = true;
  var _isEnabled = false;
  late Child _defaultChild;

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
      _defaultChild = Provider.of<Auth>(context, listen: false).currentChild!;

      // Provider.of<ChildRecomendations>(context, listen: false)
      //     .fetchChildSuggestions(
      //         _defaultChild.childID!, _loginResponse.b2cParent!.parentID)
      Provider.of<ChildRecomendations>(context, listen: false)
          .fetchChildSuggestions(
              _defaultChild.childID!, _loginResponse.b2cParent!.parentID)
          .then((value) {
        setState(() {
          _suggestions = value;
        });
      }).onError((error, stackTrace) {
        setState(() {
          Dialogs().ackAlert(context, '', error.toString());
        });
      });

      _isInIt = false;
    }
    super.didChangeDependencies();
  }

  Future<String> verifySubscriptionPackage() async {
    late ParentSubscriptionGroup? parentSubscription;
    String retValue = "nopackage";
    var loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;

    var parentId = loginResponse.b2cParent!.parentID;
    // var authToken = loginResponse.token;
    try {
      parentSubscription =
          await Provider.of<Subscriptions>(context, listen: false)
              .listParentSubscription(parentId);
      if (parentSubscription.currentPlan.packageId != 0) {
        var basicAssessment = parentSubscription.currentPlan.subCategoryList
            .firstWhere((element) => element.categoryId == 3,
                orElse: () => SubCategoryList(
                      unusedPlan: 0,
                      categoryName: 'Basic Assessments',
                      handlerName: 'basic',
                      couponCode: '000',
                      count: 0,
                      categoryId: 0,
                    ));
        //retValue = true;
        if (basicAssessment.unusedPlan == 0) {
          retValue = "over";
        } else {
          retValue = "ok";
        }
      } else {
        retValue = "nopackage";
      }
    } catch (e) {
      retValue = "nopackage";
    }
    // parentSubscription =
    //     await Provider.of<Subscriptions>(context, listen: false)
    //         .listParentSubscription(parentId, authToken)
    //         .then((value) {
    //   if (value.packageId != 0) {
    //     retValue = true;
    //   }
    // }).onError((error, stackTrace) {
    //   retValue = false;
    // });
    return retValue;
  }

  Future _showNoPackagePopup(String parentName) {
    return showDialog(
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                Center(
                  child: Text(
                    "Dear $parentName,",
                    style: Platform.isIOS
                        ? AppThemeCupertino
                            .lightTheme.textTheme.navTitleTextStyle
                            .copyWith(fontSize: 16, fontWeight: FontWeight.w600)
                        : AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                            fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 13),
                verticalSpaceSmall,
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Platform.isIOS
                        ? AppThemeCupertino
                            .lightTheme.textTheme.navTitleTextStyle
                            .copyWith(fontSize: 12, fontWeight: FontWeight.w300)
                        : AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                            fontSize: 12, fontWeight: FontWeight.w300),
                    children: <TextSpan>[
                      TextSpan(
                        text:
                            'Schoolwizard provides options for parents to choose flexible plans according to their requirements. Choose a suitable plan for you',
                      ),
                    ],
                  ),
                ),
                verticalSpaceLarge,
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                          width: 170,
                          child: appButton(
                            context: context,
                            width: 20,
                            height: 35,
                            title: 'Choose',
                            titleColour: AdaptiveTheme.primaryColor(context),
                            borderColor: AdaptiveTheme.primaryColor(context),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              Navigator.of(context)
                                  .pushNamed(SubscriptionPlansScreen.routeName);
                            },
                          )),
                    ),
                    verticalSpaceSmall,
                    Center(
                      child: Container(
                          width: 170,
                          child: appButton(
                            context: context,
                            width: 20,
                            height: 35,
                            title: 'Later',
                            titleColour: HexColor.fromHex("#333333"),
                            borderColor: HexColor.fromHex('#C9C9C9'),
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      context: context,
    );
  }

  Future _showOverPackagePopup(String parentName) {
    return showDialog(
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                Center(
                  child: Text(
                    "Dear $parentName,",
                    style: Platform.isIOS
                        ? AppThemeCupertino
                            .lightTheme.textTheme.navTitleTextStyle
                            .copyWith(fontSize: 16, fontWeight: FontWeight.w600)
                        : AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                            fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 13),
                verticalSpaceSmall,
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Platform.isIOS
                        ? AppThemeCupertino
                            .lightTheme.textTheme.navTitleTextStyle
                            .copyWith(fontSize: 12, fontWeight: FontWeight.w300)
                        : AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                            fontSize: 12, fontWeight: FontWeight.w300),
                    children: <TextSpan>[
                      TextSpan(
                        text:
                            'The current plan has been exhausted. Please renew the plan for continued usage.',
                      ),
                    ],
                  ),
                ),
                verticalSpaceLarge,
                Center(
                  child: Container(
                      width: 170,
                      child: appButton(
                        context: context,
                        width: 20,
                        height: 35,
                        title: 'OK',
                        titleColour: AdaptiveTheme.primaryColor(context),
                        borderColor: AdaptiveTheme.primaryColor(context),
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final interestArgs =
        ModalRoute.of(context)!.settings.arguments as InterestArgs;
    Widget _itemRow(String title, bool? status, int assessmentId) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: 150,
            child: AutoSizeText(
              title,
              textAlign: TextAlign.left,
              style: const TextStyle(
                  fontSize: 13,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis),
              maxFontSize: textScale(context) <= 1.0 ? 12 : 11,
              maxLines: 2,
              minFontSize: 11,
              stepGranularity: 1,
            ),
          ),
          Spacer(),
          SizedBox(
            width: textScale(context) <= 1.0 ? 105 : 110,
            height: 25,
            child: appButton(
              titleFontSize: textScale(context) <= 1.0 ? 12 : 10,
              borderColor: status == false
                  ? AdaptiveTheme.primaryColor(context)
                  : AdaptiveTheme.secondaryColor(context),
              height: 25,
              title: status == false ? 'Assess Now' : 'View Score',
              titleColour: status == false
                  ? AdaptiveTheme.primaryColor(context)
                  : AdaptiveTheme.secondaryColor(context),
              width: textScale(context) <= 1.0 ? 105 : 110,
              onPressed: _isEnabled
                  ? () {}
                  : status == false
                      ? () async {
                          setState(() {
                            _isEnabled = true;
                          });
                          String result = await verifySubscriptionPackage();

                          if (result == "nopackage") {
//show the info message
                            await _showNoPackagePopup(
                                _loginResponse.b2cParent!.name);
                            //show plans list

                            setState(() {
                              _isEnabled = false;
                            });
                          } else if (result == "over") {
                            await _showOverPackagePopup(
                                _loginResponse.b2cParent!.name);
                            //show myPlans page
                            Navigator.of(context)
                                .pushNamed(MySubscriptionPlanScreen.routeName);

                            setState(() {
                              _isEnabled = false;
                            });
                          } else {
                            _defaultChild =
                                Provider.of<Auth>(context, listen: false)
                                    .currentChild!;
                            int age = DateUtil.getAge(_defaultChild.dob!);
                            GetQuestionReq getQuestionReq = GetQuestionReq(
                                childName: '${_defaultChild.name}',
                                countryCode: '${_defaultChild.countryID}',
                                hierarchyId: '$assessmentId',
                                currentLeafId: '0',
                                studentId: '${_defaultChild.childID}',
                                hierarchyCount: '7',
                                age: '$age',
                                assessmentName: '$title');
                            //print(getQuestionReq.toString());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WebViewAssessment(
                                        getQuestionReq: getQuestionReq,
                                        updateChildData:
                                            interestArgs.updateHandler,
                                      )),
                            );
                            setState(() {
                              _isEnabled = false;
                            });
                          }
                        }
                      : () {
                          Navigator.of(context).pushReplacementNamed(
                              ChildSkillsummaryScreen.routeName,
                              arguments:
                                  InterestArgs(interestArgs.updateHandler));
                        },
              /*child: Text(
                status == false ? 'Assess Now' : 'View Score',
                style: TextStyle(
                  letterSpacing: 0.0,
                  fontSize: textScale(context) <= 1.0 ? 12 : 10,
                  color: status == false
                      ? AdaptiveTheme.primaryColor(context)
                      : AdaptiveTheme.secondaryColor(context),
                ),
              ),*/
              context: context,
              /*style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1.0,
                      color: status == false
                          ? AdaptiveTheme.primaryColor(context)
                          : AdaptiveTheme.secondaryColor(context),
                    ),
                    borderRadius: new BorderRadius.circular(7.0),
                  ))*/
            ),
          ),
        ],
      );
    }

    Widget _buildCard(
        double score, String title, List<ChildAssessment>? assessments) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
        child: Container(
          width: double.infinity,
          height: 230,
          child: Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 8.0, 1.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: 220,
                        child: AutoSizeText(
                          title,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              fontSize: 16,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500),
                          maxFontSize: textScale(context) <= 1.0 ? 16 : 13,
                          maxLines: 2,
                          minFontSize: 13,
                          stepGranularity: 1,
                        ),
                      ),
                      Spacer(),
                      PrettyGauge(
                        gaugeSize: 60,
                        currentValueDecimalPlaces: 0,
                        segments: [
                          GaugeSegment('1', 20, HexColor.fromHex('#F361A1')),
                          GaugeSegment('2', 20, HexColor.fromHex('#F3408E')),
                          GaugeSegment('3', 20, HexColor.fromHex('#ED247C')),
                          GaugeSegment('4', 20, HexColor.fromHex('#9F08AA')),
                          GaugeSegment('5', 20, HexColor.fromHex('#7F2A86')),
                        ],
                        currentValue: score,
                        needleColor: Colors.black,
                        showMarkers: false,
                      ),
                    ],
                  ),
                  DashDivider(color: Colors.grey.shade300),
                  const SizedBox(height: 30),
                  if (assessments != null)
                    Expanded(
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: assessments.length,
                        itemBuilder: (BuildContext context, int i) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _itemRow(
                                  assessments[i].assessmentName,
                                  assessments[i].takenStatus,
                                  assessments[i].assessmentId),
                              const SizedBox(height: 15)
                            ],
                          );
                        },
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      appBar: AdaptiveCustomAppBar(
        showShopifyHomeButton: false,
        showShopifyCartButton: false,
        showKycButton: false,
        showProfileButton: false,
        showHamburger: false,
        scaffoldKey: scaffoldKey,
        adResponse: null,
        loginResponse: null,
        kycStatus: null,
        updateHandler: () {},
        socialUpdateHandler: () {},
        socialAccessTokenResponse: null,
        title: "Top Interests",
        showMascot: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(10),
          child: _suggestions.length < 1
              ? Center(child: const Text(' '))
              : ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (BuildContext context, int i) {
                    return _buildCard(
                        _suggestions[i].score,
                        _suggestions[i].interestName,
                        _suggestions[i].assessments);
                  },
                ),
        ),
        // ),
      ),
    );
  }
}
