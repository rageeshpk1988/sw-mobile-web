import 'package:flutter/material.dart';
import '../../../../src/home/skill_assement/widgets/child_info_item.dart';
import '../../../../util/ui_helpers.dart';

class ChildrenListingScreen extends StatelessWidget {
  const ChildrenListingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/sw_appbar_logo.png',
          height: 25,
        ),
        centerTitle: false,
      ),
      backgroundColor: Colors.grey[350],
      body: Column(
        children: [
          Container(
            color: Colors.white,
            height: screenHeightPercentage(context) * 0.05,
            width: screenWidth(context),
            child: Center(
              child: Text(
                'Your Children',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  ChildInfoItemWidget(
                      title: 'title',
                      subTitle: 'subTitle',
                      subTitle2: 'subTitle2'),
                  ChildInfoItemWidget(
                      title: 'title',
                      subTitle: 'subTitle',
                      subTitle2: 'subTitle2'),
                  ChildInfoItemWidget(
                      title: 'title',
                      subTitle: 'subTitle',
                      subTitle2: 'subTitle2'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
