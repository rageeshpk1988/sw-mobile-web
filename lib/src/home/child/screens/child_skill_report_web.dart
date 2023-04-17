import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pretty_gauge/pretty_gauge.dart';
import 'package:expandable_text/expandable_text.dart' as expandTextPackage;
import 'package:provider/provider.dart';
import '../../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../../adaptive/adaptive_theme.dart';
import '../../../../webviews/webview_child_coach_booking.dart';

import '../../../../src/models/child_skill_summary_group.dart';
import '../../../../src/providers/child_skill_summary.dart';

import '../../../../util/app_theme.dart';
import '../../../../util/date_util.dart';
import '../../../../util/dialogs.dart';
import '../../../../util/ui_helpers.dart';
import '../../../../webviews/webview_child_coach_booking_web.dart';
import '../../../../widgets/web_banner.dart';
import '../../../../widgets/web_bottom_bar.dart';
import '../../../models/child.dart';
import '../../../models/login_response.dart';
import '../../../providers/auth.dart';
import '../../../providers/subscriptions.dart';

class ChildSkillReportScreenWeb extends StatefulWidget {
  static String routeName = '/web-child-skill-report';
  ChildSkillReportScreenWeb({Key? key}) : super(key: key);

  @override
  _ChildSkillReportScreenScreenWebState createState() =>
      _ChildSkillReportScreenScreenWebState();
}

class _ChildSkillReportScreenScreenWebState
    extends State<ChildSkillReportScreenWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  late ChildSkillCategory _childSkillCategory;
  late ChildSkillSubCategory _childSkillSubCategory;
  late ChildSkillSubCategory _selectedChildSkillSubCategory;
  late ChildSkillReport? _childSkillReport;
  bool expandWhatNext = false;

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
      LoginResponse _loginResponse;
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
      _defaultChild = Provider.of<Auth>(context, listen: false).currentChild!;

      _childSkillCategory =
          ModalRoute.of(context)!.settings.arguments as ChildSkillCategory;
      _childSkillSubCategory = _childSkillCategory.subCategoryList![0];
      _selectedChildSkillSubCategory =
          _childSkillSubCategory; //this is for the right side view

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
          height: 100,
          child: Card(
            elevation: 1.0,
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
                            width: screenWidth(context) * 0.30,
                            child: AutoSizeText(
                              subCategory.catName,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 18,
                                  letterSpacing: 0.0,
                                  color: AdaptiveTheme.secondaryColor(context),
                                  fontWeight: FontWeight.w500),
                              maxFontSize: 18,
                              maxLines: 2,
                              minFontSize: 14,
                              stepGranularity: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: screenWidth(context) * 0.30,
                        child: AutoSizeText(
                          recommendation,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 16,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w300),
                          maxFontSize: 16,
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
                                _childSkillSubCategory.catName,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontSize: 18,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500),
                                maxFontSize: 18,
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
                                    : _childSkillSubCategory.skill,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color:
                                        AdaptiveTheme.secondaryColor(context),
                                    fontSize: 18,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500),
                                maxFontSize: 18,
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

    Widget _bodyWidget() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // SizedBox(height: 20),

          const SizedBox(height: 5),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _childSkillSubCategory.subCategoryList!.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedChildSkillSubCategory =
                          _childSkillSubCategory.subCategoryList![index];
                    });
                  },
                  child: _buildCard(
                      _childSkillSubCategory.subCategoryList![index]));
            },
          ),
          const SizedBox(height: 10),
        ],
      );
    }

    Widget _whatNextButton() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: appButton(
          context: context,
          width: screenWidth(context) * 0.10,
          height: 40,
          titleFontSize: 14,
          title: 'What Next ?',
          titleColour: AdaptiveTheme.primaryColor(context),
          onPressed: () {
            setState(() {
              expandWhatNext = !expandWhatNext;
            });
          },
          borderColor: AdaptiveTheme.primaryColor(context),
          //borderRadius: 10,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WebBanner(
              showMenu: true,
              showHomeButton: true,
              showProfileButton: true,
              scaffoldKey: scaffoldKey,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50.0, top: 40),
              child: Row(
                children: [
                  Text(
                    _childSkillCategory.catName,
                    style: TextStyle(
                        letterSpacing: 0.0,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 50.0, right: 50),
              child: expandTextPackage.ExpandableText(
                _pageSubheading,
                expandText: 'See more',
                collapseText: 'See less',
                maxLines: 2,
                linkColor: Colors.grey,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 50.0),
              child: SizedBox(
                width: screenWidth(context) * 0.90,
                child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    elevation: 5.0,
                    child: _buildHeaderCard(_childSkillSubCategory.percentage)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50.0),
              child: SizedBox(
                width: screenWidth(context) * 0.90,
                child: Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      elevation: 5.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: screenWidth(context) * 0.45,
                                constraints: BoxConstraints(
                                  maxHeight: double.infinity,
                                ),
                                child: _bodyWidget(),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ChildSkillReportSubViewWeb(
                                subCategory: _selectedChildSkillSubCategory,
                              ),
                              const Divider(thickness: 1),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _whatNextButton(),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    if (expandWhatNext)
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        elevation: 5.0,
                        child: ChildCoachInfoWeb(
                          childSkillCategory: _childSkillCategory,
                          childSkillReport: _childSkillReport,
                        ),
                      )
                  ],
                ),
              ),
            ),
            WebBottomBar(),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class ChildSkillReportSubViewWeb extends StatefulWidget {
  final ChildSkillSubCategory subCategory;

  ChildSkillReportSubViewWeb({
    required this.subCategory,
    Key? key,
  }) : super(key: key);

  @override
  _ChildSkillReportSubViewWebState createState() =>
      _ChildSkillReportSubViewWebState();
}

