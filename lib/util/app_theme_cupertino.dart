import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppThemeCupertino {
  //AppThemeCupertino._();

  static const Color primaryColor = Color(0xFFED247C);
  static const Color secondaryColor = Color(0xFF7F2A86);
  static const Color secondaryLightColor = Color(0xFFC767CE);
  static Color scaffoldGreyBackground = Colors.grey.shade300;

  static const Color _lightPrimaryColor = Color(0xFFED247C);
  //static const Color _lightPrimaryVariantColor = Color(0xFFEA2E80);
  //static const Color _lightSecondaryColor = Color(0xFFCD065E);
  //static const Color _lightSecondaryVariantColor = Color(0xFFC42C74);

  static final CupertinoThemeData lightTheme = CupertinoThemeData(
    barBackgroundColor: Colors.white,
    primaryColor: _lightPrimaryColor,
    primaryContrastingColor: secondaryColor, // _lightSecondaryColor,
    scaffoldBackgroundColor: Colors.white,
    textTheme: _lightTextTheme,
  );

  static final CupertinoTextThemeData _lightTextTheme = CupertinoTextThemeData(
    primaryColor: _lightPrimaryColor,
    textStyle: TextStyle(
      fontFamily: "SFUIDisplay",
      color: CupertinoColors.black,
    ),
    navTitleTextStyle: _lightScreenSubHeadTextStyle,
    navLargeTitleTextStyle: _lightScreenHeadingTextStyle,
    pickerTextStyle: _lightScreenHeading4TextStyle,
  );

  static final TextStyle _lightScreenHeadingTextStyle = TextStyle(
      fontFamily: "SFUIDisplay",
      fontWeight: FontWeight.w700,
      fontSize: 21,
      color: Colors.black);
  static final TextStyle _lightScreenSubHeadTextStyle = TextStyle(
      fontSize: 17,
      color: Colors.black, //color: Colors.grey[900],
      letterSpacing: 0.15,
      fontWeight: FontWeight.w700);
  static final TextStyle _lightScreenHeading4TextStyle = TextStyle(
    fontSize: 17.0,
    color: Color(0xff78849E),
    fontWeight: FontWeight.w600,
  );
}
