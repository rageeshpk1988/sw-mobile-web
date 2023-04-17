import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '/src/home/child/screens/child_recomendations_web.dart';
import '/src/home/child/screens/child_skillenrichment_web.dart';
import '/src/home/child/screens/child_skillsummary_web.dart';
import '/src/home/child/widgets/profile_carousel_web.dart';

import '../../../../src/models/child.dart';
import '../../../../util/ui_helpers.dart';

import '../../../../adaptive/adaptive_circular_progressInd.dart';

import '../../../../adaptive/adaptive_theme.dart';
import '../../../../helpers/connectivity_helper.dart';
import '../../../../helpers/route_arguments.dart';
import '../../../../helpers/shared_pref_data.dart';
import '../../../../util/app_theme.dart';

import '../../../../util/dialogs.dart';
import '../../../../widgets/web_banner.dart';
import '../../../../widgets/web_bottom_bar.dart';
import '../../../models/interest_qa.dart';
import '../../../models/login_response.dart';
import '../../../providers/auth.dart';
import '../../../providers/interest_capture.dart';

import '../widgets/profile_carousel.dart';

import 'interest_capture_web.dart';

class ChildTransformationScreenWeb extends StatefulWidget {
  static String routeName = '/web-child-transformation';
  ChildTransformationScreenWeb({Key? key}) : super(key: key);

  @override
  State<ChildTransformationScreenWeb> createState() =>
      _ChildTransformationScreenWebState();
}

