import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AdaptiveTextButton extends StatelessWidget {
  final String text;
  final Function handler;
  const AdaptiveTextButton({
    required this.text,
    required this.handler,
  });

  @override
  Widget build(BuildContext context) {
    return kIsWeb || Platform.isAndroid
        ? TextButton(child: Text(text), onPressed: handler())
        : CupertinoButton(child: Text(text), onPressed: handler());
  }
}
