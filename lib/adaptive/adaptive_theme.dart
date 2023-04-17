import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../util/app_theme.dart';
import '../../util/app_theme_cupertino.dart';

class AdaptiveTheme {
  static Color primaryColor(BuildContext context) =>
      kIsWeb || Platform.isAndroid
          ? AppTheme.lightTheme.primaryColor
          : AppThemeCupertino.lightTheme.primaryColor;

  static Color secondaryColor(BuildContext context) =>
      kIsWeb || Platform.isAndroid
          ? AppTheme.secondaryColor
          : AppThemeCupertino.lightTheme.primaryContrastingColor;

  static InputBorder outlineInputBorder(BuildContext context) =>
      OutlineInputBorder(
        borderSide: BorderSide(
            color: kIsWeb || Platform.isAndroid
                ? AppTheme.lightTheme.primaryColor
                : AppThemeCupertino.lightTheme.primaryColor),
      );
  static UnderlineInputBorder underlineInputBorder(BuildContext context) =>
      UnderlineInputBorder(
        borderSide: BorderSide(
            color: kIsWeb || Platform.isAndroid
                ? AppTheme.lightTheme.primaryColor
                : AppThemeCupertino.lightTheme.primaryColor),
      );
  static InputDecoration textFormFieldDecoration(
          BuildContext context, String labelText, FocusNode focusNode) =>
      InputDecoration(
        errorStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
        labelText: labelText,
        errorMaxLines: 2,
        labelStyle: kIsWeb || Platform.isAndroid
            ? AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w200,
                color: focusNode.hasFocus
                    ? AdaptiveTheme.primaryColor(context)
                    : Colors.grey.shade900)
            : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
                .copyWith(fontSize: 15, fontWeight: FontWeight.w300,color:focusNode.hasFocus
            ? AdaptiveTheme.primaryColor(context)
            : Colors.grey.shade900 ),
        focusedBorder: AdaptiveTheme.outlineInputBorder(context),
        border: AdaptiveTheme.outlineInputBorder(context),
      );

  static InputDecoration dropdownSearchDecoration(
          BuildContext context, String labelText, FocusNode focusNode) =>
      InputDecoration(
          errorStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
          floatingLabelStyle:  kIsWeb || Platform.isAndroid
              ? AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w200,
              color: focusNode.hasFocus
                  ? AdaptiveTheme.primaryColor(context)
                  : Colors.grey.shade900)
              : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
              .copyWith(fontSize: 15, fontWeight: FontWeight.w300,color:focusNode.hasFocus
              ? AdaptiveTheme.primaryColor(context)
              : Colors.grey.shade900 ),
          labelText: labelText,
          labelStyle:  kIsWeb || Platform.isAndroid
              ? AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w200,
              color: focusNode.hasFocus
                  ? AdaptiveTheme.primaryColor(context)
                  : Colors.grey.shade900)
              : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
              .copyWith(fontSize: 15, fontWeight: FontWeight.w300,color:focusNode.hasFocus
              ? AdaptiveTheme.primaryColor(context)
              : Colors.grey.shade900 ),
          contentPadding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
          focusedBorder: AdaptiveTheme.outlineInputBorder(context),
          border: OutlineInputBorder(
              borderSide: BorderSide(
                  color: kIsWeb || Platform.isAndroid
                      ? AppTheme.lightTheme.primaryColor
                      : AppThemeCupertino.lightTheme.primaryColor))
          //border: AdaptiveTheme.outlineInputBorder(context),
          );
  // static textTheme(BuildContext context) => Platform.isIOS
  //     ? AppThemeCupertino.lightTheme.textTheme
  //     : AppTheme.lightTheme.textTheme;
}
