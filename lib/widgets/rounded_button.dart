import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback? onPressed;
  final double borderRadius;
  const RoundButton({
    Key? key,
    required this.title,
    required this.onPressed,
    required this.color,
    this.borderRadius = 15.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(title),
      style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(borderRadius),
          )),
    );
  }
}
