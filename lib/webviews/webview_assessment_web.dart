import 'dart:async';
import 'package:flutter/material.dart';
//import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import '../helpers/route_arguments.dart';
import '../helpers/global_variables.dart';

import '../src/home/child/screens/child_skillsummary.dart';
import '../src/models/getquestion_request.dart';
import '../src/providers/auth.dart';

import '../src/providers/child_recomendations.dart';
import '../widgets/web_banner.dart';
import '../widgets/web_bottom_bar.dart';

class WebViewAssessmentWeb extends StatefulWidget {
  static String routeName = '/assessment-page-web';
  final GetQuestionReq getQuestionReq;
  final Function updateChildData;
  const WebViewAssessmentWeb({
    Key? key,
    required this.updateChildData,
    required this.getQuestionReq,
  }) : super(key: key);
  @override
  _WebViewAssessmentWebState createState() => _WebViewAssessmentWebState();
}

class _WebViewAssessmentWebState extends State<WebViewAssessmentWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  WebViewXController? webViewController;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    var appBarHeight = kToolbarHeight;
    var screenheight = deviceSize.height - appBarHeight;
    var screenwidth = deviceSize.width;
    var _defaultChild = Provider.of<Auth>(context, listen: false).currentChild!;
    var loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
    return Scaffold(
      key: scaffoldKey,
      endDrawer: WebBannerDrawer(),
      backgroundColor: Colors.white,
      body: AbsorbPointer(
        absorbing: _isLoading,
        child: SingleChildScrollView(
          child: WebViewAware(
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
                WebViewX(
                  height: screenheight * .90,
                  width: screenwidth * 90,
                  initialContent:
                      "${GlobalVariables.apiBaseUrl}/login/studentanalysis/webview?age=${widget.getQuestionReq.age}&countryid=${loginResponse.b2cParent!.countryID}",
                  javascriptMode: JavascriptMode.unrestricted,
                  //initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.alwaysAllow,
                  dartCallBacks: {
                    DartCallback(
                        name: 'StudentAnalysisHandler',
                        callBack: (msg) async {
                          var temp = msg;

                          //print(temp[0]);

                          // widget.updateChildData(_defaultChild.childID);
                          if (_isLoading != true) if (temp[0].toString() ==
                              "completed") {
                            setState(() {
                              _isLoading = true;
                            });
                            var submitted =
                                await Provider.of<ChildRecomendations>(context,
                                        listen: false)
                                    .sentAssessmentData(
                                        int.parse(
                                            widget.getQuestionReq.hierarchyId),
                                        widget.getQuestionReq.assessmentName,
                                        loginResponse.b2cParent!.parentID,
                                        _defaultChild.childID!)
                                    .onError((error, stackTrace) {
                              return false;
                            });

                            if (submitted == true) {
                              setState(() {
                                _isLoading = false;
                              });
                              widget.updateChildData(_defaultChild.childID);
                              Navigator.of(context).pop();
                              Navigator.of(context).pushReplacementNamed(
                                  ChildSkillsummaryScreen.routeName,
                                  arguments:
                                      InterestArgs(widget.updateChildData));
                            } else if (submitted == false) {
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
                            Navigator.of(context).pop();
                          }
                        })
                  },
                  /*onWebViewCreated: (WebViewXController controller) {
                    webViewController = controller;
                    controller.(
                        handlerName: 'StudentAnalysisHandler',
                        callback: (value) async {
                          var temp = value;

                          print(temp[0]);

                          // widget.updateChildData(_defaultChild.childID);
                          if (_isLoading != true) if (temp[0].toString() ==
                              "completed") {
                            setState(() {
                              _isLoading = true;
                            });
                            var submitted = await Provider.of<ChildRecomendations>(
                                context,
                                listen: false)
                                .sentAssessmentData(
                                int.parse(widget.getQuestionReq.hierarchyId),
                                widget.getQuestionReq.assessmentName,
                                loginResponse.b2cParent!.parentID,
                                _defaultChild.childID!)
                                .onError((error, stackTrace) {
                              return false;
                            });

                            if (submitted == true) {
                              setState(() {
                                _isLoading = false;
                              });
                              widget.updateChildData(_defaultChild.childID);
                              Navigator.of(context).pop();
                              Navigator.of(context).pushReplacementNamed(
                                  ChildSkillsummaryScreen.routeName,
                                  arguments: InterestArgs(widget.updateChildData));
                            } else if (submitted == false) {
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
                            Navigator.of(context).pop();
                          }
                        });
                  },*/
                  onPageFinished: (finish) async {
                    await webViewController
                        ?.callJsMethod("StudentAnalysisHandler.setAllData", [
                      widget.getQuestionReq.age,
                      widget.getQuestionReq.countryCode,
                      widget.getQuestionReq.studentId,
                      widget.getQuestionReq.hierarchyCount,
                      widget.getQuestionReq.currentLeafId,
                      widget.getQuestionReq.hierarchyId,
                      widget.getQuestionReq.childName
                    ]);
                    /* await webViewController?.evalRawJavascript(
                         "setAllData(" +
                            widget.getQuestionReq.age +
                            ",'" +
                            widget.getQuestionReq.countryCode +
                            "'," +
                            widget.getQuestionReq.studentId +
                            "," +
                            widget.getQuestionReq.hierarchyCount +
                            "," +
                            widget.getQuestionReq.currentLeafId +
                            "," +
                            widget.getQuestionReq.hierarchyId +
                            ",\"" +
                            widget.getQuestionReq.childName +
                            "\")",inGlobalContext: true);*/
                    // print("setAllData(" +
                    //     widget.getQuestionReq.age +
                    //     ",'" +
                    //     widget.getQuestionReq.countryCode +
                    //     "'," +
                    //     widget.getQuestionReq.studentId +
                    //     "," +
                    //     widget.getQuestionReq.hierarchyCount +
                    //     "," +
                    //     widget.getQuestionReq.currentLeafId +
                    //     "," +
                    //     widget.getQuestionReq.hierarchyId +
                    //     ",\"" +
                    //     widget.getQuestionReq.childName +
                    //     "\")");
                    setState(() {
                      _isLoading = false;
                    });
                    /*controller.addJavaScriptHandler(
                        handlerName: "StudentAnalysisHandler",
                        callback: (value)  {

                          print(value.toString());




                        });*/
                  },
                  /*onConsoleMessage: (controller, message) {
                    print("${message.message}");
                  },*/
                ),
                WebBottomBar(),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
