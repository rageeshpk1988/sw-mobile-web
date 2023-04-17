import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../.././../util/ui_helpers.dart';

class AssessmentProgressItemWidget extends StatelessWidget {
  const AssessmentProgressItemWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircularPercentIndicator(
                    radius: 80.0,
                    lineWidth: 8.0,
                    percent: 0.8,
                    center: Text(
                      "80%",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    progressColor: Colors.green,
                    backgroundColor: Colors.grey.shade200,
                  ),
                  horizontalSpaceSmall,
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 2,
                              child: Text(
                                'data 6u65u56y 356y ',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Text(
                                '100 %',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        backgroundColor: Colors.red,
                                        color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
