import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:package_info_plus/package_info_plus.dart';

import '../../../adaptive/adaptive_circular_progressInd.dart';

import '../../../adaptive/adaptive_theme.dart';
import '../../../util/app_theme.dart';
import '../../../util/app_theme_cupertino.dart';
import '../../../widgets/web_banner.dart';
import '../../../widgets/web_bottom_bar.dart';
import '../../home/landing/screens/landing_page.dart';

import '/src/models/b2cparentkyc.dart';
import '/src/models/kycdoc_response.dart';
import '/widgets/kyc_document_image_picker.dart';
import '/widgets/kyc_document_picker.dart';
import '/helpers/app_info.dart';
import '../../../util/ui_helpers.dart';
import '/src/providers/user.dart';
import '/util/dialogs.dart';
import '/src/models/login_response.dart';
import '/src/providers/auth.dart';

class KycTypeSelectionScreenWeb extends StatefulWidget {
  static String routeName = '/web-kyc-update';

  const KycTypeSelectionScreenWeb({Key? key}) : super(key: key);

  @override
  _KycTypeSelectionScreenWebState createState() =>
      _KycTypeSelectionScreenWebState();
}

class _KycTypeSelectionScreenWebState extends State<KycTypeSelectionScreenWeb> {
  final _formKey = GlobalKey<FormState>();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final _docNumberFocusNode = FocusNode();
  //bool _obscured = true;
  final _docNumberController = TextEditingController();

  ParentDocumentTypeList? _defaultDocument;
  ParentDocumentTypeList? _selectedDocument;
  // List<ParentDocumentTypeList>? _documentList;

  var _isInIt = true;
  var _isLoading = false;
  late LoginResponse _loginResponse;
  File _selectedImage = File('file.txt'); //dumm file name to avoid null issue

  final Map<String, dynamic> _dataFields = {
    //'adStatus': '',
    //'countryCode': '',
    'docType': '',
    'documentNumber': '',
    //'kycStatus': '',
    'parentDocumentTypeId': '',
    //'password': '',
    //'registrationType': '',
    //'userID': '',
    'appVersion': '',
    'cityId': '',
    'countryId': '',
    'email': '',
    'mobileOs': '',
    'name': '',
    'parentId': '',
    'phone': '',
    'pin': '',
    'stateId': '',
  };

  @override
  void dispose() {
    _docNumberController.dispose();
    _docNumberFocusNode.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _docNumberFocusNode.addListener(_onOnFocusNodeEvent);
  }

