import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFFED247C);
  static const Color secondaryColor = Color(0xFF7F2A86);
  static const Color secondaryLightColor = Color(0xFFC767CE);
  static Color scaffoldGreyBackground = Colors.grey.shade300;

  static const Color _lightPrimaryColor = Color(0xFFED247C);
  static const Color _lightPrimaryVariantColor = Color(0xFFEA2E80);
  static const Color _lightSecondaryColor = Color(0xFFCD065E);
  static const Color _lightSecondaryVariantColor = Color(0xFFC42C74);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: _lightPrimaryColor,
    scaffoldBackgroundColor: Colors.white,
    textSelectionTheme: TextSelectionThemeData(cursorColor: _lightPrimaryColor),
    appBarTheme: AppBarTheme(
      color: Colors.white,
      iconTheme: IconThemeData(color: _lightSecondaryVariantColor),
    ),
    iconTheme: IconThemeData(
      color: _lightPrimaryColor,
    ),
    textTheme: _lightTextTheme,
    fontFamily: "SFUIDisplay",
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: ColorScheme.light(
      primary: _lightPrimaryColor,
      primaryContainer: _lightPrimaryVariantColor,
      secondary: _lightSecondaryColor,
      secondaryContainer: _lightSecondaryVariantColor,
    ).copyWith(secondary: _lightPrimaryColor),
    scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: MaterialStateProperty.all(true),
        thickness: MaterialStateProperty.all(10),
        thumbColor: MaterialStateProperty.all(_lightPrimaryColor),
        radius: Radius.circular(50),
        minThumbLength: 10),
  );

  // static final TextTheme _lightTextTheme = TextTheme(
  //   headline1: _lightScreenHeadingTextStyle,
  //   headline2: _lightScreenSubHeadTextStyle,
  //   headline4: _lightScreenHeading4TextStyle,
  //   subtitle1: _lightScreenSubTitleTextStyle,
  //   bodyText1: _lightScreenBody1TextStyle,
  //   bodyText2: _lightScreenBody2TextStyle,
  //   button: _lightScreenButtonTextStyle,
  //   caption: _lightScreenCaptionTextStyle,
  //   overline: _lightScreenOverLineTextStyle,
  // );
  static final TextTheme _lightTextTheme = TextTheme(
    titleLarge: _headingH1,
    titleMedium: _headingH2,
    titleSmall: _headingH3,
    headlineMedium: _headingH4,
    bodyLarge: _paragraphP1,
    bodyMedium: _paragraphP2,
    bodySmall: _paragraphP2_1,
    labelSmall: _smallText,
    displaySmall: _links,
  );

  static final TextStyle _headingH1 = TextStyle(
    fontFamily: "SFUIDisplay",
    fontWeight: FontWeight.w700,
    fontSize: 21,
    color: Colors.black,
    letterSpacing: 0.0,
  );
  static final TextStyle _headingH2 = TextStyle(
    fontFamily: "SFUIDisplay",
    fontWeight: FontWeight.w700,
    fontSize: 19,
    color: Colors.black,
    letterSpacing: 0.0,
  );
  static final TextStyle _headingH3 = TextStyle(
    fontFamily: "SFUIDisplay",
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: Colors.black,
    letterSpacing: 0.0,
  );
  static final TextStyle _headingH4 = TextStyle(
    fontFamily: "SFUIDisplay",
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: Colors.black,
    letterSpacing: 0.0,
  );
  static final TextStyle _paragraphP1 = TextStyle(
    fontFamily: "SFUIDisplay",
    fontWeight: FontWeight.w300,
    fontSize: 21,
    color: Colors.black,
    letterSpacing: 0.0,
  );
  static final TextStyle _paragraphP2 = TextStyle(
    fontFamily: "SFUIDisplay",
    fontWeight: FontWeight.w300,
    fontSize: 17,
    color: Colors.black,
    letterSpacing: 0.0,
  );
  static final TextStyle _paragraphP2_1 = TextStyle(
    fontFamily: "SFUIDisplay",
    fontWeight: FontWeight.w500,
    fontSize: 17,
    color: Colors.black,
    letterSpacing: 0.0,
  );
  static final TextStyle _smallText = TextStyle(
    fontFamily: "SFUIDisplay",
    fontWeight: FontWeight.w300,
    fontSize: 12,
    color: Colors.black,
    letterSpacing: 0.0,
  );
  static final TextStyle _links = TextStyle(
    fontFamily: "SFUIDisplay",
    fontWeight: FontWeight.w300,
    fontSize: 15,
    color: Colors.black,
    letterSpacing: 0.0,
  );
  // static final TextStyle _lightScreenHeadingTextStyle = TextStyle(
  //     fontFamily: "IBM Plex Sans",
  //     fontWeight: FontWeight.w700,
  //     fontSize: 26,
  //     color: Colors.black);
  // static final TextStyle _lightScreenSubHeadTextStyle = TextStyle(
  //     fontSize: 18.0,
  //     color: Colors.grey[900],
  //     letterSpacing: 0.15,
  //     fontWeight: FontWeight.w700);
  // static final TextStyle _lightScreenHeading4TextStyle = TextStyle(
  //     fontSize: 16.0, color: Color(0xff78849E), fontWeight: FontWeight.w500);
  // static final TextStyle _lightScreenSubTitleTextStyle =
  //     TextStyle(fontSize: 14.0, color: Colors.grey, letterSpacing: 0.15);
  // static final TextStyle _lightScreenBody1TextStyle = TextStyle(
  //     fontSize: 16.0,
  //     color: Color(0xFF000000),
  //     letterSpacing: 0.5,
  //     fontWeight: FontWeight.w400);
  // static final TextStyle _lightScreenBody2TextStyle = TextStyle(
  //     fontSize: 14.0,
  //     color: Color(0xFF000000),
  //     letterSpacing: 0.25,
  //     fontWeight: FontWeight.w300);
  // static final TextStyle _lightScreenButtonTextStyle =
  //     TextStyle(fontSize: 14.0, color: Colors.white, letterSpacing: 1.25);
  // static final TextStyle _lightScreenCaptionTextStyle =
  //     TextStyle(fontSize: 12.0, color: Color(0xFF000000), letterSpacing: 0.4);
  // static final TextStyle _lightScreenOverLineTextStyle =
  //     TextStyle(fontSize: 10.0, color: Color(0xFF000000), letterSpacing: 1.5);

}
