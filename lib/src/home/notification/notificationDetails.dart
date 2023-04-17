import 'package:flutter/material.dart';
import '../../../src/home/notification/notification_product.dart';
import '../../../util/app_theme.dart';
import '../../../widgets/rounded_button.dart';

class NotificationDetailScreen extends StatefulWidget {
  const NotificationDetailScreen({Key? key}) : super(key: key);

  @override
  _NotificationDetailScreenState createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/images/sw_appbar_logo.png', height: 25),
          centerTitle: false,
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Spacer(),
                      const Text('Location: test location address'),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Spacer(),
                          RoundButton(
                              title: 'Follow',
                              onPressed: () {},
                              color: Colors.orange),
                          const SizedBox(
                            width: 20,
                          ),
                          const Text('Followers 0'),
                          Spacer(),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Text('Overview',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 25)),
              NotificationDetailList
            ],
          ),
        ))));
  }

  Widget NotificationDetailList = new Container(
    margin: EdgeInsets.symmetric(vertical: 20.0),
    height: 700,
    child: new ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          child: SizedBox(
            height: 150,
            width: double.infinity,
            child: Row(
              children: [
                SizedBox(
                  height: 70,
                  width: 70,
                  child: Image.asset('assets/images/b2c_splash_logo1.png',
                      height: 25),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Code it',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 25,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(
                      height: 20,
                    ),
                    Text('Age: 4-10 years',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.normal)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('INR 400.00',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(
                          width: 100,
                        ),
                        RoundButton(
                            title: 'Buy Now',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        NotificationProductScreen()),
                              );
                            },
                            color: AppTheme.secondaryColor)
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    ),
  );
}
