import 'package:flutter/material.dart';

import '../../../adaptive/adaptive_custom_appbar.dart';
import '/src/home/notification/notificationDetails.dart';

class NotificationScreen extends StatefulWidget {
  static String routeName = '/notifications-list';
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  bool isSwitched = false;
  Future? quoteLoader;
  String? quote;
  String? author;
  //List<DocumentSnapshot> ads = [];
  List<int> new1 = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          title: 'Alerts',
          showMascot: true,
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Text('Alerts',
              //       textAlign: TextAlign.left,
              //       style: const TextStyle(
              //           fontWeight: FontWeight.bold, fontSize: 25)),
              // ),
              notificationList
            ],
          ),
        ))));
  }

  Widget notificationList = new Container(
    margin: EdgeInsets.symmetric(vertical: 20.0),
    height: 700,
    child: new ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          child: ListTile(
            leading: Icon(Icons.notifications),
            title: Text('${[index]}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotificationDetailScreen()),
              );
            },
          ),
        );
      },
    ),
  );
}
