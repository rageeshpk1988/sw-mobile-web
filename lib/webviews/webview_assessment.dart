import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../helpers/route_arguments.dart';
import '../helpers/global_variables.dart';
import '../adaptive/adaptive_custom_appbar.dart';
import '../src/home/child/screens/child_skillsummary.dart';
import '../src/models/getquestion_request.dart';
import '../src/providers/auth.dart';

import '../src/providers/child_recomendations.dart';

class WebViewAssessment extends StatefulWidget {
  static String routeName = '/assessment-page-temp';
  final GetQuestionReq getQuestionReq;
  final Function updateChildData;
  const WebViewAssessment({
    Key? key,
    required this.updateChildData,
    required this.getQuestionReq,
  }) : super(key: key);
  @override
  _WebViewAssessmentState createState() => _WebViewAssessmentState();
}

class _WebViewAssessmentState extends State<WebViewAssessment> {
  InAppWebViewController? webViewController;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    var _defaultChild = Provider.of<Auth>(context, listen: false).currentChild!;
    var loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AdaptiveCustomAppBar(
        title: "Assessment",
        showShopifyHomeButton: false,
        showShopifyCartButton: false,
        showKycButton: false,
        showProfileButton: false,
        showHamburger: false,
        scaffoldKey: null,
        adResponse: null,
        loginResponse: null,
        updateHandler: null,
        showMascot: true,
      ),
      body: AbsorbPointer(
        absorbing: _isLoading,
        child: SafeArea(
          child: InAppWebView(
            onProgressChanged: (controller, progress) {
              // print("Progress: $progress");
            },
            initialUrlRequest: URLRequest(
                url: Uri.parse(
                    "${GlobalVariables.apiBaseUrl}/login/studentanalysis/webview?age=${widget.getQuestionReq.age}&countryid=${loginResponse.b2cParent!.countryID}")),
            initialOptions: InAppWebViewGroupOptions(
              ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true),
              crossPlatform: InAppWebViewOptions(
                preferredContentMode: UserPreferredContentMode.MOBILE,
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
              ),
            ),
            onWebViewCreated: (InAppWebViewController controller) {
              webViewController = controller;
              controller.addJavaScriptHandler(
                  handlerName: 'StudentAnalysisHandler',
                  callback: (value) async {
                    var temp = value;

                    // print(temp[0]);

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
            },
            onLoadStop: (controller, uri) async {
              await controller.evaluateJavascript(
                  source: "setAllData(" +
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
                      "\")");
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
            onConsoleMessage: (controller, message) {
              //print("${message.message}");
            },
          ),
        ),
      ),
    );
  }
}