class _ChildSkillReportSubViewWebState
    extends State<ChildSkillReportSubViewWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  var _isInIt = true;
  bool _isLoading = false;
  late Child _defaultChild;
  late String _pageDescription;

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      setState(() {
        _isLoading = true;
      });

      _defaultChild = Provider.of<Auth>(context, listen: false).currentChild!;

      Provider.of<ChildSkillSummary>(context, listen: false)
          .fetchAssessmentDescription(
              _defaultChild.childID!, widget.subCategory.catID)
          .then((value) {
        setState(() {
          _pageDescription = value;
          _isLoading = false;
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

  // to be provided title: categoryArgs.skillCategory.catName,
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: _isLoading
          ? Center(child: AdaptiveCircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  widget.subCategory.catName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Significance',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: screenWidth(context) * 0.40,
                  child: Text(
                      'this $_pageDescription this is test test test this is test test test test test this is test this is test this is test test this is test test',
                      style: TextStyle(
                        letterSpacing: 0,
                        fontSize: 16,
                      )),
                ),
              ],
            ),
    );
  }
}

class ChildCoachInfoWeb extends StatefulWidget {
  final ChildSkillCategory childSkillCategory;
  final ChildSkillReport? childSkillReport;
  ChildCoachInfoWeb({
    required this.childSkillCategory,
    this.childSkillReport,
    Key? key,
  }) : super(key: key);

  @override
  _ChildCoachInfoWebState createState() => _ChildCoachInfoWebState();
}

class _ChildCoachInfoWebState extends State<ChildCoachInfoWeb> {
  late String reportHeader;
  var _meetingStatus = false;
  var _isInIt = true;
  late Child _defaultChild;
  int _tabSelected = 0; //0-Inference, 1-Recommendations, 3-Programs

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      var authData = Provider.of<Auth>(context, listen: false);
      _defaultChild = authData.currentChild!;

      Provider.of<Subscriptions>(context, listen: false)
          .meetingStatus(authData.loginResponse.mobileNumber)
          .then((value) {
        setState(() {
          _meetingStatus = value;
        });
      });

