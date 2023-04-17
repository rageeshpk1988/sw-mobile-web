import 'package:flutter/material.dart';
import '../../../../util/app_theme.dart';

class HeaderBlockItem extends StatelessWidget {
  const HeaderBlockItem({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _gradientDecoration = BoxDecoration(
      gradient: LinearGradient(
          colors: [
            AppTheme.secondaryLightColor,
            AppTheme.primaryColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp),
    );
    return Container(
      decoration: _gradientDecoration,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('assets/images/child_avatar.png'),
        ),
        title: Text(
          "title",
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: Colors.white),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FittedBox(
              child: Text(
                "title",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white),
              ),
            ),
            FittedBox(
              child: Text(
                "title",
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
