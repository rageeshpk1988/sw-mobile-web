import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import '../../../../adaptive/adaptive_theme.dart';

import '../../../invite_friend/screens/refer_friend.dart';
import '../../../models/login_response.dart';
import '../../../providers/auth.dart';

import '../../../../main.dart';
import '../widgets/main_drawer.dart';
import 'home_page.dart';

//This is a dummy page for testing . It will be removed at later stage

class LandingPage extends StatefulWidget {
  static String routeName = '/landing-page';
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _selectedIndex = 0;
  late LoginResponse loginResponse;
  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    const Text('No New Notifications'),
    ReferFriend(),
    MainDrawer(),
  ];

  void _onItemTapped(int index) {
    //if (index == 2) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    //If we are on iOS we ask for permissions
    if (kIsWeb || Platform.isAndroid) {
      //don't do anything
    } else if (Platform.isIOS) {
      FirebaseMessaging.instance.requestPermission();
    }
    if (!kIsWeb) {
      //Handle the background notifications (the app is termianted)
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        //If there is data in our notification
        if (message != null) {
          var kycStatus = Provider.of<Auth>(context, listen: false).kycResponse;
          if (kycStatus != 1) {
            updateKycStatus();
          }
          //We will open the route from the field view
          //with the value definied in the notification
          Navigator.of(context).pushNamed('/' + message.data['view']);
        }
      });

      //Handle the notification if the app is in Foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          var kycStatus = Provider.of<Auth>(context, listen: false).kycResponse;
          if (kycStatus != 1) {
            updateKycStatus();
          }
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title, // Title of our notification
              notification.body, // Body of our notification
              NotificationDetails(
                android: AndroidNotificationDetails(
                  // This is the channel we use defined above
                  channel.id,
                  channel.name,
                  channelDescription: channel.description,
                  //The icon is defined in android/app/src/main/res/drawable
                  icon: 'notification',
                ),
              ),
              //We parse the data from the field view to the callback
              payload: message.data["view"]);
        }
      });
      FirebaseMessaging.instance
          .subscribeToTopic('vendor_post'); // subscribe to topic
      //Handle the background notifications (the app is closed but not termianted)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        var kycStatus = Provider.of<Auth>(context, listen: false).kycResponse;
        if (kycStatus != 1) {
          updateKycStatus();
        }
        //debugPrint('A new onMessageOpenedApp event was published!');
        Navigator.of(context).pushNamed('/' + message.data['view']);
      });
    }
  }

  void updateKycStatus() async {
    loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
    // var resultsLoaded = await Provider.of<Auth>(context, listen: false)
    //     .getApproveStatusKyc(loginResponse.b2cParent!.parentID);
    //print("updating kycstatus");
    //int? status = await SharedPrefData.getUserKycStatus();
    setState(() {
      //kycStatus = status;
    });
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          content: Text(
            'Do you really want to exit?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
                //TODO:: FOR iOS MinimizeApp.minimizeApp();
                //   Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Colors.black,
          selectedItemColor: AdaptiveTheme.secondaryColor(context),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "assets/icons/homepag_filled.svg",
                color: _selectedIndex == 0
                    ? AdaptiveTheme.secondaryColor(context)
                    : Colors.black,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "assets/icons/bell.svg",
                color: _selectedIndex == 1
                    ? AdaptiveTheme.secondaryColor(context)
                    : Colors.black,
              ),
              label: 'Notification',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "assets/icons/refer_and_earn.svg",
                color: _selectedIndex == 2
                    ? AdaptiveTheme.secondaryColor(context)
                    : Colors.black,
                height: 23,
                width: 24,
              ),
              label: 'Refer',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/icons/menu.png"),
              ),
              label: 'Menu',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