  _onOnFocusNodeEvent() {
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      setState(() {
        _isLoading = true;
      });
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
      if (_loginResponse.b2cParent != null) {
        if (_loginResponse.b2cParent!.docType != '') {}
      }

      setState(() {
        _isLoading = false;
      });
      _isInIt = false;
      super.didChangeDependencies();
    }
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    if (_selectedImage.path == 'file.txt') {
      Dialogs().ackInfoAlert(context, 'Please upload document image!');
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });
    PackageInfo _packageInfo = await AppInfo.getPackageInfo();
    _dataFields['appVersion'] = _packageInfo.version;
    // _dataFields['mobileOs'] = Platform.isIOS
    //     ? 'iOs'
    //     : Platform.isAndroid
    //         ? 'android'
    //         : 'Unknown';
    _dataFields['mobileOs'] = kIsWeb
        ? 'unknown'
        : Platform.isIOS
            ? 'iOs'
            : Platform.isAndroid
                ? 'android'
                : 'Unknown';
    //The API request is not in standard object format, its a combination of many values
    //Build the object
    B2CParentKYC parent = B2CParentKYC(
      parentID: _loginResponse.b2cParent!.parentID,
      name: _loginResponse.b2cParent!.name,
      emailID: _loginResponse.b2cParent!.emailID,
      countryID: _loginResponse.b2cParent!.countryID,
      stateID: _loginResponse.b2cParent!.stateID,
      locationID: _loginResponse.b2cParent!.locationID,
      pinCode: _loginResponse.b2cParent!.pinCode,
      parentDocumentTypeId: _selectedDocument!.documentId,
      kycType: "offline",
      docNumber: _dataFields['documentNumber'],
      docType: _selectedDocument!.documentType,
    );
    try {
      var _inserted = await Provider.of<User>(context, listen: false)
          .parentProfileKYC(
              parent,
              _loginResponse.mobileNumber,
              _dataFields['appVersion'],
              _dataFields['mobileOs'],
              _selectedImage);
      if (_inserted) {
        bool _mobileValidated = await Provider.of<Auth>(context, listen: false)
            .validateMobileNumber(_loginResponse.mobileNumber);
        //Refreshing the local storage . this needs to be rechecked for a better option
        if (_mobileValidated) {
          setState(() {
            _isLoading = false;
          });
        }

        // await Dialogs().ackAlert(context, 'Successfully submitted the request',
        //     'Will take upto 7 days for verification');
        await Dialogs().ackSuccessAlert(
            context, 'SUCCESS!!!', 'Will take upto 7 days for verification');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LandingPage()),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      await Dialogs().ackAlert(context, 'An error occured', error.toString());
    }
  }

  void saveImage(File selectedImage) {
    setState(() {
      _selectedImage = selectedImage;
    });
  }

  void updateDocs(
    ParentDocumentTypeList? parentDocumentTypeList,
  ) {
    setState(() {
      _selectedDocument = parentDocumentTypeList;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _textViewStyle = kIsWeb || Platform.isAndroid
        ? AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontSize: 15)
            .copyWith(fontSize: 15)
        : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w300); //TextStyle(color: Colors.black87);
    // TextStyle _dropdownTextViewStyle = _textViewStyle;
    // TextStyle _dropdownLabelStyle =
    //     _textViewStyle.copyWith(fontWeight: FontWeight.w200);

    Widget _bodyWidget() {
      return Column(
        children: [
          if (screenWidth(context) <= 400)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: screenWidth(context) * 0.35,
                child: Center(
                    child: Image.asset('assets/images/kyc_selection.png')),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (screenWidth(context) > 400)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: screenWidth(context) * 0.35,
                    child: Center(
                        child: Image.asset('assets/images/kyc_selection.png')),
                  ),
                ),
              SizedBox(
                width: screenWidth(context) *
                    (screenWidth(context) > 400 ? 0.45 : 0.90),
                child: Column(
                  children: [
                    Text(
                      'KYC',
                      textAlign: TextAlign.center,
                      style: kIsWeb || Platform.isAndroid
                          ? AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: AdaptiveTheme.primaryColor(context))
                          : AppThemeCupertino
                              .lightTheme.textTheme.navTitleTextStyle
                              .copyWith(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: AdaptiveTheme.primaryColor(context)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'It is important to identify each parent who sign-up to SchoolWizard platform.',
                        style: kIsWeb || Platform.isAndroid
                            ? AppTheme.lightTheme.textTheme.bodyMedium!
                                .copyWith(
                                    fontSize: 16, fontWeight: FontWeight.w300)
                            : AppThemeCupertino
                                .lightTheme.textTheme.navTitleTextStyle
                                .copyWith(
                                    fontSize: 16, fontWeight: FontWeight.w300),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Please help us to complete the process by any of the following methods.',
                        style: kIsWeb || Platform.isAndroid
                            ? AppTheme.lightTheme.textTheme.bodyMedium!
                                .copyWith(
                                    fontSize: 16, fontWeight: FontWeight.w300)
                            : AppThemeCupertino
                                .lightTheme.textTheme.navTitleTextStyle
                                .copyWith(
                                    fontSize: 16, fontWeight: FontWeight.w300),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            verticalSpaceSmall,
                            /* Text(
                                    'Document Type',
                                    style: kIsWeb || Platform.isAndroid
                                        ? AppTheme.lightTheme.textTheme.bodyMedium!
                                            .copyWith(
                                                fontSize: 16, fontWeight: FontWeight.w700)
                                        : AppThemeCupertino
                                            .lightTheme.textTheme.navTitleTextStyle
                                            .copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700),
                                  ),*/
                            verticalSpaceSmall,
                            KycDocumentPicker(_defaultDocument, updateDocs,
                                _isLoading ? false : true),
                            TextFormField(
                              enabled: _isLoading ? false : true,
                              decoration: AdaptiveTheme.textFormFieldDecoration(
                                  context,
                                  'Document Number',
                                  _docNumberFocusNode),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp("[0-9a-zA-Z]")),
                              ],
                              controller: _docNumberController,
                              textInputAction: TextInputAction.next,
                              style: _textViewStyle,
                              focusNode: _docNumberFocusNode,
                              // onFieldSubmitted: (_) {
                              //   FocusScope.of(context).requestFocus(_emailFocusNode);
                              // },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please provide document number';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _dataFields['documentNumber'] = value!;
                              },
                            ),
                            DocImagePicker(_loginResponse.b2cParent!.docImage,
                                saveImage, _isLoading),
                            verticalSpaceMedium,
                            _isLoading
                                ? Center(
                                    child: AdaptiveCircularProgressIndicator())
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: screenWidthPercentage(context,
                                            percentage:
                                                (screenWidth(context) > 800
                                                    ? .10
                                                    : screenWidth(context) > 400
                                                        ? 0.20
                                                        : 0.40)),
                                        height: 40,
                                        child: appButton(
                                          context: context,
                                          width: 20,
                                          height: 20,
                                          title: 'Continue',
                                          titleColour:
                                              AdaptiveTheme.primaryColor(
                                                  context),
                                          borderColor:
                                              AdaptiveTheme.primaryColor(
                                                  context),
                                          onPressed: () => _submit(),
                                        ),
                                      ),
                                    ],
                                  ),
                            verticalSpaceMedium,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Scaffold(
      endDrawer: WebBannerDrawer(),
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            WebBanner(
              showMenu: true,
              showHomeButton: true,
              showProfileButton: true,
              scaffoldKey: scaffoldKey,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50.0, top: 40),
              child: Row(
                children: [
                  Text(
                    'KYC Registration',
                    style: TextStyle(
                        letterSpacing: 0.0,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            Container(
              width: screenWidth(context) * 0.90,
              //height: screenHeight(context) * 0.98,
              child: _isLoading == false
                  ? _bodyWidget()
                  : Center(child: AdaptiveCircularProgressIndicator()),
            ),
            WebBottomBar(),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
