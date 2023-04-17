import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// import 'package:expandable_text/expandable_text.dart' as expandTextPackage;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../../../providers/subscriptions.dart';
import '/adaptive/adaptive_theme.dart';
import '/helpers/route_arguments.dart';
import '../../../../webviews/webview_child_coach_booking.dart';
import '/util/app_theme.dart';
import '/util/app_theme_cupertino.dart';

import '../../../../adaptive/adaptive_custom_appbar.dart';

import '../../../../util/ui_helpers.dart';

import '../../../models/child_skill_summary_group.dart';

import '../../../providers/auth.dart';

class ChildCoachInfoScreen extends StatefulWidget {
  static String routeName = '/child-coach-info';
  ChildCoachInfoScreen({Key? key}) : super(key: key);

  @override
  _ChildCoachInfoScreenState createState() => _ChildCoachInfoScreenState();
}

class _ChildCoachInfoScreenState extends State<ChildCoachInfoScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  late ChildSkillCategory _childSkillCategory;
  late String reportHeader;
  late ChildSkillReport? _childSkillReport;
  var _meetingStatus = false;
  var _isInIt = true;
  // late Child _defaultChild;
  int _tabSelected = 0; //0-Inference, 1-Recommendations, 3-Programs

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      var authData = Provider.of<Auth>(context, listen: false);
      //_defaultChild = authData.currentChild!;

      SkillReportAndCategoryArgs args = ModalRoute.of(context)!
          .settings
          .arguments as SkillReportAndCategoryArgs;
      _childSkillCategory = args.skillCategory;
      _childSkillReport = args.skillReport!;

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
    reportHeader = _childSkillCategory.catName;

    TextStyle? _contentStyle = kIsWeb || Platform.isAndroid
        ? AppTheme.lightTheme.textTheme.bodySmall!.copyWith(fontSize: 14)
        : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
            .copyWith(fontSize: 14);
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
        title: reportHeader,
        showMascot: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    appButton(
                        context: context,
                        width: 90,
                        height: 20,
                        title: 'Inferences',
                        titleFontSize: textScale(context) <= 1.0 ? 15 : 12,
                        primary: Colors.white,
                        titleColour: _tabSelected == 0
                            ? AdaptiveTheme.secondaryColor(context)
                            : Colors.black87,
                        onPressed: () {
                          _tabSelected = 0;
                          setState(() {});
                        },
                        borderColor: Colors.white,
                        borderRadius: 20),
                    appButton(
                        context: context,
                        width: 140,
                        height: 20,
                        title: 'Recommendations',
                        titleFontSize: textScale(context) <= 1.0 ? 15 : 12,
                        primary: Colors.white,
                        titleColour: _tabSelected == 1
                            ? AdaptiveTheme.secondaryColor(context)
                            : Colors.black87,
                        onPressed: () {
                          _tabSelected = 1;
                          setState(() {});
                        },
                        borderColor: Colors.white,
                        borderRadius: 20),
                    appButton(
                        context: context,
                        width: 90,
                        height: 20,
                        title: 'Programs',
                        titleFontSize: textScale(context) <= 1.0 ? 15 : 12,
                        primary: Colors.white,
                        titleColour: _tabSelected == 2
                            ? AdaptiveTheme.secondaryColor(context)
                            : Colors.black87,
                        onPressed: () {
                          _tabSelected = 2;
                          setState(() {});
                        },
                        borderColor: Colors.white,
                        borderRadius: 20),
                  ],
                ),
                //TABBED VIEW
                const SizedBox(height: 10),
                //EXPANDED VIEW
                if (_childSkillReport != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        width: double.infinity,
                        //height: 200,
                        child: _tabSelected == 0
                            ? _childSkillReport!.interpretationList!.length > 0
                                ? Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                          color: AdaptiveTheme.secondaryColor(
                                                  context)
                                              .withAlpha(90)),
                                    ),
                                    child: InterpretationsWidget(
                                      interpretationList: this
                                          ._childSkillReport!
                                          .interpretationList!,
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
                                ? _childSkillReport!
                                            .recommendationList!.length >
                                        0
                                    ? Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          border: Border.all(
                                              color:
                                                  AdaptiveTheme.secondaryColor(
                                                          context)
                                                      .withAlpha(90)),
                                        ),
                                        child: RecommendationsWidget(
                                          recommendationList: this
                                              ._childSkillReport!
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
                                : _childSkillReport!.programs!.length > 0
                                    ? Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          border: Border.all(
                                              color:
                                                  AdaptiveTheme.secondaryColor(
                                                          context)
                                                      .withAlpha(90)),
                                        ),
                                        child: ProgramsWidget(
                                            programs: this
                                                ._childSkillReport!
                                                .programs!),
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
                // Text(
                //   'Transformation Coach',
                //   style: TextStyle(
                //       fontWeight: FontWeight.w500, letterSpacing: 0.0),
                // ),
                // SizedBox(height: 10),
                // expandTextPackage.ExpandableText(
                //   'This is a dummy text for testing the screen layout. This is a dummy text for testing the screen layout. This is a dummy text for testing the screen layout. ',
                //   expandText: 'See more',
                //   collapseText: 'See less',
                //   maxLines: 4,
                //   linkColor: Colors.grey,
                // ),
                const SizedBox(height: 20),

                //WHAT NEXT BUTTON
                appButton(
                  context: context,
                  width: double.infinity,
                  // primary: AdaptiveTheme.primaryColor(context),
                  height: 40,
                  titleFontSize: 14,
                  title: 'Connect with a Transformation Coach',
                  titleColour: _meetingStatus == false
                      ? Colors.grey
                      : AdaptiveTheme.primaryColor(context),
                  onPressed: _meetingStatus == false
                      ? () {}
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChildCoachBookingWebView(
                                      updateHandler: updateStatus,
                                    )),
                          );
                        },
                  borderColor: _meetingStatus == false
                      ? Colors.grey
                      : AdaptiveTheme.primaryColor(context),
                  //borderRadius: 10,
                ),
                const SizedBox(height: 20),
                //WHAT NEXT BUTTON
                // Text(
                //   'Advanced Assessment',
                //   style: TextStyle(
                //       fontWeight: FontWeight.w500, letterSpacing: 0.0),
                // ),
                // SizedBox(height: 10),
                // expandTextPackage.ExpandableText(
                //   'This is a dummy text for testing the screen layout. This is a dummy text for testing the screen layout. This is a dummy text for testing the screen layout. ',
                //   expandText: 'See more',
                //   collapseText: 'See less',
                //   maxLines: 4,
                //   linkColor: Colors.grey,
                // ),
                // SizedBox(height: 20),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     Text('Would you like to go for ', style: _contentStyle),
                //     GestureDetector(
                //       onTap: () {
                //         //Currently this functionality is not available
                //         Dialogs().ackAlert(context, 'Advanced Assesment',
                //             'We are working on this feature and will be available to you soon!');
                //         return;

                //         // todo:: This needs to be enabled
                //         // var _defaultChild =
                //         //     Provider.of<Auth>(context, listen: false)
                //         //         .currentChild!;
                //         // int age = DateUtil.getAge(_defaultChild.dob!);
                //         // GetQuestionReq getQuestionReq = GetQuestionReq(
                //         //     childName: '${_defaultChild.name}',
                //         //     countryCode: '${_defaultChild.countryID}',
                //         //     hierarchyId: '0', // '${category.catID}',
                //         //     currentLeafId: '0',
                //         //     studentId: '${_defaultChild.childID}',
                //         //     hierarchyCount: '7',
                //         //     age: '$age',
                //         //     assessmentName: '' // '${category.catName}'
                //         //     );
                //         // // print(getQuestionReq.toString());
                //         // Navigator.push(
                //         //   context,
                //         //   MaterialPageRoute(
                //         //       builder: (context) => WebViewAssessmentTemp(
                //         //             getQuestionReq: getQuestionReq,
                //         //           )),
                //         // );
                //       },
                //       child: Row(
                //         children: [
                //           Text('Advanced Assessment',
                //               style: _contentStyle.copyWith(
                //                   fontWeight: FontWeight.w500,
                //                   color: AdaptiveTheme.primaryColor(context),
                //                   letterSpacing: 0.0)),
                //           SizedBox(height: 10),
                //           Icon(
                //             Icons.arrow_forward,
                //             color: AdaptiveTheme.primaryColor(context),
                //           )
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
        // ),
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
    TextStyle _textViewStyle = kIsWeb || Platform.isAndroid
        ? AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontSize: 14, fontWeight: FontWeight.w300)
        : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
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
    TextStyle _textViewStyle = kIsWeb || Platform.isAndroid
        ? AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontSize: 14, fontWeight: FontWeight.w300)
        : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
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
    TextStyle _textViewStyle = kIsWeb || Platform.isAndroid
        ? AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontSize: 14, fontWeight: FontWeight.w300)
        : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
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
              //This is commented and have to be enabled at later stage
              // Padding(
              //   padding: const EdgeInsets.only(left: 8.0),
              //   child: Text(
              //     'Credentials',
              //     style: _textViewStyle.copyWith(
              //         fontWeight: FontWeight.w500, fontSize: 15),
              //   ),
              // ),
              // _buildCredentialList(programs[i].credentials!),
              Divider(thickness: 1.0),
            ],
          ),
        ),
      ),
    );
  }
}
