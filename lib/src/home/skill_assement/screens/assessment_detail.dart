import 'package:flutter/material.dart';
import '../../../../src/home/skill_assement/widgets/header_gradient_block_item.dart';
import '../../../../src/home/skill_assement/widgets/progress_block_card_item.dart';
import '../../../../src/home/skill_assement/widgets/text_block_card_item.dart';
import '../../../../util/app_theme.dart';

class AssessmentDetailScreen extends StatelessWidget {
  const AssessmentDetailScreen({Key? key}) : super(key: key);

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
      backgroundColor: AppTheme.scaffoldGreyBackground,
      body: SafeArea(
        child: Column(
          children: [
            HeaderBlockItem(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    AssessmentProgressItemWidget(),
                    AssessmentDetailItemWidget(),
                    AssessmentDetailItemWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
