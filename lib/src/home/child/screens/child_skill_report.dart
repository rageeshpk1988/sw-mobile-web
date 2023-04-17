import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pretty_gauge/pretty_gauge.dart';
import 'package:expandable_text/expandable_text.dart' as expandTextPackage;
import 'package:provider/provider.dart';
import '../../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../../adaptive/adaptive_theme.dart';
import '../../../../helpers/route_arguments.dart';
import '../../../../src/home/child/screens/child_coach_info_screen.dart';
import '../../../../src/home/child/screens/child_skill_report_subview.dart';
import '../../../../src/models/child_skill_summary_group.dart';
import '../../../../src/providers/child_skill_summary.dart';

import '../../../../adaptive/adaptive_custom_appbar.dart';
import '../../../../util/date_util.dart';
import '../../../../util/dialogs.dart';
import '../../../../util/ui_helpers.dart';
import '../../../models/child.dart';
import '../../../models/login_response.dart';
import '../../../providers/auth.dart';

class ChildSkillReportScreen extends StatefulWidget {
  static String routeName = '/child-skill-report';
  ChildSkillReportScreen({Key? key}) : super(key: key);

  @override
  _ChildSkillReportScreenScreenState createState() =>
      _ChildSkillReportScreenScreenState();
}

class _ChildSkillReportScreenScreenState extends State<ChildSkillReportScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  late ChildSkillCategory _childSkillCategory;
  late ChildSkillSubCategory _childSkillSubCategory;
  late ChildSkillReport? _childSkillReport;

  late LoginResponse _loginResponse;
  var _isInIt = true;
  bool _isLoading = false;
  late Child _defaultChild;
  String _pageSubheading = '';
  @override
  void didChangeDependencies() {
    if (_isInIt) {
      setState(() {
        _isLoading = true;
      });
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
      _defaultChild = Provider.of<Auth>(context, listen: false).currentChild!;

      _childSkillCategory =
          ModalRoute.of(context)!.settings.arguments as ChildSkillCategory;
      _childSkillSubCategory = _childSkillCategory.subCategoryList![0];
      _childSkillReport = null;
      Provider.of<ChildSkillSummary>(context, listen: false)
          .fetchAndSetSkillReport(_defaultChild.childID!,
              _loginResponse.b2cParent!.parentID, _childSkillCategory)
          .then((value) {
        _childSkillReport = value;
        Provider.of<ChildSkillSummary>(context, listen: false)
            .fetchAssessmentDescription(
                _defaultChild.childID!, _childSkillCategory.catID)
            .then((value1) {
          setState(() {
            _pageSubheading = value1;
            _isLoading = false;
          });
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

  @override
  Widget build(BuildContext context) {
//this has to be remvoed
    Widget _buildCard(ChildSkillSubCategory subCategory) {
      String imageUrl = '';
      String recommendation = '';
      switch (subCategory.skill.toLowerCase()) {
        case '':
          imageUrl = 'assets/images/Novice2.png';
          break;
        case 'novice':
          imageUrl = 'assets/images/Novice2.png';
          recommendation = 'needs improvement';
          break;
        case 'developing':
          imageUrl = 'assets/images/Developing2.png';
          recommendation = 'has scope for improvement';
          break;
        case 'proficient':
          imageUrl = 'assets/images/Proficient2.png';
          recommendation = 'is Awesome';
          break;
      }
      var childName =
          Provider.of<Auth>(context, listen: false).currentChild!.name;
      recommendation = '$childName $recommendation';
      return Padding(
        padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
        child: Container(
          width: double.infinity,
          height: 90,
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 8.0, 1.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(image: AssetImage(imageUrl)),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 220,
                            child: AutoSizeText(
                              subCategory.catName,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 0.0,
                                  color: AdaptiveTheme.secondaryColor(context),
                                  fontWeight: FontWeight.w500),
                              maxFontSize: textScale(context) <= 1.0 ? 16 : 11,
                              maxLines: 2,
                              minFontSize: 11,
                              stepGranularity: 1,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              var args = SkillReportDescriptionArgs(
                                  _childSkillCategory, subCategory);
                              Navigator.of(context).pushNamed(
                                  ChildSkillReportSubViewScreen.routeName,
                                  arguments: args);
                            },
                            child: Image(
                              image: AssetImage(
                                'assets/images/More2.png',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 220,
                        child: AutoSizeText(
                          recommendation,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w300),
                          maxFontSize: textScale(context) <= 1.0 ? 12 : 10,
                          maxLines: 2,
                          minFontSize: 10,
                          stepGranularity: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget _buildHeaderCard(double score) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(4.0, 4.0, 8.0, 4.0),
        child: Container(
          width: double.infinity,
          height: 120,
          child: Card(
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 0.0, 8.0, 1.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PrettyGauge(
                        gaugeSize: 90,
                        currentValueDecimalPlaces: 0,
                        segments: [
                          GaugeSegment('1', 20, Colors.red),
                          GaugeSegment('2', 15, Colors.orange.shade800),
                          GaugeSegment('3', 15, Colors.orange.shade500),
                          GaugeSegment('4', 15, Colors.yellow.shade500),
                          GaugeSegment('5', 15, Colors.green.shade400),
                          GaugeSegment('6', 20, Colors.green.shade800),
                        ],
                        currentValue: score,
                        needleColor: Colors.black,
                        showMarkers: false,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 200,
                              child: AutoSizeText(
                                "${_childSkillSubCategory.catName} Assessment",
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontSize: 18,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500),
                                maxFontSize:
                                    textScale(context) <= 1.0 ? 18 : 11,
                                maxLines: 2,
                                minFontSize: 11,
                                stepGranularity: 1,
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: 200,
                              child: AutoSizeText(
                                _childSkillSubCategory.skill == ''
                                    ? 'NOVICE'
                                    : _childSkillSubCategory.skill
                                        .toUpperCase(),
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color:
                                        AdaptiveTheme.secondaryColor(context),
                                    fontSize: 18,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500),
                                maxFontSize:
                                    textScale(context) <= 1.0 ? 18 : 11,
                                maxLines: 2,
                                minFontSize: 11,
                                stepGranularity: 1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (_childSkillReport != null)
                              Row(
                                children: [
                                  Text(
                                    'Completed On ${_childSkillReport!.completedOn == null ? '____' : DateUtil.formattedDate(DateTime.parse(_childSkillReport!.completedOn))}',
                                    style: TextStyle(
                                        letterSpacing: 0.0,
                                        fontSize: textScale(context) <= 1.0
                                            ? 11
                                            : 10, //9 : 8,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 5),
                                  // TODO:: TIME TAKEN IS COMMENTED AND TO BE ENABLED LATER
                                  // Text(
                                  //   '|',
                                  //   style: TextStyle(
                                  //       letterSpacing: 0.0,
                                  //       fontSize:
                                  //           textScale(context) <= 1.0 ? 12 : 10,
                                  //       color: AdaptiveTheme.secondaryColor(
                                  //           context),
                                  //       fontWeight: FontWeight.w500),
                                  // ),
                                  // SizedBox(width: 5),
                                  // Text(
                                  //   'Time Taken: ${_childSkillReport!.timeTaken}',
                                  //   style: TextStyle(
                                  //       letterSpacing: 0.0,
                                  //       fontSize:
                                  //           textScale(context) <= 1.0 ? 9 : 8,
                                  //       color: Colors.grey,
                                  //       fontWeight: FontWeight.w500),
                                  // ),
                                ],
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
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
        title: _childSkillCategory.catName,
        showMascot: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(10),
          child: _isLoading
              ? Center(child: AdaptiveCircularProgressIndicator())
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                      child: expandTextPackage.ExpandableText(
                        _pageSubheading,
                        expandText: 'See more',
                        collapseText: 'See less',
                        maxLines: 2,
                        linkColor: Colors.grey,
                        style: TextStyle(
                          fontSize: textScale(context) <= 1.0 ? 16 : 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildHeaderCard(_childSkillSubCategory.percentage),

                    const SizedBox(height: 5),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _childSkillSubCategory.subCategoryList!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildCard(
                            _childSkillSubCategory.subCategoryList![index]);
                      },
                    ),

                    //SUBCATEGORY LIST
                    const SizedBox(height: 10),
                    //WHAT NEXT BUTTON
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: appButton(
                        context: context,
                        width: double.infinity,
                        //primary: AdaptiveTheme.primaryColor(context),
                        height: 40,
                        titleFontSize: 14,
                        title: 'What Next ?',
                        titleColour: AdaptiveTheme.primaryColor(context),
                        onPressed: () {
                          SkillReportAndCategoryArgs args =
                              SkillReportAndCategoryArgs(
                            _childSkillCategory,
                            _childSkillReport,
                          );
                          Navigator.of(context).pushNamed(
                              ChildCoachInfoScreen.routeName,
                              arguments: args);
                        },
                        borderColor: AdaptiveTheme.primaryColor(context),
                        //borderRadius: 10,
                      ),
                    ),
                    //WHAT NEXT BUTTON
                  ],
                ),
        ),
        // ),
      ),
    );
  }
}
