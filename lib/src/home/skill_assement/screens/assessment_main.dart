import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../../src/home/skill_assement/widgets/header_gradient_block_item.dart';
import '../../../../src/home/skill_assement/widgets/main_list_item.dart';
import '../../../../util/app_theme.dart';
import '../../../../util/ui_helpers.dart';

class AssessmentMainScreen extends StatelessWidget {
  const AssessmentMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldGreyBackground,
      appBar: AppBar(
        title: Image.asset(
          'assets/images/sw_appbar_logo.png',
          height: 25,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            HeaderBlockItem(),
            _stageAndPercentWidget(context),
            ListTile(
              leading: ImageIcon(
                AssetImage('assets/images/ic_drawer.png'),
                color: AppTheme.secondaryColor,
              ),
              title: Text(
                'Assesment title',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            AssessmentMainListItemWidget(
              advancedInfoPressed: () {},
              basicStartPressed: () {},
              advancedStartPressed: () {},
            ),
            ListTile(
              leading: ImageIcon(
                AssetImage('assets/images/ic_drawer.png'),
                color: AppTheme.secondaryColor,
              ),
              title: Text(
                'Assesment title',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            AssessmentMainListItemWidget(
              advancedInfoPressed: () {},
              basicStartPressed: () {},
              advancedStartPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Container _stageAndPercentWidget(BuildContext context) {
    return Container(
      height: screenHeightPercentage(context) * 0.10,
      color: Colors.white,
      child: Column(
        children: [
          Container(),
          Spacer(),
          LinearPercentIndicator(
            lineHeight: 14.0,
            percent: 0.5,
            backgroundColor: Colors.grey.shade300,
            progressColor: AppTheme.secondaryLightColor,
          ),
          Container(
            width: screenWidth(context),
            child: Text(
              '50 % Completed',
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
          verticalSpaceSmall,
        ],
      ),
    );
  }
}
