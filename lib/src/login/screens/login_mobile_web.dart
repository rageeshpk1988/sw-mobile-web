import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/src/login/screens/migrate_account_web.dart';
import '/widgets/web_banner.dart';
import '/widgets/web_bottom_bar.dart';
import 'email_registration_web.dart';
import '../../../src/login/services/login_mobile_service.dart';
import '../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../adaptive/adaptive_theme.dart';
import '../../../util/app_theme.dart';

import '../../intro/web_intro_screen.dart';
import '/helpers/url_launcher.dart';

import '../../../util/ui_helpers.dart';
import '../../../widgets/rounded_button.dart';
import '../../../helpers/global_variables.dart';

class LoginMobileWeb extends StatefulWidget {
  static String routeName = '/web-otp-request';
  const LoginMobileWeb({Key? key}) : super(key: key);

  @override
  _LoginMobileWebState createState() => _LoginMobileWebState();
}

class _LoginMobileWebState extends State<LoginMobileWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey();
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
  late double logincardWidth;
  late double logincardHeight;
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

  void loadEmailRegistrationPage() {
    Navigator.of(context).pushNamed(EmailRegistrationWeb.routeName,
        arguments: _enteredMobileNumber);
  }

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
    var deviceSize = MediaQuery.of(context).size;
    logincardWidth = deviceSize.width *
        (screenWidth(context) > 800
            ? 0.30
            : (screenWidth(context) > 400 ? 0.60 : 0.98));
    logincardHeight =
        deviceSize.height * (screenWidth(context) > 800 ? 0.50 : 0.60);

    Widget _pageBody() {
      return Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Padding(
            padding: screenWidth(context) > 400
                ? EdgeInsets.all(18.0)
                : EdgeInsets.all(3.0),
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: SizedBox(
                width: logincardWidth,
                height: logincardHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
        ),
      );
    }

    Widget _responsiveBody() {
      List<Widget> _items = [
        WebIntroScreen(),
        _pageBody(),
      ];
      if (screenWidth(context) > 800) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: deviceSize.width * 0.2,
              height: deviceSize.height * 0.7,
              child: _items[0],
            ),
            _items[1],
          ],
        );
      } else {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (screenWidth(context) < 800)
              Image.asset(
                'assets/images/sw_appbar_logo.png',
                width: 200,
                height: 80,
              ),
            _items[1],
          ],
        );
      }
    }

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: scaffoldKey,
        // endDrawer: WebBannerDrawer(),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: screenWidth(context) > 800
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (screenWidth(context) > 800)
              WebBanner(
                scaffoldKey: scaffoldKey,
              ),

            if (screenWidth(context) > 800)
              SizedBox(height: deviceSize.height * 0.1),
            if (screenWidth(context) > 800)
              Container(
                width: screenWidth(context) * 0.90,
                child: _responsiveBody(),
              ),
            if (screenWidth(context) <= 800)
              Container(
                width: screenWidth(context) * 0.90,
                height: screenHeight(context) * 0.90,
                child: _responsiveBody(),
              ),
            //Spacer(),
            WebBottomBar(),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Column _oldMobileNoCapturingSection(BuildContext context) {
    TextStyle _textViewStyle = AppTheme.lightTheme.textTheme.bodySmall!
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
    TextStyle _textViewStyle = AppTheme.lightTheme.textTheme.bodySmall!
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
            width: screenWidth(context) *
                (screenWidth(context) > 800 ? 0.10 : 0.30),
            height: 34,

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
    TextStyle _textViewStyle = AppTheme.lightTheme.textTheme.bodySmall!
        .copyWith(fontSize: 16, fontWeight: FontWeight.w400);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
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
                width: logincardWidth * 0.80,
                child: RichText(
                  textAlign: TextAlign.justify,
                  softWrap: true,
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
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_isLoading)
          Center(child: AdaptiveCircularProgressIndicator())
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: screenWidth(context) *
                    (screenWidth(context) > 800 ? 0.10 : 0.30),
                height: 34,
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
              ),
            ],
          ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(context)
                            .pushNamed(MigrateAccountWeb.routeName);
                        //loadEmailRegistrationPage();
                      },
                child: Text('Migrate Account',
                    style: TextStyle(color: AppTheme.secondaryColor))),
          ],
        )
      ],
    );
  }
}
