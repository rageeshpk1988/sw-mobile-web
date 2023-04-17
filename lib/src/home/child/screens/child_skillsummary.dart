import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../../webviews/webview_assessment.dart';
import '../../../../src/home/child/screens/child_skill_report.dart';
import '../../../../src/models/child_skill_summary_group.dart';
import '../../../../src/providers/child_skill_summary.dart';

import '../../../../adaptive/adaptive_theme.dart';
import '../../../../helpers/route_arguments.dart';
import '../../../../util/app_theme.dart';
import '../../../../util/app_theme_cupertino.dart';
import '../../../../util/date_util.dart';
import '../../../../util/dialogs.dart';
import '../../../../util/ui_helpers.dart';
import '../../../../adaptive/adaptive_custom_appbar.dart';
import '../../../models/getquestion_request.dart';
import '../../../models/login_response.dart';
import '../../../models/parent_subscription.dart';
import '../../../providers/auth.dart';
import '../../../providers/subscriptions.dart';
import '../../../subscription/screens/mySubscriptionPlan.dart';
import '../../../subscription/screens/subcriptionsPlans.dart';

class ChildSkillsummaryScreen extends StatefulWidget {
  static String routeName = '/child-skill-summary';
  ChildSkillsummaryScreen({Key? key}) : super(key: key);

  @override
  _ChildSkillsummaryScreenScreenState createState() =>
      _ChildSkillsummaryScreenScreenState();
}

