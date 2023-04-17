import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/src/kyc/screens/kyc_type_selection_web.dart';

import '../src/providers/auth.dart';
import '/src/kyc/screens/kyc_type_selection.dart';
import '../../../src/models/login_response.dart';

import 'dialogs.dart';

class KycUtils {
  static void launchKycScreen(
    BuildContext context,
    LoginResponse? _loginResponse,
    int? status, {
    bool isWeb = false,
  }) async {
    // _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
    //int? status;
    // print(_loginResponse!.b2cParent!.parentID);
    /*print(_loginResponse.b2cParent!.docNumber);
    print(_loginResponse.b2cParent!.docType);*/
    //await Provider.of<User>(context, listen: false).getapproveStatus(_loginResponse!.b2cParent!.parentID).then((value) => status = value);
    //print(status);

    if (status == 0 && _loginResponse!.b2cParent!.docNumber == "") {
      if (isWeb) {
        Navigator.of(context).pushNamed(
          KycTypeSelectionScreenWeb.routeName,
        );
      } else {
        Navigator.of(context).pushNamed(
          KycTypeSelectionScreen.routeName,
        );
      }
    } else if (status == 0 && _loginResponse!.b2cParent!.docNumber != "") {
      /* Navigator.of(context).pushNamed(KycTypeSelectionScreen.routeName,
      );*/
      Provider.of<Auth>(context, listen: false).loginResponse;
      await Provider.of<Auth>(context, listen: false)
          .getApproveStatusKyc(_loginResponse.b2cParent!.parentID);
      Dialogs().ackInfoAlert(
          context, 'KYC details submitted, pending verification!');
    } else if (status == 1) {
      Dialogs().ackSuccessAlert(context, 'SUCCESS!!!',
          'Your KYC is verified and you have full access to SchoolWizard!');
    } else if (status == 2) {
      if (isWeb) {
        Navigator.of(context).pushNamed(
          KycTypeSelectionScreenWeb.routeName,
        );
      } else {
        Navigator.of(context).pushNamed(
          KycTypeSelectionScreen.routeName,
        );
      }

      Dialogs().ackInfoAlert(context,
          'Your KYC request is not approved. Please ensure the given details are correct and try again, or try using aadhaar online verification.');
    }
  }
}
