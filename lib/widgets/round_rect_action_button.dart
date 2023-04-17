import 'package:flutter/material.dart';
import '/adaptive/adaptive_theme.dart';

class RoundRectActionButton extends StatelessWidget {
  final IconData iconData;
  final VoidCallback onTap;
  final double borderRadius;
  final double size;
  const RoundRectActionButton(
      {Key? key,
      required this.iconData,
      required this.onTap,
      this.borderRadius = 5,
      this.size = 30})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, // Colors.yellow[700],
            borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
        child: Icon(
          iconData,
          color: AdaptiveTheme.primaryColor(context)
              .withOpacity(0.5), // Colors.white,
          size: size,
        ),
      ),
      onTap: onTap,
    );
  }
}