class _ChildSkillsummaryScreenScreenState
    extends State<ChildSkillsummaryScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  ChildSkillSummaryGroup? _childSkillSummaryGroup;
  late int noviceCount = 0;
  late int developingCount = 0;
  late int proficientCount = 0;
  bool _isLoading = false;
  var _isEnabled = false;

  var _isInIt = true;
  @override
  void didChangeDependencies() {
    if (_isInIt) {
      setState(() {
        _isLoading = true;
      });
      var parentId = Provider.of<Auth>(context, listen: false)
          .loginResponse
          .b2cParent!
          .parentID;
      var child = Provider.of<Auth>(context, listen: false).currentChild;
      //TODO ::: platform type has to be changed based on OS
      Provider.of<ChildSkillSummary>(context, listen: false)
          .fetchAndSetSkillSummary(child!, parentId, 'android')
          .then((value) {
        setState(() {
          _childSkillSummaryGroup =
              Provider.of<ChildSkillSummary>(context, listen: false)
                  .skillSummaryGroup!;
          if (_childSkillSummaryGroup != null) {
            noviceCount = _calculateSkillCount(1);
            developingCount = _calculateSkillCount(2);
            proficientCount = _calculateSkillCount(3);
          }
          _isLoading = false;
        });
      }).onError((error, stackTrace) {
        setState(() {
          Dialogs().ackAlert(context, 'Data Error', error.toString());
          _isLoading = false;
        });
      });

      _isInIt = false;
    }
    super.didChangeDependencies();
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

  Future<String> verifySubscriptionPackage() async {
    late ParentSubscriptionGroup? parentSubscription;
    String retValue = "nopackage";
    var loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;

    var parentId = loginResponse.b2cParent!.parentID;
    //var authToken = loginResponse.token;
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

  int _calculateSkillCount(int skilltype) {
    String skill;
    int skillCount = 0;
    if (skilltype == 1) {
      skill = 'Novice';
    } else if (skilltype == 2) {
      skill = 'Developing';
    } else {
      skill = 'Proficient';
    }
    if (_childSkillSummaryGroup!.categoryList!.length > 0) {
      for (ChildSkillCategory cat in _childSkillSummaryGroup!.categoryList!) {
        if (cat.subCategoryList![0].percentage != 0.0 &&
            cat.subCategoryList![0].skill.toLowerCase() ==
                skill.toLowerCase()) {
          skillCount++;
        }
      }
    }

    return skillCount;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24 - 120) / 2;
    final double itemWidth = size.width / 2;
    final interestArgs =
        ModalRoute.of(context)!.settings.arguments as InterestArgs;
    Widget _buildTitleCard(String title, String count, Color color) {
      return Stack(
        children: [
          Container(
            width: 115,
            height: 30,
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: color),
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.white,
            ),
          ),
          Positioned(
            left: 18,
            top: 7,
            child: Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w400),
                maxFontSize: textScale(context) <= 1.0 ? 13 : 11,
                maxLines: 1,
                minFontSize: 9,
                stepGranularity: 1,
              ),
            ),
            // child: Text(
            //   title,
            //   style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            // ),
          ),
          Positioned(
            top: 3,
            right: 3,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: Center(
                child: AutoSizeText(
                  count,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                  maxFontSize: 12,
                  maxLines: 1,
                  minFontSize: 9,
                  stepGranularity: 1,
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget _innerCard(
      String title,
      String? selectedImageUrl,
      String? selectedKidImageUrl,
    ) {
      return Stack(
        children: [
          SizedBox(
            width: 100,
            height: 70,
            child: Image(
              image: AssetImage(
                selectedImageUrl != null
                    ? selectedImageUrl
                    : 'assets/images/emptyskill.png',
              ),
              width: 40,
              height: 60,
            ),
          ),
          if (selectedKidImageUrl != null)
            Positioned(
              top: -4,
              right: -5,
              child: Image(
                image: AssetImage(selectedKidImageUrl),
              ),
            ),
          Positioned(
            left: 30,
            top: 28,
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w400,
                  color:
                      selectedImageUrl != null ? Colors.white : Colors.black),
            ),
          ),
        ],
      );
    }

    Widget _buildCard(ChildSkillCategory category) {
      String? statusCardImageUrl;
      String? statusKidImageUrl;
      switch (category.subCategoryList![0].skill.toLowerCase()) {
        case '':
          statusCardImageUrl = null;
          break;
        case 'novice':
          statusCardImageUrl = 'assets/images/novice.png';
          statusKidImageUrl = 'assets/images/novicekid.png';
          break;
        case 'developing':
          statusCardImageUrl = 'assets/images/developing.png';
          statusKidImageUrl = 'assets/images/developingkid.png';
          break;
        case 'proficient':
          statusCardImageUrl = 'assets/images/proficient.png';
          statusKidImageUrl = 'assets/images/proficientkid.png';

          break;
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
        child: Container(
          width: double.infinity,
          height: 170,
          child: Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 8.0, 1.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 20,
                    child: AutoSizeText(
                      category.catName,
                      style: const TextStyle(
                          fontSize: 18,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500),
                      maxFontSize: textScale(context) <= 1.0 ? 18 : 11,
                      maxLines: 2,
                      minFontSize: 11,
                      stepGranularity: 1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _innerCard(
                          'Novice',
                          category.subCategoryList![0].percentage != 0.0 &&
                                  category.subCategoryList![0].skill
                                          .toLowerCase() ==
                                      'novice'
                              ? statusCardImageUrl!
                              : null,
                          category.subCategoryList![0].percentage != 0.0 &&
                                  category.subCategoryList![0].skill
                                          .toLowerCase() ==
                                      'novice'
                              ? statusKidImageUrl!
                              : null),
                      _innerCard(
                          'Developing',
                          category.subCategoryList![0].percentage != 0.0 &&
                                  category.subCategoryList![0].skill
                                          .toLowerCase() ==
                                      'developing'
                              ? statusCardImageUrl
                              : null,
                          category.subCategoryList![0].percentage != 0.0 &&
                                  category.subCategoryList![0].skill
                                          .toLowerCase() ==
                                      'developing'
                              ? statusKidImageUrl!
                              : null),
                      _innerCard(
                          'Proficient',
                          category.subCategoryList![0].percentage != 0.0 &&
                                  category.subCategoryList![0].skill
                                          .toLowerCase() ==
                                      'proficient'
                              ? statusCardImageUrl
                              : null,
                          category.subCategoryList![0].percentage != 0.0 &&
                                  category.subCategoryList![0].skill
                                          .toLowerCase() ==
                                      'proficient'
                              ? statusKidImageUrl!
                              : null),
                    ],
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (category.subCategoryList![0].percentage != 0.0)
                        GestureDetector(
                          onTap: () {
                            if (category.subCategoryList != null) {
                              Navigator.of(context).pushNamed(
                                  ChildSkillReportScreen.routeName,
                                  arguments: category);
                            }
                          },
                          child: Text(
                            'View Report',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue),
                          ),
                        ),
                      Spacer(),
                      if (category.subCategoryList![0].percentage == 0.0)
                        GestureDetector(
                          onTap: _isEnabled
                              ? () {}
                              : () async {
                                  setState(() {
                                    _isEnabled = true;
                                  });
                                  LoginResponse loginResponse =
                                      Provider.of<Auth>(context, listen: false)
                                          .loginResponse;
                                  String result =
                                      await verifySubscriptionPackage();

                                  if (result == "nopackage") {
//show the info message
                                    await _showNoPackagePopup(
                                        loginResponse.b2cParent!.name);
                                    //show plans list

                                    setState(() {
                                      _isEnabled = false;
                                    });
                                  } else if (result == "over") {
                                    await _showOverPackagePopup(
                                        loginResponse.b2cParent!.name);
                                    //show myPlans page
                                    Navigator.of(context).pushNamed(
                                        MySubscriptionPlanScreen.routeName);

                                    setState(() {
                                      _isEnabled = false;
                                    });
                                  } else {
                                    var _defaultChild = Provider.of<Auth>(
                                            context,
                                            listen: false)
                                        .currentChild!;
                                    int age =
                                        DateUtil.getAge(_defaultChild.dob!);
                                    GetQuestionReq getQuestionReq =
                                        GetQuestionReq(
                                            childName: '${_defaultChild.name}',
                                            countryCode:
                                                '${_defaultChild.countryID}',
                                            hierarchyId: '${category.catID}',
                                            currentLeafId: '0',
                                            studentId:
                                                '${_defaultChild.childID}',
                                            hierarchyCount: '7',
                                            age: '$age',
                                            assessmentName:
                                                '${category.catName}');
                                    // print(getQuestionReq.toString());
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              WebViewAssessment(
                                                getQuestionReq: getQuestionReq,
                                                updateChildData:
                                                    interestArgs.updateHandler,
                                              )),
                                    );
                                    setState(() {
                                      _isEnabled = false;
                                    });
                                  }
                                },
                          child: Row(
                            children: [
                              Text(
                                'Take Test',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue),
                              ),
                              const SizedBox(width: 10),
                              Image(
                                image: AssetImage(
                                  'assets/images/testarrow.png',
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
        title: "Skill Summary",
        showMascot: true,
      ),
      body: _isLoading
          ? Center(
              child: AdaptiveCircularProgressIndicator(),
            )
          : Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    //TITLE CARD
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildTitleCard('Novice', noviceCount.toString(),
                                HexColor.fromHex('#EC6E99')),
                            const SizedBox(
                              width: 10,
                            ),
                            _buildTitleCard(
                                'Developing',
                                developingCount.toString(),
                                HexColor.fromHex('#5BC4E6')),
                            const SizedBox(
                              width: 10,
                            ),
                            _buildTitleCard(
                                'Proficient',
                                proficientCount.toString(),
                                HexColor.fromHex('#3FD27F')),
                          ],
                        ),
                      ),
                    ),
                    //TITLE CARD
                    const SizedBox(height: 20),
                    //SUMMARY CARDS
                    if (_childSkillSummaryGroup != null)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: GridView(
                            scrollDirection: Axis.vertical,
                            physics: const BouncingScrollPhysics(),
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            children: _childSkillSummaryGroup!.categoryList!
                                .map(
                                  (category) => InkWell(
                                    onTap: () {
                                      //
                                    },
                                    child: _buildCard(category),
                                  ),
                                )
                                .toList(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: (itemWidth / itemHeight * 3.0),
                              crossAxisCount: 1,
                              crossAxisSpacing: 5.0,
                              mainAxisSpacing: 5.0,
                            ),
                          ),
                        ),
                      )
                    //SUMMARY CARDS
                  ],
                ),
              ],
            ),
    );
  }
}