class _ChildTransformationScreenWebState
    extends State<ChildTransformationScreenWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  late LoginResponse _loginResponse;
  InterestStatus? _interestStatus;
  bool _isInIt = true;
  bool _isLoading = false;
  late Child _child;

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
      _child = Provider.of<Auth>(context, listen: false).currentChild!;
      updateInterestData(_child.childID);
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

  void updateInterestData(int? childId) async {
    _child = Provider.of<Auth>(context, listen: false).currentChild!;
    setState(() {
      _isLoading = true;
    });
    var status = await Provider.of<InterestCapture>(context, listen: false)
        .fetchAndSetInterestStatus(childId!, _loginResponse.b2cParent!.parentID)
        .onError((error, stackTrace) {
      setState(() {
        _isLoading = false;
        Dialogs().ackAlert(context, 'Data Error', error.toString());
        _interestStatus = null;
      });
      return null;
    });
    ;
    setState(() {
      _interestStatus = status;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
    // _child = Provider.of<Auth>(context, listen: true).currentChild!;

    List<int> categories = [];
    categories.add(1);
    categories.add(2);
    categories.add(3);
    categories.add(4);

    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24 - 120) / 2;
    final double itemWidth = size.width / 2;
    final AutoSizeGroup titleGrp = AutoSizeGroup();
    final AutoSizeGroup descGrp = AutoSizeGroup();

    Future _showNavigationCheckPopup() {
      return showDialog(
        builder: (_) => Dialog(
          insetPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: SizedBox(
              width: screenWidth(context) * 0.40,
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
                        "Dear ${_loginResponse.b2cParent!.name},",
                        style: AppTheme.lightTheme.textTheme.bodyMedium!
                            .copyWith(
                                fontSize: 16, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 13),
                    verticalSpaceSmall,
                    RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                              text: 'Every child would have ',
                              style: TextStyle(fontWeight: FontWeight.normal)),
                          TextSpan(
                              text: ' a special or unique set of interests ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  'that when noticed would serve a purpose far beyond just having fun. Analyzing this earlier could help the child immensely with learning and also enable the child to communicate more effectively knowing their strengths.',
                              style: TextStyle(fontWeight: FontWeight.normal))
                        ],
                      ),
                    ),
                    verticalSpaceMedium,
                    Text(
                      "Please capture your child's interest to continue",
                      style: TextStyle(
                          letterSpacing: 0.0,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: HexColor.fromHex('#D8015F')),
                      textAlign: TextAlign.start,
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
                              titleFontSize: 15)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        context: context,
      );
    }

    Future _showSkillEnrichmentCheckPopup() {
      return showDialog(
        builder: (_) => Dialog(
          insetPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: SizedBox(
              width: screenWidth(context) * 0.30,
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
                        "Dear ${_loginResponse.b2cParent!.name},",
                        style: AppTheme.lightTheme.textTheme.bodyMedium!
                            .copyWith(
                                fontSize: 16, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 13),
                    verticalSpaceSmall,
                    RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                              text:
                                  "We are waiting for your child's skill assessment.",
                              //'We are waiting for your child, ${_child.name}\'s skills to be assessed.',
                              style: TextStyle(fontWeight: FontWeight.normal)),
                          TextSpan(
                              text:
                                  "SchoolWizard recommends proceeding to the assessment section to start with the child's ", //    ' SchoolWizard advises you to proceed with the suggested skill assessment to begin with your child\'s ',
                              style: TextStyle(fontWeight: FontWeight.normal)),
                          TextSpan(
                              text: 'Transformational Journey.',
                              style: TextStyle(fontWeight: FontWeight.bold))
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
                              titleFontSize: 15)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        context: context,
      );
    }

    Future _showInterestCapturePopup() {
      return showDialog(
        builder: (_) => Dialog(
          insetPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: SizedBox(
              width: screenWidth(context) * 0.35,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: Text(
                        "Why capturing Interest",
                        style: AppTheme.lightTheme.textTheme.bodyMedium!
                            .copyWith(
                                fontSize: 16, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      height: 19,
                    ),
                    /* Text(
                      "Why it is important?",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: HexColor.fromHex('#D8015F')),
                      textAlign: TextAlign.start,
                    ),
                    verticalSpaceSmall,*/
                    RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        style: AppTheme.lightTheme.textTheme.bodyMedium!
                            .copyWith(
                                fontSize: 12, fontWeight: FontWeight.w300),
                        children: <TextSpan>[
                          TextSpan(
                              text: 'Every child would have ',
                              style: TextStyle(fontWeight: FontWeight.normal)),
                          TextSpan(
                              text: ' a special or unique set of interests ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  'that when noticed would serve a purpose far beyond just having fun. Analyzing this earlier could help the child immensely with learning and also enable the child to communicate more effectively knowing their strengths.',
                              style: TextStyle(fontWeight: FontWeight.normal))
                        ],
                      ),
                    ),
                    verticalSpaceTiny,
                    RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        style: AppTheme.lightTheme.textTheme.bodyMedium!
                            .copyWith(
                                fontSize: 12, fontWeight: FontWeight.w300),
                        children: <TextSpan>[
                          TextSpan(
                              text:
                                  'This questionnaire is to support parents get ',
                              style: TextStyle(fontWeight: FontWeight.normal)),
                          TextSpan(
                              text:
                                  'a deeper understanding of their child’s various interests/talents ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  'and their relative skills that if given special attention could ',
                              style: TextStyle(fontWeight: FontWeight.normal)),
                          TextSpan(
                              text: 'unfold a genius.',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    verticalSpaceSmall,
                    RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        style: AppTheme.lightTheme.textTheme.bodyMedium!
                            .copyWith(
                                fontSize: 12, fontWeight: FontWeight.w300),
                        children: <TextSpan>[
                          TextSpan(
                              text:
                                  'It’s the first step to a world of transformational coaching, ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  'through custom recommendations and programs that enhance your child’s unique skills & talents.',
                              style: TextStyle(fontWeight: FontWeight.normal))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Text(
                      "Instructions to Follow",
                      style: AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AdaptiveTheme.primaryColor(context)),
                      textAlign: TextAlign.start,
                    ),
                    verticalSpaceSmall,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('1)',
                            style: AppTheme.lightTheme.textTheme.bodyMedium!
                                .copyWith(
                                    fontSize: 12, fontWeight: FontWeight.w300)),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            "The questions focus on day-to-day activities, so please  make an appropriate choice.",
                            style: AppTheme.lightTheme.textTheme.bodyMedium!
                                .copyWith(
                                    fontSize: 12, fontWeight: FontWeight.w300),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                    verticalSpaceTiny,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '2)',
                          style: AppTheme.lightTheme.textTheme.bodyMedium!
                              .copyWith(
                                  fontSize: 12, fontWeight: FontWeight.w300),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            "There is no right or wrong answer on the list.",
                            style: AppTheme.lightTheme.textTheme.bodyMedium!
                                .copyWith(
                                    fontSize: 12, fontWeight: FontWeight.w300),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                    verticalSpaceTiny,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '3)',
                          style: AppTheme.lightTheme.textTheme.bodyMedium!
                              .copyWith(
                                  fontSize: 12, fontWeight: FontWeight.w300),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            "This questionnaire does not mean to be judgemental, so please feel free to mark the options accordingly.",
                            style: AppTheme.lightTheme.textTheme.bodyMedium!
                                .copyWith(
                                    fontSize: 12, fontWeight: FontWeight.w300),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: Container(
                          width: double.infinity,
                          child: appButton(
                            context: context,
                            width: 20,
                            height: 35,
                            title: 'Continue',
                            titleColour: AdaptiveTheme.primaryColor(context),
                            borderColor: AdaptiveTheme.primaryColor(context),
                            onPressed: () async {
                              SharedPrefData.setBlockCounter(
                                  _child.childID!, 0);
                              Navigator.of(context).pop();
                              if (await ConnectivityHelper.hasInternet(
                                      context,
                                      InterestCaptureScreenWeb.routeName,
                                      InterestArgs(updateInterestData)) ==
                                  true) {
                                Navigator.of(context).pushNamed(
                                    InterestCaptureScreenWeb.routeName,
                                    arguments:
                                        InterestArgs(updateInterestData));
                              }
                            },
                          )),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Container(
                          width: double.infinity,
                          child: appButton(
                            context: context,
                            width: 20,
                            height: 35,
                            title: 'Cancel',
                            titleColour: HexColor.fromHex("#333333"),
                            borderColor: HexColor.fromHex('#C9C9C9'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        context: context,
      );
    }

    void _navigateNext(int step) async {
      String screenRoute = '';
      switch (step) {
        case 1:
          if (_interestStatus != null) {
            if (_interestStatus!.totalCount > 0) {
              if (_interestStatus!.attendedCount == 0) {
                _showInterestCapturePopup();
              } else {
                if (_interestStatus!.attendedCount ==
                    _interestStatus!.totalCount) {
                  //TODO:need popup for completion
                } else {
                  screenRoute = InterestCaptureScreenWeb.routeName;
                }
              }
            } else {
              //TODO:need popup for no questions
            }
          } else {
            //TODO:need popup for  error
          }

          //_showInterestCapturePopup();
          break;
        case 2:
          if (_interestStatus != null) {
            if (_interestStatus!.submittedAny == true) {
              screenRoute = ChildRecomendationsScreenWeb.routeName;
            } else {
              _showNavigationCheckPopup();
            }
          } else {
            _showNavigationCheckPopup();
          }

          break;
        case 3:
          if (_interestStatus != null) {
            if (_interestStatus!.submittedAny == true) {
              screenRoute = ChildSkillsummaryScreenWeb.routeName;
            } else {
              _showNavigationCheckPopup();
            }
          } else {
            _showNavigationCheckPopup();
          }

          break;
        case 4:
          if (_interestStatus != null) {
            if (_interestStatus!.submittedAny == true) {
              if (_interestStatus!.numberOfSkillsAssessed > 0) {
                screenRoute = ChildSkillEnrichmentScreenWeb.routeName;
              } else {
                _showSkillEnrichmentCheckPopup();
              }
            } else {
              _showNavigationCheckPopup();
            }
          } else {
            _showNavigationCheckPopup();
          }
          break;
      }
      if (screenRoute != '') if (await ConnectivityHelper.hasInternet(
              context, screenRoute, InterestArgs(updateInterestData)) ==
          true) {
        Navigator.of(context).pushNamed(screenRoute,
            arguments: InterestArgs(updateInterestData));
      }
    }

    Widget _cardDataWidget(int step, BoxConstraints constraints) {
      late Widget widget;
      switch (step) {
        case 1:
          widget = _interestStatus == null
              ? AutoSizeText('No Questions Available',
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w700),
                  maxFontSize: 14,
                  maxLines: 1,
                  minFontSize: 10,
                  stepGranularity: 1,
                  group: descGrp)
              : _interestStatus!.totalCount > 0
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 110),
                          child: Text(
                            'Responded',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: HexColor.fromHex('#139A1D')),
                          ),
                        ),
                        LinearPercentIndicator(
                          width: 165,
                          lineHeight: constraints.maxHeight * 0.06,
                          percent: _interestStatus!.attendedCount /
                              _interestStatus!.totalCount,
                          animation: true,
                          animationDuration: 1000,
                          leading: Text(
                            '1',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          trailing: Text(
                            '${_interestStatus!.totalCount}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          center: _interestStatus!.attendedCount ==
                                  _interestStatus!.totalCount
                              ? Text(
                                  'Completed',
                                  style: TextStyle(
                                      fontSize: 7,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              : Text(
                                  '${_interestStatus!.attendedCount}',
                                  style: TextStyle(
                                      fontSize: 7,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                          progressColor: HexColor.fromHex('#139A1D'),
                        ),
                      ],
                    )
                  : AutoSizeText('No Questions Available',
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                      maxFontSize: 14,
                      maxLines: 1,
                      minFontSize: 10,
                      stepGranularity: 1,
                      group: descGrp);
          break;
        case 2:
          widget = Row(
            children: [
              LimitedBox(
                maxHeight: constraints.maxHeight * 0.30,
                child: AutoSizeText('Interests Found - ',
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w700),
                    maxFontSize: 14,
                    maxLines: 1,
                    minFontSize: 10,
                    stepGranularity: 1,
                    group: descGrp),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff139A1D),
                  /*image: DecorationImage(
          image: AssetImage('assets/images/profile_dummy.png'),
          fit: BoxFit.scaleDown),*/
                ),
                child: Center(
                    child: _interestStatus == null
                        ? Text(
                            "0",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          )
                        : Text(
                            _interestStatus!.numberOfInterestFound.toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          )),
              ),
            ],
          );
          break;
        case 3:
          widget = Row(
            children: [
              const SizedBox(height: 10),
              LimitedBox(
                maxHeight: constraints.maxHeight * 0.30,
                child: AutoSizeText('Skills Assessed - ',
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w700),
                    maxFontSize: 14,
                    maxLines: 1,
                    minFontSize: 10,
                    stepGranularity: 1,
                    group: descGrp),
              ),
              Container(
                width: 45,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xff139A1D),
                  /*image: DecorationImage(
          image: AssetImage('assets/images/profile_dummy.png'),
          fit: BoxFit.scaleDown),*/
                ),
                child: Center(
                    child: _interestStatus == null
                        ? Text(
                            '0',
                            // '5/10',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          )
                        : Text(
                            '${_interestStatus!.numberOfSkillsAssessed.toString()}/${_interestStatus!.totalNumberOfSkills.toString()}',
                            // '5/10',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          )),
              ),
            ],
          );
          break;
        case 4:
          widget = Row(
            children: [
              LimitedBox(
                maxHeight: constraints.maxHeight * 0.30,
                child: AutoSizeText('Programs Completed - ',
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w700),
                    maxFontSize: 14,
                    maxLines: 1,
                    minFontSize: 10,
                    stepGranularity: 1,
                    group: descGrp),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff139A1D),
                  /*image: DecorationImage(
          image: AssetImage('assets/images/profile_dummy.png'),
          fit: BoxFit.scaleDown),*/
                ),
                child: Center(
                    child: _interestStatus == null
                        ? Text(
                            "0",
                            // '5',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          )
                        : Text(
                            _interestStatus!.numberOfProgramsCompleted
                                .toString(),
                            // '5',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          )),
              ),
            ],
          );
          break;
      }
      return widget;
    }

    Widget _buildMenuCard(int step) {
      late Color cardColor;
      late String content;
      late String stepImageUrl;
      late String title;
      late String imageUrl;
      late String iconImageUrl;

      late double imageLeftValue;
      late double imageBottomValue;
      late double imageWidthValue;
      late double imageHeightValues;

      switch (step) {
        case 1:
          cardColor = HexColor.fromHex('#EFFEF0');
          content =
              "Discover your child's interests by completing this quick questionnaire.";
          stepImageUrl = 'assets/images/step1.png';
          title = 'Capture Interest';
          imageUrl = 'assets/images/transform1.png';
          iconImageUrl = 'assets/images/eval1.png';
          imageLeftValue = -70;
          imageBottomValue = -3;
          imageWidthValue = 0.60;
          imageHeightValues = 0.70;
          break;
        case 2:
          cardColor = HexColor.fromHex('#E0F8E1');
          content =
              'Our AI engine will help derive insight on your child’s interests and suggest suitable assessments.';
          stepImageUrl = 'assets/images/step2.png';
          title = 'Assessment Recommendations';
          imageUrl = 'assets/images/transform2.png';
          iconImageUrl = 'assets/images/eval2.png';
          imageLeftValue = -70;
          imageBottomValue = -3;
          imageWidthValue = 0.60;
          imageHeightValues = 0.70;
          break;
        case 3:
          cardColor = HexColor.fromHex('#C8E6CA');
          content =
              'Analyze the inferences and suggestions from the skill assessment and view the detailed report.';
          stepImageUrl = 'assets/images/step3.png';
          title = 'Skill Summary';
          imageUrl = 'assets/images/transform3.png';
          iconImageUrl = 'assets/images/eval3.png';
          imageLeftValue = -70;
          imageBottomValue = -3;
          imageWidthValue = 0.60;
          imageHeightValues = 0.70;
          break;
        case 4:
          cardColor = HexColor.fromHex('#ACE2B0');
          content =
              'Find products, programs and workshops to enhance your child’s interests & talents.';
          stepImageUrl = 'assets/images/step4.png';
          title = 'Skill Enrichment';
          imageUrl = 'assets/images/transform4.png';
          iconImageUrl = 'assets/images/eval4.png';

          imageLeftValue = -70;
          imageBottomValue = -3;
          imageWidthValue = 0.60;
          imageHeightValues = 0.56;

          break;
      }

      return Material(
        borderRadius: BorderRadius.circular(13.0),
        elevation: 2.0,
        color: cardColor,
        child: LayoutBuilder(
          builder: (context, constraints) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 5),
                    Image(
                      image: AssetImage(stepImageUrl),
                      width: constraints.maxWidth * 0.20,
                      height: constraints.maxHeight * 0.35,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LimitedBox(
                            maxHeight: constraints.maxHeight * 0.2,
                            child: AutoSizeText(
                                //textScale(context).toString(),
                                title,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    letterSpacing: 0.0,
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800),
                                maxFontSize: 16,
                                maxLines: 1,
                                minFontSize: 10,
                                stepGranularity: 1,
                                group: titleGrp),
                          ),
                          const SizedBox(height: 10),
                          LimitedBox(
                            maxHeight: constraints.maxHeight * 0.35,
                            child: AutoSizeText(content,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w300),
                                maxFontSize: 16,
                                maxLines: 4,
                                minFontSize: 10,
                                stepGranularity: 1,
                                group: descGrp),
                          ),
                          //SizedBox(height: 10),
                          Spacer(),
                          Row(
                            children: [
                              Image(
                                image: AssetImage(iconImageUrl),
                              ),
                              const SizedBox(width: 10),
                              _cardDataWidget(step, constraints),
                            ],
                          ),
                          // SizedBox(height: 2),
                        ],
                      ),
                    )
                  ],
                ),
                Positioned(
                  left: imageLeftValue,
                  bottom: imageBottomValue,
                  child: Image(
                    image: AssetImage(imageUrl),
                    width: constraints.maxWidth * imageWidthValue,
                    height: constraints.maxHeight * imageHeightValues,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    double _cardHeight() {
      var deviceSize = MediaQuery.of(context).size;
      var appBarHeight = kToolbarHeight;
      var screenheight = deviceSize.height - appBarHeight;
      double cardHeight = 0;
      double txtScale = textScale(context);
      if (txtScale <= 0.85) {
        if (screenheight < 750)
          cardHeight = 3.3;
        else
          cardHeight = 4.5;
      }
      if (txtScale >= 0.85) {
        if (screenheight < 750)
          cardHeight = 3.3;
        else
          cardHeight = 4.2;
      } else if (txtScale == 1.0) {
        if (screenheight < 750)
          cardHeight = 3.3;
        else
          cardHeight = 4;
      } else if (txtScale >= 1.0) {
        if (screenheight < 750)
          cardHeight = 3.3;
        else
          cardHeight = 4;
      } else if (txtScale >= 1.15) {
        if (screenheight < 750)
          cardHeight = 3.3;
        else
          cardHeight = 3.8;
      } else if (txtScale >= 1.30) {
        if (screenheight < 750)
          cardHeight = 3.2;
        else
          cardHeight = 3.4;
      } else {
        if (screenheight < 750)
          cardHeight = 3.3;
        else
          cardHeight = 4;
      }
      return cardHeight;
    }

    Widget _bodyWidget() {
      return Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (_loginResponse.b2cParent!.childDetails!.length > 0)
                ProfileCarouselWeb(
                    updateHandler: updateInterestData,
                    children: _loginResponse.b2cParent!.childDetails),
              if (_loginResponse.b2cParent!.childDetails!.length < 1)
                const SizedBox(),
              _isLoading == false
                  ? Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: GridView(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          //physics: NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          children: categories
                              .map(
                                (step) => InkWell(
                                  onTap: () {
                                    _navigateNext(step);
                                  },
                                  child: _buildMenuCard(step),
                                ),
                              )
                              .toList(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1.0, // (30.0 / 8.0),
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            mainAxisExtent: 150,
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: AdaptiveCircularProgressIndicator(),
                        ),
                      ),
                    ),
            ],
          ),
        ],
      );
    }

    Widget _bodyWidgetSmall() {
      return Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (_loginResponse.b2cParent!.childDetails!.length > 0)
                ProfileCarousel(
                    updateHandler: updateInterestData,
                    children: _loginResponse.b2cParent!.childDetails),
              if (_loginResponse.b2cParent!.childDetails!.length < 1)
                const SizedBox(),
              _isLoading == false
                  ? Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          children: categories
                              .map(
                                (step) => InkWell(
                                  onTap: () {
                                    _navigateNext(step);
                                  },
                                  child: _buildMenuCard(step),
                                ),
                              )
                              .toList(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio:
                                (itemWidth / itemHeight * _cardHeight()),
                            // (textScale(context) <= 1.0 ? 3.5 : 2.8)),
                            crossAxisCount: 1,
                            crossAxisSpacing: 15.0,
                            mainAxisSpacing: 15.0,
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: AdaptiveCircularProgressIndicator(),
                        ),
                      ),
                    ),
            ],
          ),
        ],
      );
    }

    return Scaffold(
      endDrawer: WebBannerDrawer(),
      key: scaffoldKey,
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          //crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            WebBanner(
              showMenu: true,
              showHomeButton: true,
              showProfileButton: true,
              scaffoldKey: scaffoldKey,
            ),
            Container(
              width: screenWidth(context) * 0.98,
              height: screenHeight(context) * 0.98,
              child: screenWidth(context) > 800
                  ? _bodyWidget()
                  : _bodyWidgetSmall(),
            ),
            WebBottomBar(),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