      _isInIt = false;
    }
    super.didChangeDependencies();
  }

  void updateStatus() {
    var authData = Provider.of<Auth>(context, listen: false);
    Provider.of<Subscriptions>(context, listen: false)
        .meetingStatus(authData.loginResponse.mobileNumber)
        .then((value) {
      setState(() {
        _meetingStatus = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    reportHeader = widget.childSkillCategory.catName;

    TextStyle? _contentStyle =
        AppTheme.lightTheme.textTheme.bodySmall!.copyWith(fontSize: 14);

    // title: reportHeader,
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //TABBED VIEW
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min,
              children: [
                appButton(
                    context: context,
                    width: 90,
                    height: 25,
                    title: 'Inferences',
                    titleFontSize: 16,
                    primary: Colors.white,
                    titleColour: _tabSelected == 0
                        ? AdaptiveTheme.secondaryColor(context)
                        : Colors.black87,
                    onPressed: () {
                      _tabSelected = 0;
                      setState(() {});
                    },
                    borderColor: Colors.white,
                    borderRadius: 10),
                const SizedBox(width: 10),
                appButton(
                    context: context,
                    width: 140,
                    height: 25,
                    title: 'Recommendations',
                    titleFontSize: 16,
                    primary: Colors.white,
                    titleColour: _tabSelected == 1
                        ? AdaptiveTheme.secondaryColor(context)
                        : Colors.black87,
                    onPressed: () {
                      _tabSelected = 1;
                      setState(() {});
                    },
                    borderColor: Colors.white,
                    borderRadius: 10),
                const SizedBox(width: 10),
                appButton(
                    context: context,
                    width: 90,
                    height: 25,
                    title: 'Programs',
                    titleFontSize: 16,
                    primary: Colors.white,
                    titleColour: _tabSelected == 2
                        ? AdaptiveTheme.secondaryColor(context)
                        : Colors.black87,
                    onPressed: () {
                      _tabSelected = 2;
                      setState(() {});
                    },
                    borderColor: Colors.white,
                    borderRadius: 10),
              ],
            ),
            //TABBED VIEW
            const SizedBox(height: 10),
            //EXPANDED VIEW
            if (widget.childSkillReport != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    width: double.infinity,
                    //height: 200,
                    child: _tabSelected == 0
                        ? widget.childSkillReport!.interpretationList!.length >
                                0
                            ? Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                      color:
                                          AdaptiveTheme.secondaryColor(context)
                                              .withAlpha(90)),
                                ),
                                child: InterpretationsWidget(
                                  interpretationList: widget
                                      .childSkillReport!.interpretationList!,
                                ),
                              )
                            : Column(
                                children: [
                                  const SizedBox(height: 30),
                                  Text(
                                    'No Interpreations',
                                    style: _contentStyle,
                                  ),
                                ],
                              )
                        : _tabSelected == 1
                            ? widget.childSkillReport!.recommendationList!
                                        .length >
                                    0
                                ? Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                          color: AdaptiveTheme.secondaryColor(
                                                  context)
                                              .withAlpha(90)),
                                    ),
                                    child: RecommendationsWidget(
                                      recommendationList: widget
                                          .childSkillReport!
                                          .recommendationList!,
                                    ),
                                  )
                                : Column(
                                    children: [
                                      const SizedBox(height: 30),
                                      Text('No Recommendations',
                                          style: _contentStyle),
                                    ],
                                  )
                            : widget.childSkillReport!.programs!.length > 0
                                ? Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                          color: AdaptiveTheme.secondaryColor(
                                                  context)
                                              .withAlpha(90)),
                                    ),
                                    child: ProgramsWidget(
                                        programs:
                                            widget.childSkillReport!.programs!),
                                  )
                                : Column(
                                    children: [
                                      const SizedBox(height: 30),
                                      Text('No Program recommendations',
                                          style: _contentStyle),
                                    ],
                                  )),
              ),
            //EXPANDED VIEW

            const SizedBox(height: 20),

            //WHAT NEXT BUTTON
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  appButton(
                    context: context,
                    width: screenWidth(context) * 0.22,
                    //primary: AdaptiveTheme.primaryColor(context),
                    height: 40,
                    titleFontSize: 14,
                    title: 'Connect with a Transformation Coach',
                    titleColour: _meetingStatus == false
                        ? Colors.grey
                        : AdaptiveTheme.primaryColor(context),
                    onPressed: _meetingStatus == false
                        ? () {}
                        : () {
                            if (kIsWeb) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ChildCoachBookingWebViewWeb(
                                          updateHandler: updateStatus,
                                        )),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ChildCoachBookingWebView(
                                          updateHandler: updateStatus,
                                        )),
                              );
                            }
                          },
                    borderColor: _meetingStatus == false
                        ? Colors.grey
                        : AdaptiveTheme.primaryColor(context),
                    //borderRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class InterpretationsWidget extends StatelessWidget {
  final List<ChildReportInterpretation> interpretationList;
  const InterpretationsWidget({
    required this.interpretationList,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle _textViewStyle = AppTheme.lightTheme.textTheme.bodySmall!
        .copyWith(fontSize: 14, fontWeight: FontWeight.w300);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 8.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: interpretationList.length,
        itemBuilder: (ctx, i) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.radio_button_unchecked,
              size: 13,
            ),
            const SizedBox(width: 5),
            Flexible(
                child: Text(
              interpretationList[i].interpretation!,
              style: _textViewStyle,
            )),
          ],
        ),
      ),
    );
  }
}

