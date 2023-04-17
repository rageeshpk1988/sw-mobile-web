import 'package:flutter/material.dart';

class RoundIconButton extends StatelessWidget {
  final String title;
  final Color? color;
  final Color? iconColor;
  final VoidCallback? onPressed;
  final IconData iconData;
  final double? elevation;
  const RoundIconButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.color,
    required this.iconData,
    this.iconColor,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        iconData,
        color: iconColor ?? Theme.of(context).primaryColor,
      ),
      label: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(color: iconColor ?? Theme.of(context).primaryColor),
      ),
      style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(15.0),
          ),
          elevation: elevation ?? 5),
    );
  }
}
