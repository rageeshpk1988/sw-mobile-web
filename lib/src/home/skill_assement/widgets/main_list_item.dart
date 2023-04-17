import 'package:flutter/material.dart';
import '../../../../util/ui_helpers.dart';

class AssessmentMainListItemWidget extends StatelessWidget {
  final VoidCallback basicStartPressed;
  final VoidCallback advancedStartPressed;
  final VoidCallback advancedInfoPressed;
  const AssessmentMainListItemWidget(
      {Key? key,
      required this.basicStartPressed,
      required this.advancedStartPressed,
      required this.advancedInfoPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: screenWidthPercentage(context) * 0.35,
          child: Row(
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  decoration: getBoxDecoration(1.0, 15.0, Colors.grey),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Basic'),
                        Image.asset(
                          'assets/images/basic.png',
                          width: screenWidthPercentage(context) * 0.35 / 3,
                          height: screenWidthPercentage(context) * 0.35 / 3,
                        ),
                        TextButton(
                          onPressed: basicStartPressed,
                          child: const Text('Start Now'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              horizontalSpaceSmall,
              Flexible(
                flex: 1,
                child: Stack(
                  children: [
                    Container(
                      decoration: getBoxDecoration(1.0, 15.0, Colors.grey),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Advanced'),
                            Image.asset(
                              'assets/images/advanced.png',
                              width: screenWidthPercentage(context) * 0.35 / 3,
                              height: screenWidthPercentage(context) * 0.35 / 3,
                            ),
                            TextButton(
                              onPressed: advancedStartPressed,
                              child: const Text('Start Now'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: InkWell(
                        onTap: advancedInfoPressed,
                        child: Icon(
                          Icons.info_outline,
                          size: screenWidthPercentage(context) * 0.35 / 5,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