class RecommendationsWidget extends StatelessWidget {
  final List<ChildReportRecommendation> recommendationList;
  const RecommendationsWidget({
    required this.recommendationList,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle _textViewStyle = AppTheme.lightTheme.textTheme.bodySmall!
        .copyWith(fontSize: 14, fontWeight: FontWeight.w300);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: recommendationList.length,
        itemBuilder: (ctx, i) => Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.radio_button_unchecked,
                  size: 13,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    recommendationList[i].recommendation!,
                    style: _textViewStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class ProgramsWidget extends StatelessWidget {
  final List<ChildReportProgram> programs;
  const ProgramsWidget({
    required this.programs,
    //required this.credentials,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle _textViewStyle = AppTheme.lightTheme.textTheme.bodySmall!
        .copyWith(fontSize: 14, fontWeight: FontWeight.w300);
    Widget _buildCredentialList(List<ChildReportCredential> credentials) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 8.0),
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: credentials.length,
          itemBuilder: (ctx, i) => Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    child: Text(credentials[i].credentialsKey!,
                        style: _textViewStyle),
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      height: 30,
                      width: 40,
                      // margin: EdgeInsets.only(top: 40, left: 40, right: 40),
                      decoration: new BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.grey.shade50, width: 0.0),
                          borderRadius:
                              new BorderRadius.all(Radius.elliptical(100, 50)),
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 10.0,
                            ),
                          ]),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          credentials[i].credentialsValue!.toString(),
                          style: _textViewStyle.copyWith(
                              color: AdaptiveTheme.primaryColor(context),
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 8.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: programs.length,
        itemBuilder: (ctx, i) => SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  programs[i].programImage == null
                      ? Icon(
                          Icons.image_not_supported_sharp,
                          size: 50,
                        )
                      : CachedNetworkImage(
                          imageUrl: appImageUrl(programs[i].programImage!),
                          imageBuilder: (context, imageProvider) => Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.fill),
                            ),
                          ),
                          // placeholder: (context, url) =>
                          //     Center(child: AdaptiveCircularProgressIndicator()),
                          errorWidget: (context, url, error) => SizedBox(
                            width: 60,
                            height: 60,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported_outlined,
                                    size: 40,
                                    color: AdaptiveTheme.primaryColor(context)),
                              ],
                            ),
                          ),
                        ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, top: 8.0),
                        child: SizedBox(
                          width: 220,
                          child: Text(programs[i].programName!,
                              style: _textViewStyle.copyWith(
                                  fontWeight: FontWeight.w400)),
                        ),
                      ),
                      // Text(programs[i].recommendedDate)
                      const SizedBox(height: 10),
                      // Text(programs[i].reviews!.first.comment!),
                      // SizedBox(height: 5),
                      if (programs[i].reviews!.isNotEmpty)
                        RatingBar.builder(
                          initialRating: programs[i].reviews!.first.rating!,
                          itemSize: 25,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          //  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {},
                        )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(thickness: 1.0),
            ],
          ),
        ),
      ),
    );
  }
}
