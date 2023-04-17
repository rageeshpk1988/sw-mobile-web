import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../util/dialogs.dart';
import '../../../util/notify_user.dart';
import '../../providers/auth.dart';
import '../../providers/user.dart';

class LoginMobileService {
  Future<bool> requestOTP(
    BuildContext context,
    GlobalKey<FormState> formKey,
    Map<String, String> requestOTPData,
    Function setWidgetLoadingState,
    Function setRequestOTPCallbackState,
  ) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    formKey.currentState!.save();
    setWidgetLoadingState(true);
    try {
      var _success = await Provider.of<User>(context, listen: false)
          .requestOTP(requestOTPData['mobileNumber']!);
      if (_success) {
        NotifyUser().showSnackBar(
            'An OTP has been sent to your mobile number', context);
        setRequestOTPCallbackState(
            false, false, true, requestOTPData['mobileNumber']!, false);
      } else {
        setWidgetLoadingState(false);
        await Dialogs()
            .ackAlert(context, 'OTP Error', 'Unable to process your request!');
      }
    } catch (error) {
      setWidgetLoadingState(false);
      await Dialogs().ackAlert(context, 'An error occured', error.toString());
    }
    return true;
  }

  Future<bool> resendOTP(
    BuildContext context,
    GlobalKey<FormState> formKey,
    Map<String, String> requestOTPData,
    Function setResendOTPLoadingState,
  ) async {
    bool retValue = false;
    setResendOTPLoadingState(true, true);

    try {
      var _success = await Provider.of<User>(context, listen: false)
          .requestOTP(requestOTPData['mobileNumber']!);

      NotifyUser()
          .showSnackBar('An OTP has been sent to your mobile number', context);
      setResendOTPLoadingState(false, false);

      if (!_success) {
        await Dialogs()
            .ackAlert(context, 'OTP Error', 'Unable to process your request!');
        retValue = false;
      }
    } catch (error) {
      setResendOTPLoadingState(false, false);
      await Dialogs().ackAlert(context, 'An error occured', error.toString());
    }
    return retValue;
  }

  Future<bool> validateOTP(
    BuildContext context,
    GlobalKey<FormState> formKey,
    String enteredMobileNumber,
    Map<String, String> validateOTPData,
    Function setWidgetLoadingState,
    Function setValidateOTPCallbackState,
    Function validateOTPPopScreen,
    TextEditingController otpTextController,
  ) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    formKey.currentState!.save();
    setWidgetLoadingState(true);

    final _otpResponse = Provider.of<User>(context, listen: false).otpResponse;
    bool _success = false;
    try {
      if (_otpResponse.providerType == '1') {
        _success = await Provider.of<User>(context, listen: false)
            .validateOTPLocal(enteredMobileNumber, validateOTPData['otp']!);
      } else {
        _success = await Provider.of<User>(context, listen: false)
            .validateOTPIntl(enteredMobileNumber, validateOTPData['otp']!);
      }

      if (_success) {
        //CALL login/android/licence to check the status, if not a new user then load login_with_pass screen.
        //else ask the below confirmation message
        bool _mobileValidated = await Provider.of<Auth>(context, listen: false)
            .validateMobileNumber(enteredMobileNumber, true);
        otpTextController.text = '';
        if (_mobileValidated) {
          validateOTPPopScreen();
        } else {
          setValidateOTPCallbackState(false, false, false);
        }
      }
    } catch (error) {
      setWidgetLoadingState(false);
      await Dialogs().ackAlert(context, 'An error occured', error.toString());
    }
    return true;
  }
}
