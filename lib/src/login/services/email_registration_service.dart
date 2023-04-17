//TODO:: THIS NEEDS TO BE ENABLED FOR AVOIDING DUPLICATE CODES

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../util/dialogs.dart';

import '../../../util/password_generator.dart';
import '../../models/socialaccesstoken_request.dart';
import '../../providers/auth.dart';
import '../../providers/google_signin_controller.dart';
import '../../providers/user.dart';

class EmailRegistrationService {
  Future<bool> submit(
      BuildContext context,
      GlobalKey<FormState> formKey,
      Map<String, String> registration,
      String passwordText,
      String enteredMobileNumber,
      Function setWidgetLoadingState,
      Function popScreenHandler,
      String referralCode) async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) {
      return false;
    }
    formKey.currentState!.save();
    setWidgetLoadingState(true);
    registration['password'] = passwordText;
    try {
      var _inserted = await Provider.of<User>(context, listen: false)
          .registerParent(
              enteredMobileNumber,
              registration['name']!,
              registration['emailId']!,
              registration['password']!,
              referralCode);
      if (_inserted) {
        //CALL login/android/licence to check the status, if not a new user then load login_with_pass screen.
        //else ask the below confirmation message
        bool _mobileValidated = await Provider.of<Auth>(context, listen: false)
            .validateMobileNumber(enteredMobileNumber, true);
        //TODO:: This needs to be rechecked because we are not validating the AD login
        if (_mobileValidated) {
          setWidgetLoadingState(false);
          popScreenHandler();
        }
      } else {
        setWidgetLoadingState(false);
        await Dialogs()
            .ackAlert(context, 'Alert', 'Error while saving the data...');
      }
    } catch (error) {
      setWidgetLoadingState(false);
      await Dialogs().ackAlert(context, 'An error occured', error.toString());
    }
    return true;
  }

//social registration
  Future<void> submitSocial(
    BuildContext context,
    Function updateHandler,
    String _appName,
    Map<String, String> registration,
    String enteredMobileNumber,
    Function setWidgetLoadingState,
    Function navigateToLandingpage,
  ) async {
    if (_appName == "google") {
      final provider =
          Provider.of<GoogleSignInProvider>(context, listen: false);
      SocialAdRequest _socialAccessToken = await provider.googleLogin(context);
      setWidgetLoadingState(true);
      // final password = RandomPasswordGenerator();
      registration['password'] = generatePassword(true, true, true, true, 17);
      if (_socialAccessToken.email == null || _socialAccessToken.name == null) {
        setWidgetLoadingState(false);

        await Dialogs().ackAlert(context, 'Error',
            'Something Went Wrong...To login email id is mandatory, Please give the required permissions and try again');
      } else {
        try {
          // var authToken =
          //     Provider.of<Auth>(context, listen: false).loginResponse.token;

          var _inserted = await Provider.of<User>(context, listen: false)
              .registerParent(enteredMobileNumber, _socialAccessToken.name!,
                  _socialAccessToken.email!, registration['password']!, "");
          if (_inserted) {
            //CALL login/android/licence to check the status, if not a new user then load login_with_pass screen.
            //else ask the below confirmation message
            bool _mobileValidated =
                await Provider.of<Auth>(context, listen: false)
                    .validateMobileNumber(enteredMobileNumber, true);
            //TODO:: This needs to be rechecked because we are not validating the AD login
            if (_mobileValidated) {
              try {
                //_authData['password'] = _passwordController.text;
                await Provider.of<Auth>(context, listen: false).loginADSocial(
                    _socialAccessToken.token, enteredMobileNumber, _appName);
                updateHandler();
                /*setState(() {
           _isLoading = false;
         });*/
                navigateToLandingpage();
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => LandingPage()),
                // );
              } catch (error) {
                setWidgetLoadingState(false);

                await Dialogs()
                    .ackAlert(context, 'An error occured', error.toString());
              }
            }
          } else {
            setWidgetLoadingState(false);
            await Dialogs()
                .ackAlert(context, 'Alert', 'Error while saving the data...');
          }
        } catch (error) {
          setWidgetLoadingState(false);
          await Dialogs()
              .ackAlert(context, 'An error occured', error.toString());
        }
      }
    } else {
      final provider =
          Provider.of<GoogleSignInProvider>(context, listen: false);
      SocialAdRequest _socialAccessToken =
          await provider.facebookLogin(context);
      setWidgetLoadingState(true);
      //  final password = RandomPasswordGenerator();
      registration['password'] = generatePassword(true, true, true, true, 17);
      if (_socialAccessToken.email == null || _socialAccessToken.name == null) {
        setWidgetLoadingState(false);
        await Dialogs().ackAlert(context, 'Error',
            'Something Went Wrong... To login email id is mandatory, Please give the required permissions and try again');
      } else {
        try {
          // var authToken =
          //     Provider.of<Auth>(context, listen: false).loginResponse.token;

          var _inserted = await Provider.of<User>(context, listen: false)
              .registerParent(enteredMobileNumber, _socialAccessToken.name!,
                  _socialAccessToken.email!, registration['password']!, "");
          if (_inserted) {
            //CALL login/android/licence to check the status, if not a new user then load login_with_pass screen.
            //else ask the below confirmation message
            bool _mobileValidated =
                await Provider.of<Auth>(context, listen: false)
                    .validateMobileNumber(enteredMobileNumber, true);
            //TODO:: This needs to be rechecked because we are not validating the AD login
            if (_mobileValidated) {
              try {
                //_authData['password'] = _passwordController.text;
                await Provider.of<Auth>(context, listen: false).loginADSocial(
                    _socialAccessToken.token, enteredMobileNumber, _appName);
                updateHandler();

                navigateToLandingpage();
              } catch (error) {
                setWidgetLoadingState(false);
                await Dialogs()
                    .ackAlert(context, 'An error occured', error.toString());
              }
            }
          } else {
            setWidgetLoadingState(false);
            await Dialogs()
                .ackAlert(context, 'Alert', 'Error while saving the data...');
          }
        } catch (error) {
          setWidgetLoadingState(false);
          await Dialogs()
              .ackAlert(context, 'An error occured', error.toString());
        }
      }
    }
  }
}
