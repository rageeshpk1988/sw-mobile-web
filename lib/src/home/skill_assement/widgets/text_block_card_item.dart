import 'package:flutter/material.dart';
import '../../../../util/app_theme.dart';

class AssessmentDetailItemWidget extends StatelessWidget {
  const AssessmentDetailItemWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'data',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppTheme.secondaryColor),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 4.0),
              minLeadingWidth: 10,
              leading: Icon(
                Icons.circle_outlined,
                size: 20,
                color: Colors.green,
              ),
              title: const Text('data'),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 4.0),
              minLeadingWidth: 10,
              leading: Icon(
                Icons.circle_outlined,
                size: 20,
                color: Colors.green,
              ),
              title: const Text('data'),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 4.0),
              minLeadingWidth: 10,
              leading: Icon(
                Icons.circle_outlined,
                size: 20,
                color: Colors.green,
              ),
              title: const Text('data'),
            ),
          ],
        ),
      ),
    );
  }
}
