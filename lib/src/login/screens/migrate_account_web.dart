import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import '../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../adaptive/adaptive_theme.dart';
import '../../../util/app_theme.dart';

import '../../../util/password_form_field.dart';

import '../../../widgets/web_banner.dart';
import '../../../widgets/web_bottom_bar.dart';
import '../../home/landing/screens/landing_page.dart';
import '../../intro/web_intro_screen.dart';
import '/util/notify_user.dart';

import '../../../src/providers/auth.dart';

import '../../../src/providers/user.dart';
import '../../../util/dialogs.dart';
import '../../../util/ui_helpers.dart';

import '../../../helpers/global_variables.dart';

class MigrateAccountWeb extends StatefulWidget {
  static String routeName = '/web-migrate-account-number';
  const MigrateAccountWeb({Key? key}) : super(key: key);

  @override
  _MigrateAccountWebState createState() => _MigrateAccountWebState();
}

class _MigrateAccountWebState extends State<MigrateAccountWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey();

  var _enableRequestOTP = true;
  var _enableValidateOTP = false;
  var _enablePasswordValidation = false;
  var _enteredMobileNumber = '';
  var _selectedCountryCode = '+${GlobalVariables.defaultCountryCode}';

  Map<String, String> _requestOTPData = {
    'oldMobileNumber': '',
    'newMobileNumber': '',
  };
  Map<String, String> _validateOTPData = {
    'newMobileNumber': '',
    'otp': '',
  };
  // Map<String, String> _oldMobileData = {
  //   'mobileNumber': '',
  // };
  var _isLoading = false;
  var _resendOTPClicked = false;
  late double logincardWidth;
  late double logincardHeight;
  final _mobileNumberFocusNode = FocusNode();
  final _otpFocusNode = FocusNode();
  final _oldMobileNumberFocusNode = FocusNode();
  final _otpTextController = TextEditingController();
  final _passwordController = TextEditingController();
  final _oldMobileNumberController = TextEditingController();

  @override
  void dispose() {
    _mobileNumberFocusNode.dispose();
    _otpFocusNode.dispose();
    _oldMobileNumberFocusNode.dispose();
    _otpTextController.dispose();
    _passwordController.dispose();
    _oldMobileNumberController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _mobileNumberFocusNode.addListener(_onOnFocusNodeEvent);
    _otpFocusNode.addListener(_onOnFocusNodeEvent);
    _oldMobileNumberFocusNode.addListener(_onOnFocusNodeEvent);
  }

  _onOnFocusNodeEvent() {
    setState(() {});
  }

  Future<void> _requestOTP(BuildContext ctx) async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      var _success = await Provider.of<User>(context, listen: false)
          .requestOTP(_requestOTPData['newMobileNumber']!);
      if (_success) {
        NotifyUser()
            .showSnackBar('An OTP has been sent to your mobile number', ctx);
        setState(() {
          _isLoading = false;
          _enableRequestOTP = false;
          _enableValidateOTP = true;
          _enteredMobileNumber = _requestOTPData['newMobileNumber']!;
          _enablePasswordValidation = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        await Dialogs()
            .ackAlert(context, 'OTP Error', 'Unable to process your request!');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      await Dialogs().ackAlert(context, 'An error occured', error.toString());
    }
  }

  Future<void> _resendOTP(BuildContext ctx) async {
    setState(() {
      _resendOTPClicked = true;
      _isLoading = true;
    });
    try {
      var _success = await Provider.of<User>(context, listen: false)
          .requestOTP(_requestOTPData['newMobileNumber']!);

      NotifyUser()
          .showSnackBar('An OTP has been sent to your mobile number', ctx);
      setState(() {
        _isLoading = false;
        _resendOTPClicked = false;
      });
      if (!_success) {
        await Dialogs()
            .ackAlert(context, 'OTP Error', 'Unable to process your request!');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _resendOTPClicked = false;
      });
      await Dialogs().ackAlert(context, 'An error occured', error.toString());
    }
  }

  Future<void> _validateOTP() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    final _otpResponse = Provider.of<User>(context, listen: false).otpResponse;
    bool _success = false;
    try {
      if (_otpResponse.providerType == '1') {
        _success = await Provider.of<User>(context, listen: false)
            .validateOTPLocal(_enteredMobileNumber, _validateOTPData['otp']!);
      } else {
        _success = await Provider.of<User>(context, listen: false)
            .validateOTPIntl(_enteredMobileNumber, _validateOTPData['otp']!);
      }

      if (_success) {
        //CALL login/android/licence to check the status, if not a new user then load login_with_pass screen.
        //else ask the below confirmation message
        bool _mobileValidated = await Provider.of<Auth>(context, listen: false)
            .validateMobileNumber(_enteredMobileNumber, true);
        if (_mobileValidated) {
          Navigator.of(context).pop();
        } else {
          setState(() {
            _isLoading = false;
            _enableRequestOTP = false;
            _enableValidateOTP = false;
            _enablePasswordValidation = true;
          });
        }
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      await Dialogs().ackAlert(context, 'An error occured', error.toString());
    }
  }

  Future<void> _migrateAccount(BuildContext ctx) async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      var _success = await Provider.of<User>(context, listen: false)
          .changePhoneNumber(_requestOTPData['oldMobileNumber']!,
              _enteredMobileNumber, _passwordController.text);
      if (_success) {
        //CALL login/android/licence to check the status, if not a new user then load login_with_pass screen.
        //else ask the below confirmation message
        bool _mobileValidated = await Provider.of<Auth>(context, listen: false)
            .validateMobileNumber(_enteredMobileNumber, true);
        if (_mobileValidated) {
          setState(() {
            _isLoading = false;
          });
          await Dialogs().ackSuccessAlert(context, 'SUCCESS!!!',
              'Your data has been updated with the new mobile number!');

          // NotifyUser().showSnackBar(
          //     'Your data has been updated with the new mobile number!', ctx);
          // Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LandingPage()),
          );
          //  Navigator.of(context).pushReplacementNamed(LandingPage.routeName);
        } else {
          setState(() {
            _isLoading = false;
            //loadEmailRegistrationPage();
            // Navigator.of(context)
            //     .pushReplacementNamed(EmailRegistration.routeName);
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        await Dialogs()
            .ackAlert(context, 'Error', 'Unable to process your request!');
        //TODO::: Need to know what to do next here
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      await Dialogs().ackAlert(context, 'An error occured', error.toString());
    }
  }

  Future<bool> _onBackPressed() async {
    if (_enableRequestOTP)
      return true;
    else if (_enableValidateOTP) {
      setState(() {
        _enableValidateOTP = false;
        _enableRequestOTP = true;
        _enablePasswordValidation = false;
      });
      return false;
    } else if (_enablePasswordValidation) {
      setState(() {
        _enablePasswordValidation = false;
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
        deviceSize.height * (screenWidth(context) > 800 ? 0.40 : 0.70);

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
                    Text(
                      'Migrate Account',
                      style: AppTheme.lightTheme.textTheme.bodyLarge!
                          .copyWith(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'The migrate account feature allows you to change the phone number associated with your SchoolWizard account to a new one in case of a change of number, loss or damage of your SIM card, etc. Migrating your account will transfer all your settings and details to your new phone number.',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Image.asset(
                      'assets/images/changenumber.png',
                      width: 100,
                      height: 60,
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
                      visible: _enablePasswordValidation,
                      child: _passwordCapturingSection(context),
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

    // return WillPopScope(
    //   onWillPop: _onBackPressed,
    //   child: Scaffold(
    //     body: SingleChildScrollView(
    //       child: SizedBox(
    //         height: screenHeight(context),
    //         child: Column(
    //           children: [
    //             WebBanner(),
    //             SizedBox(
    //               height: deviceSize.height * 0.1,
    //             ),
    //             Row(
    //               mainAxisSize: MainAxisSize.min,
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 SizedBox(
    //                   width: deviceSize.width * 0.2,
    //                   height: deviceSize.height * 0.7,
    //                   child: WebIntroScreen(),
    //                 ),
    //                 _pageBody(),
    //               ],
    //             ),
    //             Spacer(),
    //             WebBottomBar(),
    //             SizedBox(height: 10),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  Column _passwordCapturingSection(BuildContext context) {
    TextStyle _textViewStyle = AppTheme.lightTheme.textTheme.bodySmall!
        .copyWith(fontSize: 16, fontWeight: FontWeight.w400);

    return Column(
      children: [
        //MOBILE NUMBER
        TextFormField(
          style: _textViewStyle.copyWith(color: Colors.grey),
          readOnly: true,
          initialValue: '$_selectedCountryCode $_enteredMobileNumber',
          decoration: InputDecoration(
            labelText: 'New Mobile Number',
            labelStyle: TextStyle(color: AdaptiveTheme.primaryColor(context)),
            focusedBorder: AdaptiveTheme.outlineInputBorder(context),
            border: AdaptiveTheme.outlineInputBorder(context),
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(10),
            FilteringTextInputFormatter.digitsOnly,
          ],
          keyboardType: TextInputType.phone,
        ),
        //MOBILE NUMBER
        const SizedBox(height: 10),

        //PASSWORD
        PasswordFormField(
          isLoading: _isLoading,
          controller: _passwordController,
          login: false,
          label: 'Password',
        ),
        //PASSWORD
        //NEEDHELP
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () {},
                child: Text('Need Help?',
                    style: TextStyle(color: AppTheme.secondaryColor))),
          ],
        )

        //NEEDHELP
        ,
        verticalSpaceMedium,
        if (_isLoading)
          AdaptiveCircularProgressIndicator()
        else
          SizedBox(
            width: screenWidth(context) * 0.92,
            height: 50,
            child: appButton(
              context: context,
              width: 0,
              height: 0,
              title: 'Migrate Account',
              titleColour: AdaptiveTheme.primaryColor(context),
              onPressed: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                _migrateAccount(context);
              },
              borderColor: AdaptiveTheme.primaryColor(context),
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
          style: _textViewStyle.copyWith(color: Colors.grey),
          readOnly: true,
          initialValue: '$_selectedCountryCode $_enteredMobileNumber',
          decoration: InputDecoration(
            labelText: 'New Mobile Number',
            labelStyle: TextStyle(color: AdaptiveTheme.primaryColor(context)),
            focusedBorder: AdaptiveTheme.outlineInputBorder(context),
            border: AdaptiveTheme.outlineInputBorder(context),
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(10),
            FilteringTextInputFormatter.digitsOnly,
          ],
          keyboardType: TextInputType.phone,
          // validator: (value) {
          //   if (value!.isEmpty) {
          //     return 'Please provide a valid mobile number';
          //   }
          //   if (value.length < 10) {
          //     return 'Not a valid mobile number';
          //   }
          //   return null;
          // },
          // onSaved: (value) {
          //   _validateOTPData['newMobileNumber'] = value!;
          // },
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: screenWidth(context) * 0.10,
                height: 34,
                child: appButton(
                  context: context,
                  width: 0,
                  height: 0,
                  title: 'Submit',
                  titleColour: AdaptiveTheme.primaryColor(context),
                  onPressed:
                      _isLoading && _resendOTPClicked ? () {} : _validateOTP,
                  borderColor: AdaptiveTheme.primaryColor(context),
                ),
              ),
            ],
          ),

        const SizedBox(height: 10),
      ],
    );
  }

  Column _mobileNoCapturingSection(BuildContext context) {
    TextStyle _textViewStyle = AppTheme.lightTheme.textTheme.bodySmall!
        .copyWith(fontSize: 16, fontWeight: FontWeight.w400);

    return Column(
      children: [
        TextFormField(
          focusNode: _oldMobileNumberFocusNode,
          controller: _oldMobileNumberController,
          style: _textViewStyle,
          //initialValue: _requestOTPData['oldMobileNumber'],
          autovalidateMode: _enableRequestOTP
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          decoration: AdaptiveTheme.textFormFieldDecoration(
            context,
            'Old Number',
            _oldMobileNumberFocusNode,
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
            _requestOTPData['oldMobileNumber'] = value!;
          },
        ),
        const SizedBox(height: 10),
        //NEW MOBILE NUMBER
        TextFormField(
          focusNode: _mobileNumberFocusNode,
          style: _textViewStyle,
          initialValue: _enteredMobileNumber,
          autovalidateMode: _enableRequestOTP
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          decoration: AdaptiveTheme.textFormFieldDecoration(
            context,
            'New Number',
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
            if (value == _oldMobileNumberController.text) {
              return "Both mobile numbers can't be same";
            }
            return null;
          },
          onSaved: (value) {
            _requestOTPData['newMobileNumber'] = value!;
          },
        ),
        //NEW MOBILE NUMBER
        const SizedBox(height: 40),
        if (_isLoading)
          AdaptiveCircularProgressIndicator()
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
                  titleColour: AdaptiveTheme.primaryColor(context),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    _otpTextController.text = '';
                    _requestOTP(context);
                  },
                  borderColor: AdaptiveTheme.primaryColor(context),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
