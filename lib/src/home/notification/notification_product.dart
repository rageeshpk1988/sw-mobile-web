import 'package:flutter/material.dart';
import '../../../util/app_theme.dart';
import '../../../widgets/rounded_button.dart';

class NotificationProductScreen extends StatefulWidget {
  const NotificationProductScreen({Key? key}) : super(key: key);

  @override
  _NotificationProductScreenState createState() =>
      _NotificationProductScreenState();
}

class _NotificationProductScreenState extends State<NotificationProductScreen> {
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
              ProductDetail,
              const SizedBox(
                height: 15,
              ),
              Text('Related Products and Services',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              NotificationProductList
            ],
          ),
        ))));
  }

  Widget NotificationProductList = new Container(
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
                            onPressed: () {},
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
  Widget ProductDetail = new Container(
      margin: EdgeInsets.symmetric(vertical: 20.0),
      height: 300,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 150,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Code it',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 25,
                        fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    SizedBox(
                      height: 100,
                      width: 150,
                      child: Image.asset('assets/images/b2c_splash_logo1.png',
                          height: 25),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(
                          height: 15,
                        ),
                        Text('Age : 4-10 years'),
                        const SizedBox(
                          height: 15,
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text('INR 400',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 10,
                ),
                Spacer(),
                RoundButton(
                    title: 'Buy Now',
                    onPressed: () {},
                    color: AppTheme.primaryColor)
              ],
            ),
          ),
        ),
      ));
}
