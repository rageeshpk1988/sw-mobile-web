import 'package:flutter/material.dart';

class ChildInfoItemWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final String subTitle2;

  const ChildInfoItemWidget({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.subTitle2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('assets/images/child_avatar.png'),
        ),
        isThreeLine: true,
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        subtitle: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: '$subTitle \n',
                  style: Theme.of(context).textTheme.titleMedium),
              TextSpan(
                  text: '$subTitle',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
