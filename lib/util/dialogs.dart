//Dialogs
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import '/src/profile/screens/add_child_web.dart';

import '../src/profile/screens/add_child.dart';
import '/util/app_theme.dart';
import '/util/app_theme_cupertino.dart';

import '../adaptive/adaptive_theme.dart';
import 'ui_helpers.dart';

enum DialogConfirmAction { CANCEL, ACCEPT }

enum MediaType { IMAGE, VIDEO }

enum DialogSubscriptionStatus { NOW, AFTEREXPIRY }

class Dialogs {
  Future<void> ackAlert(BuildContext context, String title, String content) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text(title,
              style: kIsWeb || Platform.isAndroid
                  ? AppTheme.lightTheme.textTheme.bodySmall
                  : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
                      .copyWith(fontWeight: FontWeight.w500)),
          content: Text(
            content,
            style: kIsWeb || Platform.isAndroid
                ? AppTheme.lightTheme.textTheme.bodyMedium!
                    .copyWith(fontSize: 14)
                : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
                    .copyWith(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: AdaptiveTheme.primaryColor(context)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> ackInfoAlert(BuildContext context, String content,
      {bool web = false}) {
    Widget _contentWidget() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Image.asset('assets/icons/alert_info.png', width: 40, height: 40),
          const SizedBox(height: 25),
          Text(content,
              textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: appButton(
              context: context,
              width: web ? screenWidth(context) * 0.10 : double.infinity,

              height: 40,
              titleFontSize: 14,
              title: 'OK',
              titleColour: AdaptiveTheme.primaryColor(context),
              onPressed: () {
                Navigator.of(context).pop();
              },
              borderColor: AdaptiveTheme.primaryColor(context),
              //borderRadius: 10,
            ),
          ),
        ],
      );
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          content: _contentWidget(),
        );
      },
    );
  }

  Future<void> ackSuccessAlert(
      BuildContext context, String title, String content) {
    Widget _contentWidget() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Image.asset('assets/icons/alert_checkmark.png',
              width: 40, height: 40),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AdaptiveTheme.secondaryColor(context)),
          ),
          const SizedBox(height: 25),
          Text(content,
              textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: appButton(
              context: context,
              width: double.infinity,

              height: 40,
              titleFontSize: 14,
              title: 'OK',
              titleColour: AdaptiveTheme.primaryColor(context),
              onPressed: () {
                Navigator.of(context).pop();
              },
              borderColor: AdaptiveTheme.primaryColor(context),
              //borderRadius: 10,
            ),
          ),
        ],
      );
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          content: _contentWidget(),
        );
      },
    );
  }

  Future<DialogConfirmAction?> asyncConfirmDialog(
      BuildContext context, String title, String content) async {
    return showDialog<DialogConfirmAction>(
      context: context,

      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return Future.value(false);
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'No',
                  style: TextStyle(color: AdaptiveTheme.primaryColor(context)),
                ),
                onPressed: () {
                  Navigator.of(context).pop(DialogConfirmAction.CANCEL);
                },
              ),
              TextButton(
                child: Text(
                  'Yes',
                  style: TextStyle(color: AdaptiveTheme.primaryColor(context)),
                ),
                onPressed: () {
                  Navigator.of(context).pop(DialogConfirmAction.ACCEPT);
                },
              )
            ],
          ),
        );
      },
    );
  }

  Future<MediaType?> mediaTypeDialog(
      BuildContext context, String title, String content) async {
    TextStyle _textStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w400);

    return showDialog<MediaType>(
      context: context,

      //barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text(title, style: _textStyle),
          content: Text(content, style: _textStyle),
          actions: <Widget>[
            TextButton(
              child: Text(
                'IMAGE',
                style: TextStyle(color: AdaptiveTheme.primaryColor(context)),
              ),
              onPressed: () {
                Navigator.of(context).pop(MediaType.IMAGE);
              },
            ),
            TextButton(
              child: Text(
                'VIDEO',
                style: TextStyle(color: AdaptiveTheme.primaryColor(context)),
              ),
              onPressed: () {
                Navigator.of(context).pop(MediaType.VIDEO);
              },
            )
          ],
        );
      },
    );
  }

  Future<DialogSubscriptionStatus?> subscriptionDialog(
      BuildContext context, String title, String content) async {
    return showDialog<DialogSubscriptionStatus>(
      context: context,

      //barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text(title,
              style: kIsWeb || Platform.isAndroid
                  ? AppTheme.lightTheme.textTheme.bodySmall
                  : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle),
          content: Text(
            content,
            style: kIsWeb || Platform.isAndroid
                ? AppTheme.lightTheme.textTheme.bodyMedium!
                    .copyWith(fontSize: 14)
                : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
                    .copyWith(fontSize: 14),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'NOW',
                style: TextStyle(color: AdaptiveTheme.primaryColor(context)),
              ),
              onPressed: () {
                Navigator.of(context).pop(DialogSubscriptionStatus.NOW);
              },
            ),
            TextButton(
              child: Text(
                'AFTER EXPIRY',
                style: TextStyle(color: AdaptiveTheme.primaryColor(context)),
              ),
              onPressed: () {
                Navigator.of(context).pop(DialogSubscriptionStatus.AFTEREXPIRY);
              },
            )
          ],
        );
      },
    );
  }

  Future noChildPopup(BuildContext context, String? content,
      {bool isWeb = false}) {
    return showDialog(
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.all(30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 15.0),
          child: SizedBox(
            width: isWeb ? screenWidth(context) * 0.20 : double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 25,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Image.asset('assets/icons/addchild.png', width: 50, height: 50),
                if (content != null) SizedBox(height: 20),
                if (content != null)
                  Text(content,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                const SizedBox(height: 30),
                Center(
                  child: SizedBox(
                    width: screenWidth(context) * (isWeb ? 0.10 : 0.70),
                    height: 40,
                    child: appButton(
                      context: context,
                      width: 20,
                      height: 20,
                      title: 'Add Child',
                      titleFontSize: 16,
                      titleColour: AdaptiveTheme.primaryColor(context),
                      onPressed: () {
                        if (isWeb) {
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed(
                              AddChildScreenWeb.routeName,
                              arguments: () {});
                        } else {
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed(
                              AddChildScreen.routeName,
                              arguments: () {});
                        }
                      },
                      borderColor: AdaptiveTheme.primaryColor(context),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      context: context,
    );
  }

  Widget closeButtonCircle(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Align(
        alignment: Alignment.topRight,
        child: CircleAvatar(
          radius: 16.0,
          backgroundColor: AdaptiveTheme.primaryColor(context),
          child: Icon(Icons.close, color: Colors.white),
        ),
      ),
    );
  }
}

//Dialogs
