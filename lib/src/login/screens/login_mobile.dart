import 'dart:io';
//import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../adaptive/adaptive_theme.dart';
import '../../../util/app_theme.dart';
import '../../../util/app_theme_cupertino.dart';
import '../services/login_mobile_service.dart';
import '/helpers/url_launcher.dart';

import '../../../src/login/screens/email_registration.dart';

import '../../../util/ui_helpers.dart';
import '../../../widgets/rounded_button.dart';
import '../../../helpers/global_variables.dart';
import 'migrate_account.dart';

class LoginMobile extends StatefulWidget {
  static String routeName = '/otp-request';
  const LoginMobile({Key? key}) : super(key: key);

  @override
  _LoginMobileState createState() => _LoginMobileState();
}

class _LoginMobileState extends State<LoginMobile> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  // final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
  //     GlobalKey<ScaffoldMessengerState>();
  var _enableRequestOTP = true;
  var _enableValidateOTP = false;
  var _enableOldMobileNumber = false;
  var _enteredMobileNumber = '';
  var _selectedCountryCode = '+${GlobalVariables.defaultCountryCode}';

  Map<String, String> _requestOTPData = {
    'mobileNumber': '',
  };
  Map<String, String> _validateOTPData = {
    'mobileNumber': '',
    'otp': '',
  };
  Map<String, String> _oldMobileData = {
    'mobileNumber': '',
  };
  var _isLoading = false;
  var _resendOTPClicked = false;
  var _termsAgree = false;

  final _mobileNumberFocusNode = FocusNode();
  final _otpFocusNode = FocusNode();
  final _oldMobileNumberFocusNode = FocusNode();
  final _otpTextController = TextEditingController();
  bool _enableValidateOTPButton = false;
  @override
  void dispose() {
    _mobileNumberFocusNode.dispose();
    _otpFocusNode.dispose();
    _oldMobileNumberFocusNode.dispose();
    _otpTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _mobileNumberFocusNode.addListener(_onOnFocusNodeEvent);
    _otpFocusNode.addListener(_onOnFocusNodeEvent);
    _oldMobileNumberFocusNode.addListener(_onOnFocusNodeEvent);
    _otpTextController.addListener(() {
      if (_otpTextController.text.length == 6) {
        setState(() {
          _enableValidateOTPButton = true;
        });
      } else {
        setState(() {
          _enableValidateOTPButton = false;
        });
      }
    });
  }

  _onOnFocusNodeEvent() {
    setState(() {});
  }

  void setWidgetLoadingState(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void setRequestOTPCallbackState(
    bool isLoading,
    bool enableRequestOTP,
    bool enableValidateOTP,
    String enteredMobileNumber,
    bool enableOldMobileNumber,
  ) {
    setState(() {
      _isLoading = isLoading;
      _enableRequestOTP = enableRequestOTP;
      _enableValidateOTP = enableValidateOTP;
      _enteredMobileNumber = enteredMobileNumber;
      _enableOldMobileNumber = enableOldMobileNumber;
    });
  }

  Future<void> _requestOTP(BuildContext ctx) async {
    if (await LoginMobileService().requestOTP(
            context,
            _formKey,
            _requestOTPData,
            setWidgetLoadingState,
            setRequestOTPCallbackState) ==
        false) {
      return;
    }
  }

  void setResendOTPLoadingState(bool resendOTPClicked, bool isLoading) {
    setState(() {
      _resendOTPClicked = resendOTPClicked;
      _isLoading = isLoading;
    });
  }

  Future<void> _resendOTP(BuildContext ctx) async {
    if (await LoginMobileService().resendOTP(
            context, _formKey, _requestOTPData, setResendOTPLoadingState) ==
        false) {
      return;
    }
  }

  void setValidateOTPCallbackState(
    bool isLoading,
    bool enableRequestOTP,
    bool enableValidateOTP,
  ) {
    setState(() {
      _isLoading = isLoading;
      _enableRequestOTP = enableRequestOTP;
      _enableValidateOTP = enableValidateOTP;

      loadEmailRegistrationPage();
    });
  }

  void validateOTPPopScreen() {
    Navigator.of(context).pop();
  }

  Future<void> _validateOTP(BuildContext ctx) async {
    if (await LoginMobileService().validateOTP(
            context,
            _formKey,
            _enteredMobileNumber,
            _validateOTPData,
            setWidgetLoadingState,
            setValidateOTPCallbackState,
            validateOTPPopScreen,
            _otpTextController) ==
        false) {
      return;
    }
  }

//To be deletedCommented after moving the code to servies folder common for web and mobile

  // Future<void> _requestOTP(BuildContext ctx) async {
  //   if (!_formKey.currentState!.validate()) {
  //     // Invalid!
  //     return;
  //   }
  //   _formKey.currentState!.save();
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   try {
  //     var _success = await Provider.of<User>(context, listen: false)
  //         .requestOTP(_requestOTPData['mobileNumber']!);
  //     if (_success) {
  //       NotifyUser()
  //           .showSnackBar('An OTP has been sent to your mobile number', ctx);
  //       setState(() {
  //         _isLoading = false;
  //         _enableRequestOTP = false;
  //         _enableValidateOTP = true;
  //         _enteredMobileNumber = _requestOTPData['mobileNumber']!;
  //         _enableOldMobileNumber = false;
  //       });
  //     } else {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       await Dialogs()
  //           .ackAlert(context, 'OTP Error', 'Unable to process your request!');
  //     }
  //   } catch (error) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     await Dialogs().ackAlert(context, 'An error occured', error.toString());
  //   }
  // }

  // Future<void> _resendOTP(BuildContext ctx) async {
  //   setState(() {
  //     _resendOTPClicked = true;
  //     _isLoading = true;
  //   });
  //   try {
  //     var _success = await Provider.of<User>(context, listen: false)
  //         .requestOTP(_requestOTPData['mobileNumber']!);

  //     NotifyUser()
  //         .showSnackBar('An OTP has been sent to your mobile number', ctx);
  //     setState(() {
  //       _isLoading = false;
  //       _resendOTPClicked = false;
  //     });
  //     if (!_success) {
  //       await Dialogs()
  //           .ackAlert(context, 'OTP Error', 'Unable to process your request!');
  //     }
  //   } catch (error) {
  //     setState(() {
  //       _isLoading = false;
  //       _resendOTPClicked = false;
  //     });
  //     await Dialogs().ackAlert(context, 'An error occured', error.toString());
  //   }
  // }

  // Future<void> _validateOTP() async {
  //   if (!_formKey.currentState!.validate()) {
  //     // Invalid!
  //     return;
  //   }
  //   _formKey.currentState!.save();
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   final _otpResponse = Provider.of<User>(context, listen: false).otpResponse;
  //   bool _success = false;
  //   try {
  //     if (_otpResponse.providerType == '1') {
  //       _success = await Provider.of<User>(context, listen: false)
  //           .validateOTPLocal(_enteredMobileNumber, _validateOTPData['otp']!);
  //     } else {
  //       _success = await Provider.of<User>(context, listen: false)
  //           .validateOTPIntl(_enteredMobileNumber, _validateOTPData['otp']!);
  //     }

  //     if (_success) {
  //       //CALL login/android/licence to check the status, if not a new user then load login_with_pass screen.
  //       //else ask the below confirmation message
  //       bool _mobileValidated = await Provider.of<Auth>(context, listen: false)
  //           .validateMobileNumber(_enteredMobileNumber, true);
  //       _otpTextController.text = '';
  //       if (_mobileValidated) {
  //         Navigator.of(context).pop();
  //         // Navigator.of(context).pushReplacementNamed(
  //         //     LoginWithPassword.routeName,
  //         //     arguments: LoginWithPasswordArgs(
  //         //         _mobileValidated, _enteredMobileNumber));
  //       } else {
  //         setState(() {
  //           _isLoading = false;
  //           _enableRequestOTP = false;
  //           _enableValidateOTP = false;
  //           //_enableOldMobileNumber = true;
  //           loadEmailRegistrationPage();
  //         });
  //         // final DialogConfirmAction? action = await Dialogs()
  //         //     .asyncConfirmDialog(context, 'Alert',
  //         //         'Does user have an account with different number?');
  //         // if (action == DialogConfirmAction.CANCEL) {
  //         //   loadEmailRegistrationPage();
  //         //   // Navigator.of(context)
  //         //   //     .pushReplacementNamed(EmailRegistration.routeName);
  //         // } else {
  //         //   setState(() {
  //         //     _enableRequestOTP = false;
  //         //     _enableValidateOTP = false;
  //         //     _enableOldMobileNumber = true;
  //         //   });
  //         // }
  //       }
  //     }
  //   } catch (error) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     await Dialogs().ackAlert(context, 'An error occured', error.toString());
  //   }
  // }

//To be deletedCommented after moving the code to servies folder common for web and mobile

  void loadEmailRegistrationPage() {
    Navigator.of(context).pushNamed(EmailRegistration.routeName,
        arguments: _enteredMobileNumber);
  }

//Commented and to be removed
  // Future<void> _changePhoneNumber(BuildContext ctx) async {
  //   if (!_formKey.currentState!.validate()) {
  //     // Invalid!
  //     return;
  //   }
  //   _formKey.currentState!.save();
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   try {
  //     var _success = await Provider.of<User>(context, listen: false)
  //         .changePhoneNumber(
  //             _oldMobileData['mobileNumber']!, _enteredMobileNumber);
  //     if (_success) {
  //       //CALL login/android/licence to check the status, if not a new user then load login_with_pass screen.
  //       //else ask the below confirmation message
  //       bool _mobileValidated = await Provider.of<Auth>(context, listen: false)
  //           .validateMobileNumber(_enteredMobileNumber, true);
  //       if (_mobileValidated) {
  //         NotifyUser().showSnackBar(
  //             'Your data has been updated with the new mobile number!', ctx);
  //         Navigator.of(context).pushReplacementNamed(
  //             LoginWithPassword.routeName,
  //             arguments: LoginWithPasswordArgs(
  //                 _mobileValidated, _enteredMobileNumber, () {}, () {}, false));
  //       } else {
  //         setState(() {
  //           _isLoading = false;
  //           loadEmailRegistrationPage();
  //           // Navigator.of(context)
  //           //     .pushReplacementNamed(EmailRegistration.routeName);
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       await Dialogs()
  //           .ackAlert(context, 'Error', 'Unable to process your request!');
  //       //TODO::: Need to know what to do next here
  //     }
  //   } catch (error) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     await Dialogs().ackAlert(context, 'An error occured', error.toString());
  //   }
  // }

  void _onCountryChange(CountryCode countryCode) {
    _selectedCountryCode = countryCode.toString();
  }
  Future<bool> _onBackPressed() async {
    if (_enableRequestOTP)
      return true;
    else if (_enableValidateOTP) {
      setState(() {
        _enableValidateOTP = false;
        _enableRequestOTP = true;
        _enableOldMobileNumber = false;
      });
      return false;
    } else if (_enableOldMobileNumber) {
      setState(() {
        _enableOldMobileNumber = false;
        _enableValidateOTP = false;
        _enableRequestOTP = true;
      });
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _pageBody() {
      return Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/splashscreen.gif'),
                  Image.asset(
                    'assets/images/sw_appbar_logo.png',
                    width: 200,
                    height: 80,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Visibility(
                    visible: _enableRequestOTP,
                    child: _mobileNoCapturingSection(context),
                  ),
                  Visibility(
                    visible: _enableValidateOTP,
                    child: _otpValidationSection(context),
                  ),
                  Visibility(
                    visible: _enableOldMobileNumber,
                    child: _oldMobileNoCapturingSection(context),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Platform.isIOS
          ? CupertinoPageScaffold(
              child: Center(
                child: SingleChildScrollView(
                  child: _pageBody(),
                ),
              ),
            )
          : Scaffold(
              body: Center(
                child: SingleChildScrollView(
                  child: _pageBody(),
                ),
              ),
            ),
    );
  }

  Column _oldMobileNoCapturingSection(BuildContext context) {
    TextStyle _textViewStyle = Platform.isIOS
        ? AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
            .copyWith(fontSize: 16, fontWeight: FontWeight.w400)
        : AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontSize: 16, fontWeight: FontWeight.w400);

    return Column(
      children: [
        //MOBILE NUMBER
        TextFormField(
          style: _textViewStyle,
          focusNode: _oldMobileNumberFocusNode,
          decoration: AdaptiveTheme.textFormFieldDecoration(
              context, 'Mobile Number', _oldMobileNumberFocusNode),
          inputFormatters: [
            LengthLimitingTextInputFormatter(10),
            FilteringTextInputFormatter.digitsOnly,
          ],
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please provide a valid mobile number';
            }
            if (value.length < 10) {
              return 'Not a valid mobile number';
            }
            return null;
          },
          onSaved: (value) {
            _oldMobileData['mobileNumber'] = value!;
          },
        ),
        //MOBILE NUMBER
        verticalSpaceMedium,
        if (_isLoading)
          AdaptiveCircularProgressIndicator()
        else
          SizedBox(
            width: double.infinity,
            child: RoundButton(
              title: 'Submit',
              color: AdaptiveTheme.primaryColor(context),
              onPressed: () {
                // _changePhoneNumber(context);
              },
            ),
          ),
      ],
    );
  }

  Column _otpValidationSection(BuildContext context) {
    TextStyle _textViewStyle = Platform.isIOS
        ? AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
            .copyWith(fontSize: 16, fontWeight: FontWeight.w400)
        : AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontSize: 16, fontWeight: FontWeight.w400);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        //MOBILE NUMBER
        TextFormField(
          style: _textViewStyle,
          readOnly: true,
          initialValue: '$_selectedCountryCode $_enteredMobileNumber',
          decoration: InputDecoration(
            labelText: 'Mobile Number',
            labelStyle: TextStyle(color: AdaptiveTheme.primaryColor(context)),
            focusedBorder: AdaptiveTheme.outlineInputBorder(context),
            border: AdaptiveTheme.outlineInputBorder(context),
            suffixIcon: InkWell(
              child: Icon(
                Icons.edit,
                color: _isLoading
                    ? Colors.grey
                    : AdaptiveTheme.primaryColor(context),
              ),
              onTap: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _enableRequestOTP = true;
                        _enableValidateOTP = false;

                        _enableOldMobileNumber = false;
                      });
                    },
            ),
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(10),
            FilteringTextInputFormatter.digitsOnly,
          ],
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please provide a valid mobile number';
            }
            if (value.length < 10) {
              return 'Not a valid mobile number';
            }
            return null;
          },
          onSaved: (value) {
            _validateOTPData['mobileNumber'] = value!;
          },
        ),
        //MOBILE NUMBER
        verticalSpaceMedium,
        //OTP
        TextFormField(
          controller: _otpTextController,
          style: _textViewStyle,
          focusNode: _otpFocusNode,
          decoration: AdaptiveTheme.textFormFieldDecoration(
              context, 'OTP', _otpFocusNode),
          inputFormatters: [
            LengthLimitingTextInputFormatter(6),
            FilteringTextInputFormatter.digitsOnly,
          ],
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please provide the OTP received';
            }
            if (value.length < 6) {
              return 'Not a valid OTP';
            }
            return null;
          },
          onSaved: (value) {
            _validateOTPData['otp'] = value!;
          },
        ),
        //OTP

        if (_isLoading && _resendOTPClicked)
          AdaptiveCircularProgressIndicator()
        else
          TextButton(
            child: const Text('Resend OTP'),
            style: TextButton.styleFrom(
                foregroundColor: AdaptiveTheme.primaryColor(context)),
            onPressed: _isLoading
                ? null
                : () {
                    // setState(() {
                    _otpTextController.text = '';
                    // });
                    FocusScope.of(context).requestFocus(new FocusNode());

                    _resendOTP(context);
                  },
          ),
        verticalSpaceMedium,
        if (_isLoading && !_resendOTPClicked)
          Center(child: AdaptiveCircularProgressIndicator())
        else
          SizedBox(
            width: double.infinity,
            height: 50,
            child: appButton(
              context: context,
              width: 0,
              height: 0,
              title: 'Validate OTP',
              titleColour: _enableValidateOTPButton ==
                      false // _otpTextController.text == ''
                  ? Colors.grey
                  : AdaptiveTheme.primaryColor(context),
              onPressed: _isLoading && _resendOTPClicked
                  ? () {}
                  : _otpTextController.text == ''
                      ? () {}
                      : () {
                          _validateOTP(context);
                        },
              borderColor: _otpTextController.text == ''
                  ? Colors.grey
                  : AdaptiveTheme.primaryColor(context),
            ),
            // child: RoundButton(
            //   title: 'Validate OTP',
            //   color: AdaptiveTheme.primaryColor(context),
            //   onPressed: _isLoading && _resendOTPClicked ? null : _validateOTP,
            // ),
          ),
        // if (_isLoading && _resendOTPClicked)
        //   AdaptiveCircularProgressIndicator()
        // else
        //   TextButton(
        //     child: Text('Resend OTP'),
        //     style: TextButton.styleFrom(
        //         primary: AdaptiveTheme.primaryColor(context)),
        //     onPressed: _isLoading
        //         ? null
        //         : () {
        //             _resendOTP(context);
        //           },
        //   ),
        const SizedBox(height: 10),
      ],
    );
  }

  Column _mobileNoCapturingSection(BuildContext context) {
    TextStyle _textViewStyle = Platform.isIOS
        ? AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
            .copyWith(fontSize: 16, fontWeight: FontWeight.w400)
        : AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontSize: 16, fontWeight: FontWeight.w400);

    return Column(
      //mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 58,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border:
                      Border.all(color: AdaptiveTheme.primaryColor(context))),
              child: CountryCodePicker(
                enabled:
                    false, //TODO:: This should be enabled when the intl. sms provider api is up.
                initialSelection: GlobalVariables.defaultCountryISO,
                textStyle: TextStyle(color: Colors.black),
                onChanged: _onCountryChange,
              ),
            ),
            const SizedBox(width: 10),
            //MOBILE NUMBER
            Expanded(
              child: TextFormField(
                focusNode: _mobileNumberFocusNode,
                style: _textViewStyle,
                initialValue: _enteredMobileNumber,
                autovalidateMode: _enableRequestOTP
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                decoration: AdaptiveTheme.textFormFieldDecoration(
                  context,
                  'Mobile Number',
                  _mobileNumberFocusNode,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please provide a valid mobile number';
                  }
                  if (value.length < 10) {
                    return 'Not a valid mobile number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _requestOTPData['mobileNumber'] = value!;
                },
              ),
            ),
            //MOBILE NUMBER
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: 10,
                  height: 10,
                  child: Checkbox(
                    value: _termsAgree,
                    fillColor: MaterialStateProperty.all(
                        AdaptiveTheme.primaryColor(context)),
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _termsAgree = value ?? false;
                            });
                          },
                  ),
                ),
              ),
              const SizedBox(width: 15),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: RichText(
                  //softWrap: true,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            'By clicking on the checkbox, you are agreeing to the ',
                        style: const TextStyle(
                            fontSize: 14,
                            letterSpacing: 0.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: 'terms and conditions',
                        style: const TextStyle(
                            fontSize: 14,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            UrlLauncher.launchURL(
                                GlobalVariables.termOfServiceUrl);
                          },
                      ),
                      TextSpan(
                        text: ' and',
                        style: const TextStyle(
                            fontSize: 14,
                            letterSpacing: 0.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: ' privacy policy',
                        style: const TextStyle(
                            fontSize: 14,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            UrlLauncher.launchURL(
                                GlobalVariables.usersPrivacyPolicyUrl);
                          },
                      ),
                    ],
                  ),
                ),
              ),
              // InkWell(
              //   onTap: _isLoading
              //       ? null
              //       : () =>
              //           UrlLauncher.launchURL(GlobalVariables.termOfServiceUrl),
              //   child: SizedBox(
              //     width: MediaQuery.of(context).size.width * 0.7,
              //     child: AutoSizeText(
              //       'By clicking on the checkbox, you are agreeing to the terms and conditions',
              //       textAlign: TextAlign.left,
              //       style: const TextStyle(
              //           fontSize: 13,
              //           letterSpacing: 0.0,
              //           fontWeight: FontWeight.w400),
              //       maxFontSize: textScale(context) <= 1.0 ? 13 : 11,
              //       maxLines: 2,
              //       minFontSize: 11,
              //       stepGranularity: 1,
              //     ),
              //   ),
              // )
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_isLoading)
          Center(child: AdaptiveCircularProgressIndicator())
        else
          SizedBox(
            width: screenWidth(context) * 0.92,
            height: 50,
            child: appButton(
              context: context,
              width: 0,
              height: 0,
              title: 'Request OTP',
              titleColour: !_termsAgree
                  ? Colors.grey
                  : AdaptiveTheme.primaryColor(context),
              onPressed: !_termsAgree
                  ? () {}
                  : () {
                      _otpTextController.text = '';
                      FocusScope.of(context).requestFocus(new FocusNode());

                      _requestOTP(context);
                    },
              borderColor: !_termsAgree
                  ? Colors.grey
                  : AdaptiveTheme.primaryColor(context),
            ),
            // child: RoundButton(
            //     title: 'Request OTP',
            //     color: AdaptiveTheme.primaryColor(context),
            //     onPressed: !_termsAgree
            //         ? null
            //         : () {
            //             _requestOTP(context);
            //           }),
          ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(context)
                            .pushNamed(MigrateAccount.routeName);
                      },
                child: Text('Migrate Account',
                    style: TextStyle(color: AppTheme.secondaryColor))),
          ],
        )
      ],
    );
  }
}
