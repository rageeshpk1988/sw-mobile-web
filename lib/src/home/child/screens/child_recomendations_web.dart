import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pretty_gauge/pretty_gauge.dart';
import 'package:provider/provider.dart';
import '/src/home/child/screens/child_skillsummary_web.dart';
import '/src/subscription/screens/mysubscriptionplan_web.dart';
import '/src/subscription/screens/subscriptionplans_web.dart';
import '../../../../webviews/webview_assessment.dart';
import '../../../../src/models/child.dart';
import '../../../../util/dialogs.dart';

import '../../../../helpers/route_arguments.dart';
import '../../../../src/models/child_recomendation.dart';
import '../../../../src/models/login_response.dart';
import '../../../../src/providers/child_recomendations.dart';
import '../../../../adaptive/adaptive_theme.dart';
import '../../../../util/app_theme.dart';

import '../../../../util/dash_divider.dart';

import '../../../../util/date_util.dart';
import '../../../../util/ui_helpers.dart';
import '../../../../webviews/webview_assessment_web.dart';
import '../../../../widgets/web_banner.dart';
import '../../../../widgets/web_bottom_bar.dart';
import '../../../models/getquestion_request.dart';
import '../../../models/parent_subscription.dart';
import '../../../providers/auth.dart';
import '../../../providers/subscriptions.dart';

class ChildRecomendationsScreenWeb extends StatefulWidget {
  static String routeName = '/web-child-recomendations';
  ChildRecomendationsScreenWeb({Key? key}) : super(key: key);

  @override
  _ChildRecomendationsScreenScreenWebState createState() =>
      _ChildRecomendationsScreenScreenWebState();
}

class _ChildRecomendationsScreenScreenWebState
    extends State<ChildRecomendationsScreenWeb> {
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
          Dialogs().ackAlert(context, 'Data Error', error.toString());
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
                    style: AppTheme.lightTheme.textTheme.bodyMedium!
                        .copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 13),
                verticalSpaceSmall,
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTheme.lightTheme.textTheme.bodyMedium!
                        .copyWith(fontSize: 12, fontWeight: FontWeight.w300),
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
                              Navigator.of(context).pushNamed(
                                  SubscriptionPlansScreenWeb.routeName);
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
                    style: AppTheme.lightTheme.textTheme.bodyMedium!
                        .copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 13),
                verticalSpaceSmall,
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTheme.lightTheme.textTheme.bodyMedium!
                        .copyWith(fontSize: 12, fontWeight: FontWeight.w300),
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
            width: screenWidth(context) *
                (screenWidth(context) > 800 ? 0.20 : 0.35),
            child: AutoSizeText(
              title,
              textAlign: TextAlign.left,
              style: const TextStyle(
                  fontSize: 13,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w400),
              maxFontSize: 13,
              maxLines: 2,
              minFontSize: 11,
              stepGranularity: 1,
            ),
          ),
          Spacer(),
          Container(
            width: screenWidth(context) *
                (screenWidth(context) > 800 ? 0.08 : 0.3),
            height: 25,
            child: ElevatedButton(
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
                            Navigator.of(context).pushNamed(
                                MySubscriptionPlanScreenWeb.routeName);

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
                            //  print(getQuestionReq.toString());
                            if (kIsWeb) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WebViewAssessmentWeb(
                                          getQuestionReq: getQuestionReq,
                                          updateChildData:
                                              interestArgs.updateHandler,
                                        )),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WebViewAssessment(
                                          getQuestionReq: getQuestionReq,
                                          updateChildData:
                                              interestArgs.updateHandler,
                                        )),
                              );
                            }

                            setState(() {
                              _isEnabled = false;
                            });
                          }
                        }
                      : () {
                          Navigator.of(context).pushReplacementNamed(
                              ChildSkillsummaryScreenWeb.routeName,
                              arguments:
                                  InterestArgs(interestArgs.updateHandler));
                        },
              child: Text(
                status == false ? 'Assess Now' : 'View Score',
                style: TextStyle(
                  letterSpacing: 0.0,
                  fontSize: 12,
                  color: status == false
                      ? AdaptiveTheme.primaryColor(context)
                      : AdaptiveTheme.secondaryColor(context),
                ),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1.0,
                      color: status == false
                          ? AdaptiveTheme.primaryColor(context)
                          : AdaptiveTheme.secondaryColor(context),
                    ),
                    borderRadius: new BorderRadius.circular(7.0),
                  )),
            ),
          )
        ],
      );
    }

    Widget _buildCard(
        double score, String title, List<ChildAssessment>? assessments) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
        child: Container(
          //width: double.infinity,
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
                  Column(
                    children: [
                      PrettyGauge(
                        gaugeSize: 90,
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
                      SizedBox(
                        // width: 220,
                        child: AutoSizeText(
                          title,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              fontSize: 16,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500),
                          maxFontSize: 16,
                          maxLines: 2,
                          minFontSize: 13,
                          stepGranularity: 1,
                        ),
                      ),
                    ],
                  ),
                  DashDivider(color: Colors.grey.shade300),
                  const SizedBox(height: 30),
                  if (assessments != null)
                    Expanded(
                      child: ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
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
                              const SizedBox(height: 3)
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

    Widget _bodyWidget() {
      return GridView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        // physics: AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        children: List.generate(_suggestions.length, (i) {
          return _buildCard(
            _suggestions[i].score,
            _suggestions[i].interestName,
            _suggestions[i].assessments,
          );
        }),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: (30.0 / 25.0),
            crossAxisCount: screenWidth(context) > 800 ? 3 : 1,
            crossAxisSpacing: 5,
            mainAxisSpacing: 10,
            mainAxisExtent: 300),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: WebBannerDrawer(),
      key: scaffoldKey,
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
              padding: const EdgeInsets.only(left: 50.0, top: 40, bottom: 30.0),
              child: Row(
                children: [
                  Text(
                    'Top Interestes',
                    style: TextStyle(
                        letterSpacing: 0.0,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            Container(
                width: screenWidth(context) *
                    (screenWidth(context) > 800
                        ? 0.98
                        : screenWidth(context) > 400
                            ? 0.80
                            : 0.98),
                height: screenHeight(context), // * 0.90,
                child: _suggestions.length < 1
                    ? Center(child: const Text(' '))
                    : _bodyWidget()),
            WebBottomBar(),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
