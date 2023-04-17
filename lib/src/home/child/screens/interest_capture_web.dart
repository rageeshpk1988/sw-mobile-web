import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '/src/home/child/screens/child_recomendations_web.dart';
import '../../../../src/providers/interest_capture.dart';
import '../../../../adaptive/adaptive_circular_progressInd.dart';

import '../../../../adaptive/adaptive_theme.dart';
import '../../../../helpers/connectivity_helper.dart';
import '../../../../helpers/route_arguments.dart';
import '../../../../helpers/shared_pref_data.dart';
import '../../../../util/app_theme.dart';

import '../../../../util/dialogs.dart';
import '../../../../util/ui_helpers.dart';
import '../../../../widgets/web_banner.dart';
import '../../../../widgets/web_bottom_bar.dart';
import '../../../models/interest_qa.dart';
import 'package:collection/collection.dart';

import '../../../providers/auth.dart';

class InterestCaptureScreenWeb extends StatefulWidget {
  // final Function? updateHandler;
  static String routeName = '/web-interest-capture';
  const InterestCaptureScreenWeb({
    Key? key,
  }) : super(key: key);

  @override
  _InterestCaptureTempScreenWebState createState() =>
      _InterestCaptureTempScreenWebState();
}

class _InterestCaptureTempScreenWebState
    extends State<InterestCaptureScreenWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  QuestionAnswer? questionAnswer;
  QuestionAnswer? firstQuestion;
  QuestionAnswer? lastQuestion;
  List<QuestionAnswer>? finalQuestionList;
  bool _isLoading = false;
  List<Choice>? finalChoices;
  InterestQA? qa;
  Future? loader;
  bool _isInIt = true;
  int? parentId;
  int? childId;
  int? blockNumber;

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      parentId = Provider.of<Auth>(context, listen: false)
          .loginResponse
          .b2cParent!
          .parentID;
      childId = Provider.of<Auth>(context, listen: false).currentChild!.childID;
      _initialLoader();
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

  //Update local stored object ( provider)
  //first update local object
  //server update
  //if server calls fails then revoke local update

  Future<bool> _continueLater(Function updateHandler) {
    return showDialog(
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          width: screenWidth(context) * 0.30,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 25),
              Image.asset('assets/icons/alert_info.png', width: 40, height: 40),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Save your progress and continue later",
                style: AppTheme.lightTheme.textTheme.bodyMedium!
                    .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 25,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  appButton(
                    context: context,
                    width: screenWidth(context) *
                        (screenWidth(context) > 800 ? 0.10 : 0.40),
                    height: 35,
                    title: 'Yes',
                    titleColour: AdaptiveTheme.primaryColor(context),
                    borderColor: AdaptiveTheme.primaryColor(context),
                    onPressed: () {
                      updateHandler(childId);
                      int count = 0;
                      Navigator.of(context).popUntil((_) => count++ >= 2);
                    },
                  ),
                  verticalSpaceSmall,
                  appButton(
                    context: context,
                    width: screenWidth(context) *
                        (screenWidth(context) > 800 ? 0.10 : 0.40),
                    height: 35,
                    title: 'No',
                    titleColour: HexColor.fromHex("#333333"),
                    borderColor: HexColor.fromHex('#C9C9C9'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
      context: context,
    ).then((value) => value ?? false);
  }

  Future _nextBlock(BuildContext context, Function updateHandler) {
    return showDialog(
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: screenWidth(context) * 0.40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 25,
                ),
                Text(
                  blockNumber != null
                      ? "${popupMessagesList[blockNumber!]}"
                      : "Thank you for participating. Just a few more to go!",
                  style: AppTheme.lightTheme.textTheme.bodyMedium!
                      .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                verticalSpaceRegular,
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        appButton(
                          context: context,
                          width: screenWidth(context) *
                              (screenWidth(context) > 800 ? 0.10 : 0.40),
                          height: 35,
                          titleFontSize: 14,
                          title: 'View',
                          titleColour: AdaptiveTheme.primaryColor(context),
                          borderColor: AdaptiveTheme.primaryColor(context),
                          onPressed: () async {
                            updateHandler(childId);
                            Navigator.of(context).pop();
                            int updatedCount =
                                blockNumber != null ? blockNumber! + 1 : 1;
                            await SharedPrefData.setBlockCounter(
                                childId!, updatedCount);
                            if (await ConnectivityHelper.hasInternet(
                                    context,
                                    ChildRecomendationsScreenWeb.routeName,
                                    InterestArgs(updateHandler)) ==
                                true) {
                              Navigator.of(context).pushReplacementNamed(
                                  ChildRecomendationsScreenWeb.routeName,
                                  arguments: InterestArgs(updateHandler));
                            }
                          },
                        ),
                        verticalSpaceSmall,
                        Text(
                          "Child's interest and recommended assessments based on the assessments given so far",
                          style: AppTheme.lightTheme.textTheme.bodyMedium!
                              .copyWith(
                                  fontSize: 11, fontWeight: FontWeight.w300),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    verticalSpaceSmall,
                    Text(
                      "or",
                      style: AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AdaptiveTheme.secondaryColor(context)),
                      textAlign: TextAlign.center,
                    ),
                    verticalSpaceSmall,
                    Column(
                      children: [
                        appButton(
                          context: context,
                          width: screenWidth(context) *
                              (screenWidth(context) > 800 ? 0.10 : 0.40),
                          height: 35,
                          titleFontSize: 14,
                          title: 'Continue',
                          titleColour: AdaptiveTheme.secondaryColor(context),
                          borderColor: AdaptiveTheme.secondaryColor(context),
                          onPressed: blockNumber == 9
                              ? null
                              : () async {
                                  updateHandler(childId);
                                  int updatedCount = blockNumber != null
                                      ? blockNumber! + 1
                                      : 1;
                                  await SharedPrefData.setBlockCounter(
                                      childId!, updatedCount);
                                  loader = _initialLoader();
                                  Navigator.of(context).pop();
                                },
                        ),
                        verticalSpaceSmall,
                        Center(
                            child: Text(
                          "With more areas of your child’s interests",
                          style: AppTheme.lightTheme.textTheme.bodyMedium!
                              .copyWith(
                                  fontSize: 11, fontWeight: FontWeight.w300),
                          textAlign: TextAlign.center,
                        )),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 25,
                )
              ],
            ),
          ),
        ),
      ),
      context: context,
    );
  }
  //dialog for final exit

  Future _allDone(BuildContext context, Function updateHandler) {
    return showDialog(
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 32.0, right: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 25,
              ),
              Text(
                "Congratulations!- You have completed the first level of the Child Transformation Process.Discover more about your child by using the assessment suggestions.It is equally rewarding for us to see your child's Talents develop.",
                style: AppTheme.lightTheme.textTheme.bodyMedium!
                    .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 18,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  appButton(
                    context: context,
                    width: double.infinity,
                    height: 35,
                    titleFontSize: textScale(context) <= 1.0 ? 14 : 10,
                    title: 'View',
                    titleColour: AdaptiveTheme.primaryColor(context),
                    borderColor: AdaptiveTheme.primaryColor(context),
                    onPressed: () async {
                      updateHandler(childId);
                      Navigator.of(context).pop();
                      if (await ConnectivityHelper.hasInternet(
                              context,
                              ChildRecomendationsScreenWeb.routeName,
                              InterestArgs(updateHandler)) ==
                          true) {
                        Navigator.of(context).pushReplacementNamed(
                            ChildRecomendationsScreenWeb.routeName,
                            arguments: InterestArgs(updateHandler));
                      }
                    },
                  ),
                  verticalSpaceSmall,
                  Text(
                    "Child's interest and recommended assessments based on the assessments given so far",
                    style: AppTheme.lightTheme.textTheme.bodyMedium!
                        .copyWith(fontSize: 11, fontWeight: FontWeight.w300),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              )
            ],
          ),
        ),
      ),
      context: context,
    );
  }

