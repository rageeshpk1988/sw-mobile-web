import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:sign_button/sign_button.dart';

import '../../../helpers/global_variables.dart';
import '../../../src/home/landing/screens/landing_page.dart';
import '../../../src/models/socialaccesstoken_request.dart';
import '../../../util/app_theme.dart';
import '../../../util/app_theme_cupertino.dart';
import '../../../util/password_generator.dart';

import '../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../adaptive/adaptive_theme.dart';
import '/src/providers/google_signin_controller.dart';

import '../../../src/providers/user.dart';
import '../../../util/notify_user.dart';
import '../../../helpers/global_validations.dart';
import '../../../util/ui_helpers.dart';

import '../../../src/providers/auth.dart';
import '../../../util/dialogs.dart';
import '../../../util/password_form_field.dart';
import 'login_mobile.dart';

class EmailRegistration extends StatefulWidget {
  static String routeName = '/email-registration';

  @override
  _EmailRegistrationState createState() => _EmailRegistrationState();
}

class _EmailRegistrationState extends State<EmailRegistration> {
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
  final _referralController = TextEditingController();
  final _referralFocusNodePopup = FocusNode();
  final _referralFocusNode = FocusNode();
  var _enteredMobileNumber = '';
  var _enteredReferralCode = '';
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
          .registerParent(_enteredMobileNumber, _registration['name']!,
              _registration['emailId']!, _registration['password']!,_enteredReferralCode).onError((error, stackTrace) async {
        await Dialogs()
            .ackAlert(context, 'Alert', error.toString());
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


  Future _referralDialog(Function updateHandler,String _appName) {
    TextStyle _textViewStyle = Platform.isIOS
        ? AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
        .copyWith(fontSize: 16, fontWeight: FontWeight.w400)
        : AppTheme.lightTheme.textTheme.bodySmall!
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
                style: Platform.isIOS
                    ? AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
                    .copyWith(fontSize: 14, fontWeight: FontWeight.w700)
                    : AppTheme.lightTheme.textTheme.bodyMedium!
                    .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              Text(
                "Do you have referral code?",
                style: Platform.isIOS
                    ? AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
                    .copyWith(fontSize: 14, fontWeight: FontWeight.w700)
                    : AppTheme.lightTheme.textTheme.bodyMedium!
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
                   FilteringTextInputFormatter(RegExp("[a-zA-Z0-9]"), allow: true),
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
                      _submitSocial(updateHandler, _appName, _enteredReferralCode);
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
                      _submitSocial(updateHandler, _appName, _enteredReferralCode);
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
  Future<void> _submitSocial(Function updateHandler, String _appName,String referralCode) async {
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

          var _inserted =
              await Provider.of<User>(context, listen: false).registerParent(
            _enteredMobileNumber,
            _socialAccessToken.name!,
            _socialAccessToken.email!,
            _registration['password']!,
                referralCode
          ).onError((error, stackTrace) async {
            await Provider.of<GoogleSignInProvider>(context,listen: false).googleSignOut();
                await Dialogs()
                    .ackAlert(context, 'Alert', error.toString());
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
    }else if(_appName == "apple") {
      final provider =
      Provider.of<GoogleSignInProvider>(context, listen: false);
      SocialAdRequest _socialAccessToken =
      await provider.appleLogin(context);
      setState(() {
        _isLoading = true;
      });
      //  final password = RandomPasswordGenerator();
      _registration['password'] = generatePassword(true, true, true, true, 17);
      if (_socialAccessToken.email == null || _socialAccessToken.name == null) {
        provider.appleSignOut();
        setState(() {
          _isLoading = false;
        });
        await Dialogs().ackAlert(context, 'Error',
            'Something Went Wrong... To login email id is mandatory, Please give the required permissions and try again');
      } else {
        try {
          // var authToken =
          //     Provider.of<Auth>(context, listen: false).loginResponse.token;

          var _inserted =
          await Provider.of<User>(context, listen: false).registerParent(
              _enteredMobileNumber,
              _socialAccessToken.name!,
              _socialAccessToken.email!,
              _registration['password']!,
              referralCode
          ).onError((error, stackTrace) async {
            provider.appleSignOut();
            await Dialogs()
                .ackAlert(context, 'Alert', error.toString());
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
    }else {
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

          var _inserted =
              await Provider.of<User>(context, listen: false).registerParent(
            _enteredMobileNumber,
            _socialAccessToken.name!,
            _socialAccessToken.email!,
            _registration['password']!,
                  referralCode
          ).onError((error, stackTrace) async {
               await Dialogs()
                    .ackAlert(context, 'Alert', error.toString());
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

  Future<bool> _onBackPressed() async {
    //Navigator.popUntil(context, ModalRoute.withName(LoginMobile.routeName));
    Navigator.pushReplacementNamed(context, (LoginMobile.routeName));
    return false;
  }


  @override
  Widget build(BuildContext context) {
    TextStyle _textViewStyle = Platform.isIOS
        ? AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
            .copyWith(fontSize: 16, fontWeight: FontWeight.w400)
        : AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontSize: 16, fontWeight: FontWeight.w400);

    _enteredMobileNumber = ModalRoute.of(context)!.settings.arguments as String;
    return WillPopScope(
      onWillPop: () async {
        if (_isLoading == true) {
          return false;
        } else {
          _onBackPressed();
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/Mascot.png'),
                    Image.asset('assets/images/sw_appbar_logo.png',
                        width: 200, height: 60),
                    //verticalSpaceMedium,
                    //NAME
                    TextFormField(
                      enabled: _isLoading ? false : true,
                      style: _textViewStyle,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                        FilteringTextInputFormatter.deny(
                            RegExp(GlobalVariables.regExpEmoji)),
                        FilteringTextInputFormatter.allow(
                            RegExp(GlobalVariables.regExpAlphbets))
                      ],
                      decoration: AdaptiveTheme.textFormFieldDecoration(
                          context, 'Parent Name', _nameFocusNode),
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
                    verticalSpaceSmall,
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
                    verticalSpaceSmall,
                    //PASSWORD
                    PasswordFormField(
                      isLoading: _isLoading,
                      controller: _passwordController,
                      login: false,
                      label: 'Password',
                    ),
                    //PASSWORD
                    verticalSpaceSmall,
                    //CONFIRM PASSWORD
                    TextFormField(
                      enabled: _isLoading ? false : true,
                      style: _textViewStyle,
                      focusNode: _confirmPasswordFocusNode,
                      decoration: AdaptiveTheme.textFormFieldDecoration(context,
                          'Confirm Password', _confirmPasswordFocusNode),
                      textInputAction: TextInputAction.next,
                      obscureText: true,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_referralFocusNode);
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
                    //REFERRAL CODE
                    TextFormField(
                      enabled: _isLoading ? false : true,
                      style: _textViewStyle,
                      focusNode: _referralFocusNode,
                      decoration: AdaptiveTheme.textFormFieldDecoration(context,
                          'Referral Code (Optional)', _referralFocusNode),
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter(RegExp("[a-zA-Z0-9]"), allow: true),
                      ],
                      onFieldSubmitted: (_) {
                        //  _saveForm();
                      },
                      onSaved: (value){
                        if (value != null){

                            _enteredReferralCode = value;

                        }

                      },
                    ),
                    //REFERRAL CODE
                    verticalSpaceMedium,

                    if (_isLoading)
                      AdaptiveCircularProgressIndicator()
                    else
                      Column(
                        children: [SizedBox(
                          width: double.infinity,
                          height: 50,
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

                          verticalSpaceSmall,
                          NotifyUser().showPasswordPolicyText(),
                          verticalSpaceMedium,
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
                                  // calls google sign in
                                  _referralDialog(updateSocialADData, "google");
                                }),
                          ),
                          verticalSpaceSmall,
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
                                  _referralDialog(updateSocialADData, "facebook");
                                }),
                          ),
                          verticalSpaceSmall,
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
                                    _referralDialog(updateSocialADData, "apple");
                                  }),
                            ),
                          verticalSpaceMedium,
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        )),
      ),
    );
  }
}
//