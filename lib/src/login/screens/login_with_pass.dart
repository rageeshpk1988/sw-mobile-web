import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sign_button/constants.dart';
import 'package:sign_button/create_button.dart';
import '../../../helpers/global_variables.dart';
import '../../../webviews/webview_shop.dart';

import '../../../src/models/socialaccesstoken_request.dart';
import '../../../src/providers/google_signin_controller.dart';

import '../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../adaptive/adaptive_theme.dart';
import '../../../util/app_theme_cupertino.dart';
import '../../models/ad_response.dart';
import '../../models/socialaccesstoken_response.dart';
import '/src/login/screens/forgot_password.dart';
import '/src/providers/user.dart';
import '../../../helpers/route_arguments.dart';
import '../../../util/ui_helpers.dart';

import '../../../src/login/screens/login_mobile.dart';

import '../../../src/providers/auth.dart';
import '../../../util/app_theme.dart';
import '../../../util/dialogs.dart';
import '../../../util/password_form_field.dart';

class LoginWithPassword extends StatefulWidget {
  const LoginWithPassword({Key? key}) : super(key: key);
  static String routeName = '/login-withpassword';

  @override
  _LoginWithPasswordState createState() => _LoginWithPasswordState();
}

class _LoginWithPasswordState extends State<LoginWithPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  Map<String, String> _authData = {
    'mobileNumber': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  bool _forgotPasswordSelected = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(Function updateHandler) async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _forgotPasswordSelected = false;
      _isLoading = true;
    });
    try {
      _authData['password'] = _passwordController.text;
      await Provider.of<Auth>(context, listen: false)
          .loginAD(_authData['mobileNumber']!, _authData['password']!);
      updateHandler();
      ADResponse? adResponse =
          Provider.of<Auth>(context, listen: false).adResponse;
      setState(() {
        _isLoading = false;
      });
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => NewFeedScreen()),
      // );

      String productUrl =
          'https://store.xecurify.com/moas/broker/login/jwt/callback/20959/jwtsso/${adResponse!.idToken}?relay=https://store.xecurify.com/moas/broker/login/shopify/${GlobalVariables.shopify_AccountDomain}/account?redirect_endpoint=index';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => WebViewShopify(
                initialUrl: Uri.encodeFull(productUrl),
                updateHandler: () {}, // updateADData,
                socialUpdateHandler: () {})), // updateSocialADData)),
      );
      /*Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LandingPage()),
      );*/
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      await Dialogs().ackAlert(context, 'An error occured', error.toString());
    }
  }

  Future<void> _submitSocial(Function updateHandler, String _appName) async {
    if (_appName == "google") {
      // print(_appName);
      final provider =
          Provider.of<GoogleSignInProvider>(context, listen: false);
      SocialAdRequest _socialAccessToken = await provider.googleLogin(context);
      setState(() {
        _forgotPasswordSelected = false;
        _isLoading = true;
      });
      // print(_socialAccessToken);
      try {
        //_authData['password'] = _passwordController.text;
        await Provider.of<Auth>(context, listen: false).loginADSocial(
            _socialAccessToken.token, _authData['mobileNumber']!, _appName);
        updateHandler();
        SocialAdResponse? socialAccessTokenResponse =
            Provider.of<Auth>(context, listen: false).socialAccessTokenResponse;
        /*setState(() {
           _isLoading = false;
         });*/
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => NewFeedScreen()),
        // );
        String productUrl =
            'https://store.xecurify.com/moas/broker/login/jwt/callback/20959/jwtsso/${socialAccessTokenResponse!.token}?relay=https://store.xecurify.com/moas/broker/login/shopify/${GlobalVariables.shopify_AccountDomain}/account?redirect_endpoint=index';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewShopify(
                  initialUrl: Uri.encodeFull(productUrl),
                  updateHandler: () {}, // updateADData,
                  socialUpdateHandler: () {})), // updateSocialADData)),
        );
        /*Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LandingPage()),
        );*/
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        await Dialogs().ackAlert(context, 'An error occured', error.toString());
      }
    }else if (_appName == "apple"){
      print(_appName);
      final provider =
      Provider.of<GoogleSignInProvider>(context, listen: false);
      SocialAdRequest _socialAccessToken = await provider.appleLogin(context);
      setState(() {
        _forgotPasswordSelected = false;
        _isLoading = true;
      });
      print(_socialAccessToken);
      try {
        //_authData['password'] = _passwordController.text;
        await Provider.of<Auth>(context, listen: false).loginADSocial(
            _socialAccessToken.token, _authData['mobileNumber']!, _appName);
        updateHandler();
        SocialAdResponse? socialAccessTokenResponse =
            Provider.of<Auth>(context, listen: false).socialAccessTokenResponse;
        /*setState(() {
           _isLoading = false;
         });*/
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => NewFeedScreen()),
        // );
        String productUrl =
            'https://store.xecurify.com/moas/broker/login/jwt/callback/20959/jwtsso/${socialAccessTokenResponse!.token}?relay=https://store.xecurify.com/moas/broker/login/shopify/${GlobalVariables.shopify_AccountDomain}/account?redirect_endpoint=index';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewShopify(
                  initialUrl: Uri.encodeFull(productUrl),
                  updateHandler: () {}, // updateADData,
                  socialUpdateHandler: () {})), // updateSocialADData)),
        );
        /*Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LandingPage()),
        );*/
      } catch (error) {
        provider.appleSignOut();
        setState(() {
          _isLoading = false;
        });
        await Dialogs().ackAlert(context, 'An error occurred', "Unable to login, please try again");
      }
    } else {
      // print(_appName);
      final provider =
          Provider.of<GoogleSignInProvider>(context, listen: false);
      SocialAdRequest _socialAccessToken =
          await provider.facebookLogin(context);
      setState(() {
        _forgotPasswordSelected = false;
        _isLoading = true;
      });
      try {
        // _authData['password'] = _passwordController.text;
        await Provider.of<Auth>(context, listen: false).loginADSocial(
            _socialAccessToken.token, _authData['mobileNumber']!, _appName);
        updateHandler();
        SocialAdResponse? socialAccessTokenResponse =
            Provider.of<Auth>(context, listen: false).socialAccessTokenResponse;
        /*setState(() {
           _isLoading = false;
         });*/
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => NewFeedScreen()),
        // );
        String productUrl =
            'https://store.xecurify.com/moas/broker/login/jwt/callback/20959/jwtsso/${socialAccessTokenResponse!.token}?relay=https://store.xecurify.com/moas/broker/login/shopify/${GlobalVariables.shopify_AccountDomain}/account?redirect_endpoint=index';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewShopify(
                  initialUrl: Uri.encodeFull(productUrl),
                  updateHandler: () {}, // updateADData,
                  socialUpdateHandler: () {})), // updateSocialADData)),
        );
        /*Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LandingPage()),
        );*/
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        await Dialogs().ackAlert(context, 'An error occured', error.toString());
      }
    }
  }

  Future<void> _resetPasswordRequest(String mobileNumber) async {
    setState(() {
      _forgotPasswordSelected = true;
      _isLoading = true;
    });
    try {
      // var loginResponse =
      //     Provider.of<Auth>(context, listen: false).loginResponse;
      int? parentId = await Provider.of<User>(context, listen: false)
          .resetPasswordRequest(mobileNumber);
      if (parentId != null) {
        setState(() {
          _forgotPasswordSelected = false;
          _isLoading = false;
        });
        // await Dialogs().ackAlert(context, 'Alert',
        //     'A temporary password has been sent to your registered email!');
        await Dialogs().ackInfoAlert(context,
            'A temporary password has been sent to your registered email!');

        UpdatePasswordArgs args = UpdatePasswordArgs(mobileNumber, parentId);
        Navigator.of(context)
            .pushNamed(ForgotPassword.routeName, arguments: args);
      }
    } catch (error) {
      setState(() {
        _forgotPasswordSelected = false;
        _isLoading = false;
      });
      await Dialogs().ackAlert(context, 'An error occured', error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as LoginWithPasswordArgs;
    TextStyle _textViewStyle = kIsWeb
        ? AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontSize: 14, fontWeight: FontWeight.w300)
        : Platform.isIOS
            ? AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
                .copyWith(fontSize: 14, fontWeight: FontWeight.w300)
            : AppTheme.lightTheme.textTheme.bodySmall!
                .copyWith(fontSize: 14, fontWeight: FontWeight.w300);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Image.asset('assets/images/Mascot.png',
                      width: 130, height: 100),
                  Image.asset('assets/images/sw_appbar_logo.png',
                      width: 200, height: 60),
                  const SizedBox(height: 20),
                  //MOBILE NUMBER
                  TextFormField(
                    enabled: false,
                    initialValue: args.mobileNumber,
                    style: _textViewStyle,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                    ],
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please provide the mobile number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['mobileNumber'] = value!;
                    },
                  ),
                  //MOBILE NUMBER
                  verticalSpaceSmall,
                  //PASSWORD
                  PasswordFormField(
                    isLoading: _isLoading,
                    controller: _passwordController,
                    login: true,
                    label: 'Password',
                  ),
                  //PASSWORD
                  Row(
                    mainAxisAlignment: !args.mobileValidated
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.end,
                    children: [
                      if (!args.mobileValidated)
                        TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(LoginMobile.routeName);
                            },
                            child: Text(
                              'New Registration',
                              style: TextStyle(color: AppTheme.secondaryColor),
                            )),
                      if (_isLoading && _forgotPasswordSelected)
                        AdaptiveCircularProgressIndicator()
                      else
                        TextButton(
                            onPressed: _isLoading && !_forgotPasswordSelected
                                ? null
                                : () {
                                    _resetPasswordRequest(args.mobileNumber);
                                  },
                            child: Text('Forgot Password',
                                style:
                                    TextStyle(color: AppTheme.secondaryColor)))
                    ],
                  ),
                  verticalSpaceMedium,
                  if (_isLoading && !_forgotPasswordSelected)
                    AdaptiveCircularProgressIndicator()
                  else
                    Column(children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: appButton(
                          context: context,
                          width: 20,
                          height: 20,
                          title: 'Login',
                          titleFontSize: 16,
                          titleColour: AdaptiveTheme.primaryColor(context),
                          onPressed: () {
                            _submit(args.updateHandler);
                          },
                          borderColor: AdaptiveTheme.primaryColor(context),
                        ),
                      ),
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: RoundButton(
                      //       title: 'Login',
                      //       color: AdaptiveTheme.primaryColor(context),
                      //       onPressed: () {
                      //         _submit(args.updateHandler);
                      //       }),
                      // ),
                      verticalSpaceSmall,

                      if (args.showSocialButton == true)
                        SizedBox(
                          height: 50,
                          child: SignInButton(
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(7.0)),
                              elevation: 0.0,
                              btnColor: Colors.white,
                              btnTextColor: Colors.blue,
                              width: double.infinity,
                              buttonType: ButtonType.googleDark,
                              onPressed: () {
                                _submitSocial(
                                    args.socialUpdateHandler, "google");
                              }),
                        ),
                      // SignInButton(
                      //     width: double.infinity,
                      //     buttonType: ButtonType.googleDark,
                      //     onPressed: () {
                      //       _submitSocial(args.socialUpdateHandler, "google");
                      //     }),
                      verticalSpaceSmall,
                      if (args.showSocialButton == true)
                        SizedBox(
                          height: 50,
                          child: SignInButton(
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(7.0)),
                              elevation: 0.0,
                              width: double.infinity,
                              buttonType: ButtonType.facebook,
                              btnColor: Colors.white,
                              btnTextColor: Colors.black54,
                              onPressed: () {
                                // calls facebook login
                                _submitSocial(
                                    args.socialUpdateHandler, "facebook");
                              }),
                        ),
                      verticalSpaceSmall,
                      if (args.showSocialButton == true)
                        if(Platform.isIOS)
                          SizedBox(
                            height: 50,
                            child: SignInButton(
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(7.0)),
                                elevation: 0.0,
                                width: double.infinity,
                                buttonType: ButtonType.apple,
                                btnColor: Colors.white,
                                btnTextColor: Colors.black,
                                onPressed: () {
                                  // calls facebook login
                                  _submitSocial(
                                      args.socialUpdateHandler, "apple");
                                }),
                          ),
                      // SignInButton(
                      //     width: double.infinity,
                      //     buttonType: ButtonType.facebook,
                      //     btnColor: Colors.white,
                      //     btnTextColor: Colors.black,
                      //     onPressed: () {
                      //       _submitSocial(
                      //           args.socialUpdateHandler, "facebook");
                      //     }),
                    ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
