//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AdaptiveCircularProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage('assets/icons/loading_indicator.gif'),
      height: 100,
    );

    // return Platform.isIOS
    //     ? Image(
    //         image: AssetImage('assets/icons/loading_indicator.gif'),
    //         height: 100,
    //       )
    //     : Image(
    //         image: AssetImage('assets/icons/loading_indicator.gif'),
    //         height: 100,
    //       ); //CircularProgressIndicator();
  }
}
