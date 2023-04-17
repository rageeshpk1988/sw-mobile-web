import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../util/app_theme.dart';
import '../../../util/app_theme_cupertino.dart';
import '/src/providers/auth.dart';
import '../../../adaptive/adaptive_theme.dart';
import '/helpers/route_arguments.dart';

import '/src/providers/user.dart';
import '/util/dialogs.dart';
import '../../../helpers/global_validations.dart';
import '../../../util/notify_user.dart';
import '../../../util/password_form_field.dart';
import '../../../util/ui_helpers.dart';
import '../../../widgets/rounded_button.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);
  static String routeName = '/forgotpassword';

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
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
    TextStyle _textViewStyle = Platform.isIOS
        ? AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
            .copyWith(fontSize: 16, fontWeight: FontWeight.w400)
        : AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontSize: 16, fontWeight: FontWeight.w400);

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/login_banner.png'),
                    verticalSpaceLarge,
                    Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          //PASSWORD SHARED TO EMAIL
                          TextFormField(
                            focusNode: _emailPasswordFocusNode,
                            style: _textViewStyle,
                            decoration: AdaptiveTheme.textFormFieldDecoration(
                                context,
                                'Password shared to Email',
                                _emailPasswordFocusNode),
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
                                context,
                                'Confirm Password',
                                _confirPasswordFocusNode),
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
                                if (!GlobalValidations.validatePassword(
                                    value!)) {
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
                          SizedBox(
                            width: double.infinity,
                            child: RoundButton(
                              title: 'Submit',
                              color: AdaptiveTheme.primaryColor(context),
                              onPressed: () {
                                _updatePassword(
                                    context, args.mobileNumber, args.parentId);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