//First loader to load data initially
  _initialLoader() async {
    setState(() {
      _isLoading = true;
    });
    int? blockCount = await SharedPrefData.getBlockCounter(childId!);
    Provider.of<InterestCapture>(context, listen: false)
        .fetchAndSetInterestQAs(childId!, parentId!)
        .then((_) {
      setState(() {
        blockNumber = blockCount;
        qa = Provider.of<InterestCapture>(context, listen: false).interestQA;
        final List<QuestionAnswer> loadedQuestions = qa!.questionAnswers!;
        final List<Choice> loadedChoices = qa!.choices!;
        var tempQues =
            loadedQuestions.firstWhere((element) => element.answerId == 0);
        finalQuestionList = loadedQuestions;
        finalChoices = loadedChoices;
        firstQuestion = loadedQuestions.first;
        lastQuestion = loadedQuestions.last;
        questionAnswer = tempQues;
        _isLoading = false;
      });
    }).onError((error, stackTrace) {
      setState(() {
        Dialogs().ackAlert(context, 'Data Error', error.toString());
      });
    });
    ;
  }

  void updateLocalAnswer(QuestionAnswer? questionAnswer) {
    finalQuestionList![finalQuestionList!.indexWhere(
            (element) => element.questionNo == questionAnswer?.questionNo)] =
        questionAnswer!;
  }

  //Next button function
  _next(Function updateHandler) async {
    if (_verType != null) {
      if (questionAnswer != lastQuestion) {
        updateLocalAnswer(questionAnswer);
        setState(() {
          _isLoading = true;
        });
        var updateAnswer =
            await Provider.of<InterestCapture>(context, listen: false)
                .updateAnswer(parentId!, childId!, false, questionAnswer!)
                .onError((error, stackTrace) {
          setState(() {
            _isLoading = false;
          });
          return false;
        });
        ;
        if (updateAnswer == true) {
          updateHandler(childId);
          var tempQues = finalQuestionList!.firstWhere((element) =>
              element.questionNo == questionAnswer!.questionNo + 1);
          setState(() {
            questionAnswer = tempQues;
            _verType = finalChoices!.firstWhereOrNull(
                (element) => element.choiceId == tempQues.answerId);
            _isLoading = false;
          });
        } else {
          Fluttertoast.showToast(
              msg:
                  "The requested service is not available at the moment. Please try again later!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        // print("${qa!.moreRecords}");
        if (qa!.moreRecords == true) {
          updateLocalAnswer(questionAnswer);
          setState(() {
            _isLoading = true;
          });
          var updateAnswer =
              await Provider.of<InterestCapture>(context, listen: false)
                  .updateAnswer(parentId!, childId!, true, questionAnswer!)
                  .onError((error, stackTrace) {
            setState(() {
              _isLoading = false;
            });
            return false;
          });
          ;
          if (updateAnswer == true) {
            updateHandler(childId);
            _nextBlock(context, updateHandler);
            setState(() {
              _isLoading = false;
            });
          } else {
            Fluttertoast.showToast(
                msg:
                    "The requested service is not available at the moment. Please try again later!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          updateLocalAnswer(questionAnswer);
          setState(() {
            _isLoading = true;
          });
          var updateAnswer =
              await Provider.of<InterestCapture>(context, listen: false)
                  .updateAnswer(parentId!, childId!, true, questionAnswer!)
                  .onError((error, stackTrace) {
            setState(() {
              _isLoading = false;
            });
            return false;
          });
          ;
          if (updateAnswer == true) {
            updateHandler(childId);
            _allDone(context, updateHandler);
            setState(() {
              _isLoading = false;
            });
          } else {
            Fluttertoast.showToast(
                msg:
                    "The requested service is not available at the moment. Please try again later!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please Select An Answer To Continue",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        _isLoading = false;
      });
    }
  }

  //Previous button function
  _previous(Function updateHandler) async {
    if (_verType != null) {
      if (questionAnswer != firstQuestion) {
        updateLocalAnswer(questionAnswer);
        setState(() {
          _isLoading = true;
        });
        var updateAnswer =
            await Provider.of<InterestCapture>(context, listen: false)
                .updateAnswer(parentId!, childId!, false, questionAnswer!)
                .onError((error, stackTrace) {
          setState(() {
            _isLoading = false;
          });
          return false;
        });
        ;
        if (updateAnswer == true) {
          var tempQues = finalQuestionList!.firstWhere((element) =>
              element.questionNo == questionAnswer!.questionNo - 1);
          setState(() {
            questionAnswer = tempQues;
            _verType = finalChoices!.firstWhereOrNull(
                (element) => element.choiceId == tempQues.answerId);
            _isLoading = false;
          });
        } else {
          Fluttertoast.showToast(
              msg:
                  "The requested service is not available at the moment. Please try again later!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        Fluttertoast.showToast(
            msg: "Cannot go back further",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      if (questionAnswer != firstQuestion) {
        var tempQues = finalQuestionList!.firstWhere(
            (element) => element.questionNo == questionAnswer!.questionNo - 1);
        setState(() {
          questionAnswer = tempQues;
          _verType = finalChoices!.firstWhereOrNull(
              (element) => element.choiceId == tempQues.answerId);
          _isLoading = false;
        });
      } else {
        Fluttertoast.showToast(
            msg: "Cannot go back further",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  Choice? _verType = null;
  List<Color> colors = [
    Color(0xff5224ED),
    Color(0xffD18718),
    Color(0xff1DB591),
    Color(0xffED4D24),
    Color(0xff2496ED)
  ];
  List<String> popupMessagesList = [
    "We appreciate your patience in completing the first set of questions. Your prompt response gives us a better understanding of your child's interests.",
    "Thank you for taking the time to answer the second set of questions. You're doing well!",
    "We appreciate your time spent on the third set of questions. Good Going!",
    "Thank you for taking up the fourth set of questions. We are nearly halfway there!",
    "Hurray!!! 50%- HalfWay Completed",
    "We appreciate your willingness to answer the sixth set of questions. Keep Going!",
    "Thank you for participating in the seventh set of questions. Just a few more to go!",
    "Much obliged. Thank you for completing the eighth set of questions.",
    "Good job! We've done with the ninth set of questions. You're almost there- Finish line Ahead.",
    "Congratulations!- You have completed the first level of the Child Transformation Process.Discover more about your child by using the assessment suggestions.It is equally rewarding for us to see your child's Talents develop.",
  ];
  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    var screenwidth = deviceSize.width - 32;
    double textScale = MediaQuery.textScaleFactorOf(context);
    final AutoSizeGroup descGroup = AutoSizeGroup();
    final interestArgs =
        ModalRoute.of(context)!.settings.arguments as InterestArgs;

    Widget _bodyWidgetLargeScreen() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 50.0, top: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Situation -',
                  style: AppTheme.lightTheme.textTheme.bodyMedium!
                      .copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                horizontalSpaceTiny,
                Text(
                  '${questionAnswer!.questionNo}',
                  style: AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AdaptiveTheme.primaryColor(context)),
                ),
                horizontalSpaceTiny,
                Text(
                  '/47', //TODO: replace this value with the value we get from /child-interest-service/api/v1/child-interest-status/{parentId}/{childId} totalCount
                  style: AppTheme.lightTheme.textTheme.bodyMedium!
                      .copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          verticalSpaceLarge,
          Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: Row(
              children: [
                Text(
                  '${questionAnswer!.question}',
                  style: AppTheme.lightTheme.textTheme.bodyMedium!
                      .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          verticalSpaceLarge,
          Column(
            children: <Widget>[
              if (finalChoices != null)
                Container(
                  alignment: Alignment.center,
                  //margin: EdgeInsets.all(5.0),
                  height: 100,
                  width: screenwidth,
                  child: Center(
                    child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: finalChoices!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          height: 100,
                          width: 200,
                          child: Column(
                            children: [
                              Radio(
                                splashRadius: 20,
                                activeColor: colors[index],
                                value: finalChoices![index],
                                groupValue: _verType,
                                onChanged: (Choice? value) {
                                  setState(() {
                                    _verType = value!;
                                    questionAnswer?.answerId = value.choiceId;
                                    questionAnswer?.answer = value.choice;
                                  });
                                  //Navigator.of(context).pop();
                                },
                              ),
                              AutoSizeText(
                                '${finalChoices![index].choice}',
                                minFontSize: 15,
                                maxFontSize: 16,
                                style: AppTheme.lightTheme.textTheme.bodyMedium!
                                    .copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                maxLines: 1,
                                softWrap: true,
                                textAlign: TextAlign.center,
                                stepGranularity: 1,
                                group: descGroup,
                              ),

                              /*Text(
                                      'Agree',
                                      style: new TextStyle(
                                          fontSize: 11.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600),
                                    )*/
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return textScale <= 1.0
                            ? const SizedBox(
                                width: 12,
                              )
                            : const SizedBox(
                                width: 5,
                              );
                      },
                    ),
                  ),
                ),
            ],
          ),
          verticalSpaceLarge,
          Padding(
            padding: const EdgeInsets.only(right: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                appButton(
                  context: context,
                  width: 163,
                  height: 49,
                  titleFontSize: 16,
                  title: '<  Previous',
                  titleColour: AdaptiveTheme.secondaryColor(context),
                  borderColor: AdaptiveTheme.secondaryColor(context),
                  onPressed: () {
                    _previous(interestArgs.updateHandler);
                  },
                ),
                horizontalSpaceSmall,
                appButton(
                  context: context,
                  width: 163,
                  height: 49,
                  titleFontSize: 16,
                  title: 'Next >',
                  titleColour: AdaptiveTheme.primaryColor(context),
                  borderColor: AdaptiveTheme.primaryColor(context),
                  onPressed: () {
                    _next(interestArgs.updateHandler);
                  },
                ),
              ],
            ),
          ),
          // verticalSpaceMedium,
          Padding(
            padding: const EdgeInsets.only(left: 50.0, top: 50.0, right: 50.0),
            child: Divider(thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _continueLater(interestArgs.updateHandler),
                  child: Text(
                    'Continue Later',
                    style: AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AdaptiveTheme.primaryColor(
                            context)), // HexColor.fromHex("#0D75DE")),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget _bodyWidgetSmallScreen() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30.0, top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Situation -',
                  style: AppTheme.lightTheme.textTheme.bodyMedium!
                      .copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                horizontalSpaceTiny,
                Text(
                  '${questionAnswer!.questionNo}',
                  style: AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AdaptiveTheme.primaryColor(context)),
                ),
                horizontalSpaceTiny,
                Text(
                  '/47', //TODO: replace this value with the value we get from /child-interest-service/api/v1/child-interest-status/{parentId}/{childId} totalCount
                  style: AppTheme.lightTheme.textTheme.bodyMedium!
                      .copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          verticalSpaceLarge,
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    '${questionAnswer!.question}',
                    style: AppTheme.lightTheme.textTheme.bodyMedium!
                        .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
          verticalSpaceLarge,
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (finalChoices != null)
                  Container(
                    alignment: Alignment.center,
                    width: screenwidth,
                    child: Center(
                      child: ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: finalChoices!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            height: 40,
                            //width: textScale <= 1.0 ? 56 : 70,
                            child: Row(
                              children: [
                                Radio(
                                  splashRadius: 15,
                                  activeColor: colors[index],
                                  value: finalChoices![index],
                                  groupValue: _verType,
                                  onChanged: (Choice? value) {
                                    setState(() {
                                      _verType = value!;
                                      questionAnswer?.answerId = value.choiceId;
                                      questionAnswer?.answer = value.choice;
                                    });
                                    //Navigator.of(context).pop();
                                  },
                                ),
                                AutoSizeText(
                                  '${finalChoices![index].choice}',
                                  minFontSize: 15,
                                  maxFontSize: 16,
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium!
                                      .copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300),
                                  maxLines: 1,
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  stepGranularity: 1,
                                  group: descGroup,
                                ),

                                /*Text(
                                        'Agree',
                                        style: new TextStyle(
                                            fontSize: 11.0,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                      )*/
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return textScale <= 1.0
                              ? const SizedBox(
                                  width: 12,
                                )
                              : const SizedBox(
                                  width: 5,
                                );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          verticalSpaceLarge,
          Padding(
            padding: const EdgeInsets.only(right: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                appButton(
                  context: context,
                  width: 120,
                  height: 45,
                  titleFontSize: 16,
                  title: '<  Previous',
                  titleColour: AdaptiveTheme.secondaryColor(context),
                  borderColor: AdaptiveTheme.secondaryColor(context),
                  onPressed: () {
                    _previous(interestArgs.updateHandler);
                  },
                ),
                horizontalSpaceSmall,
                appButton(
                  context: context,
                  width: 120,
                  height: 45,
                  titleFontSize: 16,
                  title: 'Next >',
                  titleColour: AdaptiveTheme.primaryColor(context),
                  borderColor: AdaptiveTheme.primaryColor(context),
                  onPressed: () {
                    _next(interestArgs.updateHandler);
                  },
                ),
              ],
            ),
          ),
          verticalSpaceLarge,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _continueLater(interestArgs.updateHandler),
                child: Text(
                  'Continue Later',
                  style: AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AdaptiveTheme.primaryColor(
                          context)), // HexColor.fromHex("#0D75DE")),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return WillPopScope(
      onWillPop: () async {
        _continueLater(interestArgs.updateHandler);
        return false;
      },
      child: Scaffold(
        endDrawer: WebBannerDrawer(),
        backgroundColor: Colors.white,
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
                padding: const EdgeInsets.only(left: 50.0, top: 40),
                child: Row(
                  children: [
                    Text(
                      'Interest Capture',
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
                width: screenWidth(context) * 0.90,
                height: screenHeight(context) *
                    (screenWidth(context) > 800 ? 0.70 : 0.90),
                child: _isLoading == false
                    ? screenWidth(context) > 800
                        ? _bodyWidgetLargeScreen()
                        : _bodyWidgetSmallScreen()
                    : Center(child: AdaptiveCircularProgressIndicator()),
              ),
              WebBottomBar(),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

enum ValType { one, two, three, four, five }
