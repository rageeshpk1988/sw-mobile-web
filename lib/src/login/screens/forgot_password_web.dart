import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../util/app_theme.dart';

import '../../../widgets/web_banner.dart';
import '../../../widgets/web_bottom_bar.dart';
import '/src/providers/auth.dart';
import '../../../adaptive/adaptive_theme.dart';
import '/helpers/route_arguments.dart';

import '/src/providers/user.dart';
import '/util/dialogs.dart';
import '../../../helpers/global_validations.dart';
import '../../../util/notify_user.dart';
import '../../../util/password_form_field.dart';
import '../../../util/ui_helpers.dart';

class ForgotPasswordWeb extends StatefulWidget {
  const ForgotPasswordWeb({Key? key}) : super(key: key);
  static String routeName = '/web-forgotpassword';

  @override
  _ForgotPasswordWebState createState() => _ForgotPasswordWebState();
}

class _ForgotPasswordWebState extends State<ForgotPasswordWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  Map<String, String> _authData = {
    'tempPassword': '',
    'password': '',
  };
  final _passwordController = TextEditingController();
  final _tempPasswordController = TextEditingController();
  var _isLoading = false;
  final _emailPasswordFocusNode = FocusNode();
  final _confirPasswordFocusNode = FocusNode();

  @override
  void initState() {
    _emailPasswordFocusNode.addListener(_onOnFocusNodeEvent);
    _confirPasswordFocusNode.addListener(_onOnFocusNodeEvent);
    super.initState();
  }

  _onOnFocusNodeEvent() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailPasswordFocusNode.dispose();
    _confirPasswordFocusNode.dispose();
    _passwordController.dispose();
    _tempPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword(
      BuildContext ctx, String mobileNumber, int parentId) async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      _authData['password'] = _passwordController.text;
      var loginResponse =
          Provider.of<Auth>(context, listen: false).loginResponse;
      var _updated = await Provider.of<User>(context, listen: false)
          .updatePassword(mobileNumber, parentId, _authData['tempPassword'],
              _authData['password']);
      NotifyUser().showSnackBar('Your password has been reset!', ctx);

      if (_updated) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
        //this should be removed
        // Navigator.of(context).pushReplacementNamed(LoginWithPassword.routeName,
        //     arguments: LoginWithPasswordArgs(true, mobileNumber));
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      await Dialogs().ackAlert(context, 'An error occured', error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    UpdatePasswordArgs args =
        ModalRoute.of(context)!.settings.arguments as UpdatePasswordArgs;
    TextStyle _textViewStyle = AppTheme.lightTheme.textTheme.bodySmall!
        .copyWith(fontSize: 16, fontWeight: FontWeight.w400);

    Widget _pageBody() {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 40),
              child: Row(
                children: [
                  Text(
                    'Reset Password',
                    style: TextStyle(
                        letterSpacing: 0.0,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Column(
                children: <Widget>[
                  //PASSWORD SHARED TO EMAIL
                  TextFormField(
                    focusNode: _emailPasswordFocusNode,
                    style: _textViewStyle,
                    decoration: AdaptiveTheme.textFormFieldDecoration(context,
                        'Password shared to Email', _emailPasswordFocusNode),
                    textInputAction: TextInputAction.done,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please provide the password shared to email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['tempPassword'] = value!;
                    },
                  ),
                  //PASSWORD SHARED TO EMAIL
                  verticalSpaceSmall,
                  //PASSWORD
                  PasswordFormField(
                    isLoading: _isLoading,
                    controller: _passwordController,
                    login: false,
                    label: 'New Password',
                  ),
                  //PASSWORD
                  verticalSpaceSmall,
                  //CONFIRM PASSWORD
                  TextFormField(
                    focusNode: _confirPasswordFocusNode,
                    style: _textViewStyle,
                    decoration: AdaptiveTheme.textFormFieldDecoration(
                        context, 'Confirm Password', _confirPasswordFocusNode),
                    textInputAction: TextInputAction.done,
                    obscureText: true,
                    onFieldSubmitted: (_) {
                      //  _saveForm();
                    },
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords does not match!';
                      }
                      if (value != '') {
                        if (!GlobalValidations.validatePassword(value!)) {
                          return 'The password does not meet the password policy';
                        }
                      }
                      return null;
                    },
                  ),
                  //CONFIRM PASSWORD
                  verticalSpaceSmall,
                  NotifyUser().showPasswordPolicyText(),
                  verticalSpaceMedium,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: screenWidth(context) * 0.10,
                        height: 34,
                        child: appButton(
                          context: context,
                          width: 20,
                          height: 20,
                          title: 'Submit',
                          titleFontSize: 16,
                          titleColour: AdaptiveTheme.primaryColor(context),
                          onPressed: () {
                            _updatePassword(
                                context, args.mobileNumber, args.parentId);
                          },
                          borderColor: AdaptiveTheme.primaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      endDrawer: WebBannerDrawer(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              WebBanner(
                showMenu: true,
                showHomeButton: true,
                showProfileButton: true,
                scaffoldKey: scaffoldKey,
              ),
              Container(
                width: screenWidth(context) * 0.40,
                //height: screenHeight(context) * 0.98,
                child: _isLoading == false
                    ? _pageBody()
                    : Center(child: AdaptiveCircularProgressIndicator()),
              ),
              Spacer(),
              WebBottomBar(),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
