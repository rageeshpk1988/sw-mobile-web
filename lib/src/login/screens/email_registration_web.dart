import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '/widgets/web_banner.dart';
import '/widgets/web_bottom_bar.dart';

import 'package:sign_button/sign_button.dart';

import '../../../helpers/global_variables.dart';
import '../../../src/home/landing/screens/landing_page.dart';

import '../../../util/app_theme.dart';

import '../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../adaptive/adaptive_theme.dart';
import '../../../util/dialogs.dart';
import '../../../util/password_generator.dart';
import '../../intro/web_intro_screen.dart';
import '../../../src/providers/user.dart';
import '../../../util/notify_user.dart';
import '../../../helpers/global_validations.dart';
import '../../../util/ui_helpers.dart';

import '../../../util/password_form_field.dart';
import '../../models/socialaccesstoken_request.dart';
import '../../providers/auth.dart';
import '../../providers/google_signin_controller.dart';

class EmailRegistrationWeb extends StatefulWidget {
  static String routeName = '/web-email-registration';

  @override
  _EmailRegistrationWebState createState() => _EmailRegistrationWebState();
}

class _EmailRegistrationWebState extends State<EmailRegistrationWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey();
  Map<String, String> _registration = {
    'name': '',
    'emailId': '',
    'password': '',
  };
  var _isLoading = false;
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _passwordController = TextEditingController();
  var _enteredMobileNumber = '';
  var _enteredReferralCode = '';
  late double regncardWidth;
  final _referralFocusNodePopup = FocusNode();
  final _referralFocusNode = FocusNode();
  final _referralController = TextEditingController();
  @override
  void initState() {
    _nameFocusNode.addListener(_onOnFocusNodeEvent);
    _emailFocusNode.addListener(_onOnFocusNodeEvent);
    _confirmPasswordFocusNode.addListener(_onOnFocusNodeEvent);
    _referralFocusNodePopup.addListener(_onOnFocusNodeEvent);
    _referralFocusNode.addListener(_onOnFocusNodeEvent);
    super.initState();
  }

  _onOnFocusNodeEvent() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _passwordController.dispose();
    _referralController.dispose();
    _referralFocusNode.dispose();
    _referralFocusNodePopup.dispose();
    super.dispose();
  }

  void updateSocialADData() async {
    setState(() async {});
  }

  void setWidgetLoadingState(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void popScreenHandler() {
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 2);
  }

  // Future<void> _submit() async {
  //   if (await EmailRegistrationService().submit(
  //           context,
  //           _formKey,
  //           _registration,
  //           _passwordController.text,
  //           _enteredMobileNumber,
  //           setWidgetLoadingState,
  //           popScreenHandler,
  //           _enteredReferralCode) ==
  //       false) {
  //     return;
  //   }
  // }

  void navigateToLandingpage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LandingPage()),
    );
  }

  // Future<void> _submitSocial(Function updateHandler, String _appName) async {
  //   await EmailRegistrationService().submitSocial(
  //       context,
  //       updateHandler,
  //       _appName,
  //       _registration,
  //       _enteredMobileNumber,
  //       setWidgetLoadingState,
  //       navigateToLandingpage);
  // }

  Future<void> _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    _registration['password'] = _passwordController.text;
    try {
      //var authToken = '';
      //Provider.of<Auth>(context, listen: false).loginResponse.token;
      var _inserted = await Provider.of<User>(context, listen: false)
          .registerParent(
              _enteredMobileNumber,
              _registration['name']!,
              _registration['emailId']!,
              _registration['password']!,
              _enteredReferralCode)
          .onError((error, stackTrace) async {
        await Dialogs().ackAlert(context, 'Alert', error.toString());
        return false;
      });
      if (_inserted) {
        //CALL login/android/licence to check the status, if not a new user then load login_with_pass screen.
        //else ask the below confirmation message
        bool _mobileValidated = await Provider.of<Auth>(context, listen: false)
            .validateMobileNumber(_enteredMobileNumber, true);
        //TODO:: This needs to be rechecked because we are not validating the AD login
        if (_mobileValidated) {
          setState(() {
            _isLoading = false;
          });
          //Navigator.of(context).pop();
          int count = 0;
          Navigator.of(context).popUntil((_) => count++ >= 2);
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        /*await Dialogs()
            .ackAlert(context, 'Alert', 'Error while saving the data...');*/
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      await Dialogs().ackAlert(context, 'An error occured', error.toString());
    }
  }

  Future _referralDialog(Function updateHandler, String _appName) {
    TextStyle _textViewStyle = AppTheme.lightTheme.textTheme.bodySmall!
        .copyWith(fontSize: 16, fontWeight: FontWeight.w400);
    return showDialog(
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 32.0, right: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 30,
              ),
              //const SizedBox(height: 25),
              Image.asset('assets/images/Mascot.png', width: 70, height: 70),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Hey",
                style: AppTheme.lightTheme.textTheme.bodyMedium!
                    .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              Text(
                "Do you have referral code?",
                style: AppTheme.lightTheme.textTheme.bodyMedium!
                    .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 25,
              ),
              TextFormField(
                enabled: _isLoading ? false : true,
                style: _textViewStyle,
                focusNode: _referralFocusNodePopup,
                inputFormatters: [
                  FilteringTextInputFormatter(RegExp("[a-zA-Z0-9]"),
                      allow: true),
                ],
                controller: _referralController,
                decoration: AdaptiveTheme.textFormFieldDecoration(context,
                    'Enter referral code (Optional)', _referralFocusNodePopup),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(
                height: 25,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  appButton(
                    context: context,
                    width: double.infinity,
                    height: 35,
                    title: 'Submit',
                    titleColour: AdaptiveTheme.primaryColor(context),
                    borderColor: AdaptiveTheme.primaryColor(context),
                    onPressed: () {
                      _enteredReferralCode = _referralController.text;
                      _submitSocial(
                          updateHandler, _appName, _enteredReferralCode);
                      Navigator.of(context).pop();
                    },
                  ),
                  verticalSpaceSmall,
                  appButton(
                    context: context,
                    width: double.infinity,
                    height: 35,
                    title: 'Skip',
                    titleColour: HexColor.fromHex("#333333"),
                    borderColor: HexColor.fromHex('#C9C9C9'),
                    onPressed: () {
                      _enteredReferralCode = "";
                      _submitSocial(
                          updateHandler, _appName, _enteredReferralCode);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
      context: context,
    );
  }

//social registration
  Future<void> _submitSocial(
      Function updateHandler, String _appName, String referralCode) async {
    if (_appName == "google") {
      final provider =
          Provider.of<GoogleSignInProvider>(context, listen: false);
      SocialAdRequest _socialAccessToken = await provider.googleLogin(context);
      setState(() {
        _isLoading = true;
      });
      // final password = RandomPasswordGenerator();
      _registration['password'] = generatePassword(true, true, true, true, 17);
      if (_socialAccessToken.email == null || _socialAccessToken.name == null) {
        setState(() {
          _isLoading = false;
        });
        await Dialogs().ackAlert(context, 'Error',
            'Something Went Wrong...To login email id is mandatory, Please give the required permissions and try again');
      } else {
        try {
          // var authToken =
          //     Provider.of<Auth>(context, listen: false).loginResponse.token;

          var _inserted = await Provider.of<User>(context, listen: false)
              .registerParent(
                  _enteredMobileNumber,
                  _socialAccessToken.name!,
                  _socialAccessToken.email!,
                  _registration['password']!,
                  referralCode)
              .onError((error, stackTrace) async {
            await Provider.of<GoogleSignInProvider>(context, listen: false)
                .googleSignOut();
            await Dialogs().ackAlert(context, 'Alert', error.toString());
            return false;
          });
          if (_inserted) {
            //CALL login/android/licence to check the status, if not a new user then load login_with_pass screen.
            //else ask the below confirmation message
            bool _mobileValidated =
                await Provider.of<Auth>(context, listen: false)
                    .validateMobileNumber(_enteredMobileNumber, true);
            //TODO:: This needs to be rechecked because we are not validating the AD login
            if (_mobileValidated) {
              try {
                //_authData['password'] = _passwordController.text;
                await Provider.of<Auth>(context, listen: false).loginADSocial(
                    _socialAccessToken.token, _enteredMobileNumber, _appName);
                updateHandler();
                /*setState(() {
           _isLoading = false;
         });*/
                //Navigator.of(context).pop();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LandingPage()),
                );
              } catch (error) {
                setState(() {
                  _isLoading = false;
                });
                await Dialogs()
                    .ackAlert(context, 'An error occured', error.toString());
              }
            }
            // setState(() {
            //   _isLoading = false;
            // });
          } else {
            setState(() {
              _isLoading = false;
            });
            /*await Dialogs()
                .ackAlert(context, 'Alert', 'Error while saving the data...');*/
          }
        } catch (error) {
          setState(() {
            _isLoading = false;
          });
          await Dialogs()
              .ackAlert(context, 'An error occured', error.toString());
        }
      }
    } else {
      final provider =
          Provider.of<GoogleSignInProvider>(context, listen: false);
      SocialAdRequest _socialAccessToken =
          await provider.facebookLogin(context);
      setState(() {
        _isLoading = true;
      });
      //  final password = RandomPasswordGenerator();
      _registration['password'] = generatePassword(true, true, true, true, 17);
      if (_socialAccessToken.email == null || _socialAccessToken.name == null) {
        setState(() {
          _isLoading = false;
        });
        await Dialogs().ackAlert(context, 'Error',
            'Something Went Wrong... To login email id is mandatory, Please give the required permissions and try again');
      } else {
        try {
          // var authToken =
          //     Provider.of<Auth>(context, listen: false).loginResponse.token;

          var _inserted = await Provider.of<User>(context, listen: false)
              .registerParent(
                  _enteredMobileNumber,
                  _socialAccessToken.name!,
                  _socialAccessToken.email!,
                  _registration['password']!,
                  referralCode)
              .onError((error, stackTrace) async {
            await Dialogs().ackAlert(context, 'Alert', error.toString());
            return false;
          });
          if (_inserted) {
            //CALL login/android/licence to check the status, if not a new user then load login_with_pass screen.
            //else ask the below confirmation message
            bool _mobileValidated =
                await Provider.of<Auth>(context, listen: false)
                    .validateMobileNumber(_enteredMobileNumber, true);
            //TODO:: This needs to be rechecked because we are not validating the AD login
            if (_mobileValidated) {
              try {
                //_authData['password'] = _passwordController.text;
                await Provider.of<Auth>(context, listen: false).loginADSocial(
                    _socialAccessToken.token, _enteredMobileNumber, _appName);
                updateHandler();
                /*setState(() {
           _isLoading = false;
         });*/
                //Navigator.of(context).pop();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LandingPage()),
                );
              } catch (error) {
                setState(() {
                  _isLoading = false;
                });
                await Dialogs()
                    .ackAlert(context, 'An error occured', error.toString());
              }

              /*setState(() {
              _isLoading = false;
            });*/
              //Navigator.of(context).pop();
              /*int count = 0;
            Navigator.of(context).popUntil((_) => count++ >= 2);*/
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (context) => NewFeedScreen()),
              // );
            }
            // setState(() {
            //   _isLoading = false;
            // });
          } else {
            setState(() {
              _isLoading = false;
            });
            /*await Dialogs()
                .ackAlert(context, 'Alert', 'Error while saving the data...');*/
          }
        } catch (error) {
          setState(() {
            _isLoading = false;
          });
          await Dialogs()
              .ackAlert(context, 'An error occured', error.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    regncardWidth = deviceSize.width * 0.30;
    TextStyle _textViewStyle = AppTheme.lightTheme.textTheme.bodySmall!
        .copyWith(fontSize: 16, fontWeight: FontWeight.w400);

    _enteredMobileNumber = ModalRoute.of(context)!.settings.arguments as String;

    List<Widget> _items = [
      //NAME
      TextFormField(
        enabled: _isLoading ? false : true,
        style: _textViewStyle,
        inputFormatters: [
          LengthLimitingTextInputFormatter(50),
          FilteringTextInputFormatter.deny(RegExp(GlobalVariables.regExpEmoji)),
          FilteringTextInputFormatter.allow(
              RegExp(GlobalVariables.regExpAlphbets))
        ],
        decoration: AdaptiveTheme.textFormFieldDecoration(
            context, 'Name', _nameFocusNode),
        textInputAction: TextInputAction.next,
        focusNode: _nameFocusNode,
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(_emailFocusNode);
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please provide your name';
          }
          return null;
        },
        onSaved: (value) {
          _registration['name'] = value!;
        },
      ),
      //NAME
      //EMAIL
      TextFormField(
        enabled: _isLoading ? false : true,
        style: _textViewStyle,
        decoration: AdaptiveTheme.textFormFieldDecoration(
            context, 'Email Id', _emailFocusNode),
        inputFormatters: [
          LengthLimitingTextInputFormatter(320),
        ],
        keyboardType: TextInputType.emailAddress,
        focusNode: _emailFocusNode,
        validator: (value) {
          if (!GlobalValidations.validateEmail(value!)) {
            return 'Invalid email!';
          }
          return null;
        },
        onSaved: (value) {
          _registration['emailId'] = value!;
        },
      ),
      //EMAIL
      //PASSWORD
      PasswordFormField(
        isLoading: _isLoading,
        controller: _passwordController,
        login: false,
        label: 'Password',
      ),
      //PASSWORD
      //CONFIRM PASSWORD
      TextFormField(
        enabled: _isLoading ? false : true,
        style: _textViewStyle,
        focusNode: _confirmPasswordFocusNode,
        decoration: AdaptiveTheme.textFormFieldDecoration(
            context, 'Confirm Password', _confirmPasswordFocusNode),
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
      //REFERRAL CODE
      TextFormField(
        enabled: _isLoading ? false : true,
        style: _textViewStyle,
        focusNode: _referralFocusNode,
        decoration: AdaptiveTheme.textFormFieldDecoration(
            context, 'Referral Code (Optional)', _referralFocusNode),
        textInputAction: TextInputAction.done,
        inputFormatters: [
          FilteringTextInputFormatter(RegExp("[a-zA-Z0-9]"), allow: true),
        ],
        onFieldSubmitted: (_) {
          //  _saveForm();
        },
        onSaved: (value) {
          if (value != null) {
            _enteredReferralCode = value;
          }
        },
      ),
      //REFERRAL CODE
      //LOGIN BUTTON
      SizedBox(
        width:
            screenWidth(context) * (screenWidth(context) > 800 ? 0.10 : 0.90),
        height: 36,
        child: appButton(
          context: context,
          width: 20,
          height: 20,
          title: 'Login',
          titleFontSize: 16,
          titleColour: AdaptiveTheme.primaryColor(context),
          onPressed: _submit,
          borderColor: AdaptiveTheme.primaryColor(context),
        ),
      ),
      //LOGIN BUTTON
      //GOOGLE SIGNIN
      SizedBox(
        width:
            screenWidth(context) * (screenWidth(context) > 800 ? 0.08 : 0.90),
        height: 36,
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
            onPressed: () {
              // calls google sign in
              _referralDialog(updateSocialADData, "google");
            }),
      ),
      //GOOGLE SIGNIN
      //FACEBOOK SIGNIN
      SizedBox(
        width:
            screenWidth(context) * (screenWidth(context) > 800 ? 0.08 : 0.90),
        height: 36,
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
            onPressed: () {
              // calls facebook login
              _referralDialog(updateSocialADData, "facebook");
            }),
      ),

      //FACEBOOK SIGNIN
    ];

    Widget _pageBody() {
      return Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: SizedBox(
          width: deviceSize.width * 0.3,
          height: deviceSize.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Register !!!',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 3),
              _items[0],
              verticalSpaceTiny,
              _items[1],
              verticalSpaceTiny,
              _items[2],
              verticalSpaceTiny,
              _items[3],
              verticalSpaceTiny,
              _items[4],
              verticalSpaceTiny,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _items[5],
                ],
              ),
              verticalSpaceTiny,
              NotifyUser().showPasswordPolicyText(),
              verticalSpaceSmall,
              if (_isLoading)
                AdaptiveCircularProgressIndicator()
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _items[6],
                    const SizedBox(width: 10),
                    _items[7],
                  ],
                ),
            ],
          ),
        ),
      );
    }

    Widget _pageBodySmall() {
      return SingleChildScrollView(
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: SizedBox(
            width: deviceSize.width * (screenWidth(context) > 400 ? 0.6 : 0.9),
            //height: deviceSize.height * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/sw_appbar_logo.png',
                  width: 200,
                  height: 80,
                ),
                const SizedBox(height: 10),
                Text(
                  'Register !!!',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 3),
                _items[0],
                verticalSpaceTiny,
                _items[1],
                verticalSpaceTiny,
                _items[2],
                verticalSpaceTiny,
                _items[3],
                verticalSpaceTiny,
                _items[4],
                verticalSpaceSmall,
                _items[5],
                verticalSpaceTiny,
                NotifyUser().showPasswordPolicyText(),
                verticalSpaceSmall,
                if (_isLoading) AdaptiveCircularProgressIndicator(),
                if (!_isLoading) _items[6],
                verticalSpaceTiny,
                if (!_isLoading) _items[7],
                verticalSpaceSmall,
              ],
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (_isLoading == true) {
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        endDrawer: WebBannerDrawer(),
        backgroundColor: Colors.white,
        body: SizedBox(
          height: screenHeight(context),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                WebBanner(
                  scaffoldKey: scaffoldKey,
                ),
                // SizedBox(
                //   height: deviceSize.height * 0.1,
                // ),
                if (screenWidth(context) >= 800)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: deviceSize.width * 0.2,
                        height: deviceSize.height * 0.7,
                        child: WebIntroScreen(),
                      ),
                      const SizedBox(width: 20),
                      _pageBody(),
                    ],
                  ),
                if (screenWidth(context) < 800)
                  Container(
                      width: screenWidth(context) * 0.90,
                      height: screenHeight(context) * 0.98,
                      child: _pageBodySmall()),
                //Spacer(),
                WebBottomBar(),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
//
