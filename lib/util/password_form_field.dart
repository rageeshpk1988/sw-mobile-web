import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../adaptive/adaptive_theme.dart';
import '../helpers/global_validations.dart';
import 'app_theme.dart';
import 'app_theme_cupertino.dart';

class PasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final bool isLoading;
  final bool login;
  final String label;

  const PasswordFormField({
    required this.controller,
    required this.login,
    required this.label,
    required this.isLoading,
  });

  @override
  _PasswordFormFieldState createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  final _pwdFocusNode = FocusNode();

  @override
  void initState() {
    _pwdFocusNode.addListener(_onOnFocusNodeEvent);
    super.initState();
  }

  @override
  void dispose() {
    _pwdFocusNode.dispose();
    super.dispose();
  }

  _onOnFocusNodeEvent() {
    setState(() {});
  }

  bool _showPassword = false;
  @override
  Widget build(BuildContext context) {
    TextStyle _textViewStyle = kIsWeb || Platform.isAndroid
        ? AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontSize: 16, fontWeight: FontWeight.w400)
        : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
            .copyWith(fontSize: 16, fontWeight: FontWeight.w400);

    return TextFormField(
      enabled: widget.isLoading ? false : true,
      controller: widget.controller,
      focusNode: _pwdFocusNode,
      style: _textViewStyle,
      decoration: InputDecoration(
        errorMaxLines: 2,
        errorStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
        labelText: widget.label,
        labelStyle: kIsWeb || Platform.isAndroid
            ? AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w200,
                color: _pwdFocusNode.hasFocus
                    ? AdaptiveTheme.primaryColor(context)
                    : Colors.grey.shade900)
            : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w300,
                color: _pwdFocusNode.hasFocus
                    ? AdaptiveTheme.primaryColor(context)
                    : Colors.grey.shade900),
        focusedBorder: AdaptiveTheme.outlineInputBorder(context),
        border: AdaptiveTheme.outlineInputBorder(context),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
          child: Icon(
            _showPassword ? Icons.visibility : Icons.visibility_off,
            color: AdaptiveTheme.primaryColor(context),
          ),
        ),
      ),
      obscureText: !_showPassword,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please provide a password!';
        }
        if (!GlobalValidations.validatePassword(value)) {
          return 'The password does not meet the password policy';
        }
        return null;
      },
    );
  }
}
