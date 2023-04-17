import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '/src/login/screens/forgot_password_web.dart';
import '/webviews/webview_shop_web.dart';
import 'package:sign_button/constants.dart';
import 'package:sign_button/create_button.dart';
import '../../../helpers/global_variables.dart';
import '../../../webviews/webview_shop.dart';

import '../../../src/models/socialaccesstoken_request.dart';
import '../../../src/providers/google_signin_controller.dart';

import '../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../adaptive/adaptive_theme.dart';

import '../../../widgets/web_banner.dart';
import '../../../widgets/web_bottom_bar.dart';
import '../../models/ad_response.dart';
import '../../models/socialaccesstoken_response.dart';

import '/src/providers/user.dart';
import '../../../helpers/route_arguments.dart';
import '../../../util/ui_helpers.dart';

import '../../../src/login/screens/login_mobile.dart';

import '../../../src/providers/auth.dart';
import '../../../util/app_theme.dart';
import '../../../util/dialogs.dart';
import '../../../util/password_form_field.dart';

class LoginWithPasswordWeb extends StatefulWidget {
  const LoginWithPasswordWeb({Key? key}) : super(key: key);
  static String routeName = '/web-login-withpassword';

  @override
  _LoginWithPasswordWebState createState() => _LoginWithPasswordWebState();
}

class _LoginWithPasswordWebState extends State<LoginWithPasswordWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
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
      if (kIsWeb) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewShopifyWeb(
                  initialUrl: Uri.encodeFull(productUrl),
                  updateHandler: () {}, // updateADData,
                  socialUpdateHandler: () {})), // updateSocialADData)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewShopify(
                  initialUrl: Uri.encodeFull(productUrl),
                  updateHandler: () {}, // updateADData,
                  socialUpdateHandler: () {})), // updateSocialADData)),
        );
      }

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
        if (kIsWeb) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewShopifyWeb(
                    initialUrl: Uri.encodeFull(productUrl),
                    updateHandler: () {}, // updateADData,
                    socialUpdateHandler: () {})), // updateSocialADData)),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewShopify(
                    initialUrl: Uri.encodeFull(productUrl),
                    updateHandler: () {}, // updateADData,
                    socialUpdateHandler: () {})), // updateSocialADData)),
          );
        }
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
        if (kIsWeb) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewShopifyWeb(
                    initialUrl: Uri.encodeFull(productUrl),
                    updateHandler: () {}, // updateADData,
                    socialUpdateHandler: () {})), // updateSocialADData)),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewShopify(
                    initialUrl: Uri.encodeFull(productUrl),
                    updateHandler: () {}, // updateADData,
                    socialUpdateHandler: () {})), // updateSocialADData)),
          );
        }
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
            'A temporary password has been sent to your registered email!',
            web: true);

        UpdatePasswordArgs args = UpdatePasswordArgs(mobileNumber, parentId);
        Navigator.of(context)
            .pushNamed(ForgotPasswordWeb.routeName, arguments: args);
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
    TextStyle _textViewStyle = AppTheme.lightTheme.textTheme.bodySmall!
        .copyWith(fontSize: 14, fontWeight: FontWeight.w300);

    Widget _pageBody() {
      return Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 40),
              child: Row(
                children: [
                  Text(
                    'Login',
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
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!args.mobileValidated)
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(LoginMobile.routeName);
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
                          style: TextStyle(color: AppTheme.secondaryColor))),
                const Spacer(),
                if (_isLoading && !_forgotPasswordSelected)
                  AdaptiveCircularProgressIndicator()
                else
                  Column(
                    children: [
                      const SizedBox(height: 5),
                      SizedBox(
                        width: screenWidth(context) *
                            (screenWidth(context) > 800
                                ? 0.10
                                : screenWidth(context) > 400
                                    ? 0.20
                                    : 0.40),
                        height: 34,
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
                    ],
                  ),
              ],
            ),
            verticalSpaceMedium,

            if (args.showSocialButton == true)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: screenWidth(context) *
                        (screenWidth(context) > 800
                            ? 0.08
                            : screenWidth(context) > 400
                                ? 0.15
                                : 0.35),
                    height: 34,
                    child: SignInButton(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(7.0)),
                        elevation: 0.0,
                        btnColor: Colors.white,
                        btnText: 'Sign In',
                        btnTextColor: Colors.blue,
                        width: double.infinity,
                        buttonType: ButtonType.googleDark,
                        onPressed: _isLoading && !_forgotPasswordSelected
                            ? null
                            : () {
                                _submitSocial(
                                    args.socialUpdateHandler, "google");
                              }),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: screenWidth(context) *
                        (screenWidth(context) > 800
                            ? 0.08
                            : screenWidth(context) > 400
                                ? 0.15
                                : 0.35),
                    height: 34,
                    child: SignInButton(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(7.0)),
                        elevation: 0.0,
                        width: double.infinity,
                        buttonType: ButtonType.facebook,
                        btnColor: Colors.white,
                        btnText: 'Sign In',
                        btnTextColor: Colors.black54,
                        onPressed: _isLoading && !_forgotPasswordSelected
                            ? null
                            : () {
                                _submitSocial(
                                    args.socialUpdateHandler, "facebook");
                              }),
                  ),
                ],
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
                width: screenWidth(context) *
                    (screenWidth(context) > 800
                        ? 0.40
                        : screenWidth(context) > 400
                            ? 0.60
                            : 0.95),
                height: screenWidth(context) > 400
                    ? screenHeight(context) * 0.80
                    : null,
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
