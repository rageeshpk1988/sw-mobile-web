import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../../../helpers/app_info.dart';
import '../../../src/models/b2cparentkyc.dart';
import '../../../src/models/fetchkycdata_response.dart';
import '../../../src/models/fetchofflinexml_response.dart';
import '../../../src/models/getcaptcha_response.dart';
import '../../../src/models/login_response.dart';
import '../../../src/providers/auth.dart';
import '../../../src/providers/kyc_document.dart';
import '../../../src/providers/user.dart';
import '../../../util/app_theme.dart';
import '../../../util/app_theme_cupertino.dart';
import '../../../util/notify_user.dart';
import '../../../util/ui_helpers.dart';

import '../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../adaptive/adaptive_custom_appbar.dart';
import '../../../adaptive/adaptive_theme.dart';
import 'kyc_online_confirmed_screen.dart';

class KycOnlineScreen extends StatefulWidget {
  const KycOnlineScreen({Key? key}) : super(key: key);

  @override
  _KycOnlineScreenState createState() => _KycOnlineScreenState();
}

class _KycOnlineScreenState extends State<KycOnlineScreen> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _docNumberFocusNode = FocusNode();
  final _captchaFocusNode = FocusNode();
  final _otpFocusNode = FocusNode();
  final _shareCodeFocusNode = FocusNode();
  //bool _obscured = true;
  final _docNumberController = TextEditingController();
  final _captchaController = TextEditingController();
  final _otpController = TextEditingController();
  final _shareCodeController = TextEditingController();
  late LoginResponse _loginResponse;
  var _isInIt = true;
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  String? captchaImg;
  Future? loader;
  String clientID = "ZOFT8053";
  String apiKey = "sfhj38hf93zx";
  String saLt = "hf3hfs9ajsaq";
  String? reqID;
  String? uuID;
  String? aadharName;
  String? aadharNumber;
  String? passKey;
  String? docContent;

  GetCaptcha? response1;
  GetCaptcha? response2;
  GetCaptcha? response3;
  GetCaptcha? response4;
  FetchKycData? response5;
  FetchOfflineXml? response6;

  Random random = new Random();

  // var _isInIt = true;
  var _isLoading = false;
  var _isLoading1 = false;
  var _isLoading2 = false;
  var _part2 = false;

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
    'captchaString': '',
    'email': '',
    'mobileOs': '',
    'name': '',
    'parentId': '',
    'phone': '',
    'shareCode': '',
    'otp': '',
  };

  @override
  void dispose() {
    _docNumberController.dispose();
    _docNumberFocusNode.dispose();
    _captchaController.dispose();
    _captchaFocusNode.dispose();
    _otpController.dispose();
    _otpFocusNode.dispose();
    _shareCodeController.dispose();
    _shareCodeFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _docNumberFocusNode.addListener(_onOnFocusNodeEvent);
    _captchaFocusNode.addListener(_onOnFocusNodeEvent);
    _otpFocusNode.addListener(_onOnFocusNodeEvent);
    _shareCodeFocusNode.addListener(_onOnFocusNodeEvent);
    reqID = "ZOFT8053" + "-" + "${DateTime.now().millisecondsSinceEpoch}" + "";
    loader = getCaptcha(reqID);
  }

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      setState(() {
        _isLoading = true;
      });
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
      setState(() {
        _isLoading = false;
      });
      _isInIt = false;
      super.didChangeDependencies();
    }
  }

  int nextNumber({required int min, required int max}) =>
      min + Random().nextInt(max - min + 1);

  List<int> nextNumbers(int length, {required int min, required int max}) {
    final numbers = Set<int>();
    while (numbers.length < length) {
      final number = nextNumber(min: min, max: max);
      numbers.add(number);
    }
    return List.of(numbers);
  }

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  _onOnFocusNodeEvent() {
    setState(() {
      //documentNumber = _docNumberController.text;
      //captchaString = _captchaController.text;
    });
  }

  /* ➔	getCaptcha            :
  <client_code>|<request_id>|<api_key>|<salt>
  ➔	  fetchKYCData     :
  <client_code>|<uuid>|<api_key>|<salt>
*/

  getCaptcha(String? reqID) async {
    response1 = await Provider.of<KycDocument>(context, listen: false)
        .getCaptchaKyc(reqID);

    if (response1?.responseStatus?.status == 'SUCCESS') {
      setState(() {
        captchaImg = response1?.responseData?.captcha;
        uuID = response1?.responseData?.uuid;
      });
    } else {
      /*NotifyUser()
          .showSnackBar('${response1?.responseStatus?.message}',ctx);*/
    }
  }

  enterAadhaar(String? uuID, BuildContext ctx) async {
    final isValid = _formKey1.currentState!.validate();
    if (!isValid) {
      return;
    }

    _formKey1.currentState!.save();

    setState(() {
      _isLoading = true;
      _isLoading1 = true;
    });
    String aDd = _dataFields['documentNumber'];
    String captcha = _dataFields['captchaString'];
    response2 = await Provider.of<KycDocument>(context, listen: false)
        .enterAadhaarKyc(uuID, ctx, aDd, captcha);

    // print(aDd);
    // print(captcha);
    // print(uuID);

    if (response2?.responseStatus?.status == 'SUCCESS') {
      NotifyUser().showSnackBar('${response2?.responseStatus?.message}', ctx);
      setState(() {
        _isLoading = false;
        _part2 = true;
      });
    } else {
      NotifyUser().showSnackBar('${response2?.responseStatus?.message}', ctx);
      getNewCaptcha(uuID, ctx);
      setState(() {
        _isLoading = false;
        _isLoading1 = false;
      });
    }
  }

  getNewCaptcha(String? uuID, BuildContext ctx) async {
    response3 = await Provider.of<KycDocument>(context, listen: false)
        .getNewCaptchaKyc(uuID, ctx);
    if (response3?.responseStatus?.status == 'SUCCESS') {
      setState(() {
        captchaImg = response3?.responseData?.captcha;
        // uuID = response1?.responseData?.uuid;
      });
    } else {
      /*NotifyUser()
          .showSnackBar('$error',ctx);*/
    }
  }

  enterOtp(String? uuID, BuildContext ctx) async {
    final isValid = _formKey2.currentState!.validate();
    if (!isValid) {
      return;
    }

    _formKey2.currentState!.save();

    setState(() {
      //_isLoading = true;
      _isLoading2 = true;
    });
    String oTp = _dataFields['otp'];
    String shareCode = _dataFields['shareCode'];
    response4 = await Provider.of<KycDocument>(context, listen: false)
        .enterOtpKyc(uuID, ctx, oTp, shareCode);
    // print(oTp);
    // print(shareCode);
    // print(uuID);
    if (response4?.responseStatus?.status == 'SUCCESS') {
      /*NotifyUser()
              .showSnackBar('${response4?.responseStatus?.message}',ctx);*/
      /*setState(() {
            _isLoading = false;
           // _part2 = true;
          });*/
      fetchKycData(uuID, ctx);
    } else {
      if (response4?.responseStatus?.code == '470011') {
        NotifyUser()
            .showSnackBar('Something went wrong. Please try again.', ctx);
        setState(() {
          //_isLoading = false;
          _isLoading2 = false;
        });
      } else {
        NotifyUser().showSnackBar('${response4?.responseStatus?.message}', ctx);
        setState(() {
          //_isLoading = false;
          _isLoading2 = false;
        });
      }
      if (response4?.responseStatus?.code == '470023') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => KycOnlineScreen()),
        );
      }
    }
  }

  /* ➔	getCaptcha            :
  <client_code>|<request_id>|<api_key>|<salt>
  ➔	  fetchKYCData     :
  <client_code>|<uuid>|<api_key>|<salt>
*/

  fetchKycData(String? uuID, BuildContext ctx) async {
    response5 = await Provider.of<KycDocument>(context, listen: false)
        .fetchKycDataKyc(uuID, ctx);

    if (response5?.responseStatus?.status == 'SUCCESS') {
      setState(() {
        aadharName = response5?.responseData?.name;
        aadharNumber = response5?.responseData?.documentId;
      });
      fetchOfflineXml(uuID, ctx);
    } else {}
  }

  fetchOfflineXml(String? uuID, BuildContext ctx) async {
    response6 = await Provider.of<KycDocument>(context, listen: false)
        .fetchOfflineXmlKyc(uuID, ctx);

    if (response6?.responseStatus?.status == 'SUCCESS') {
      setState(() {
        passKey = response6?.responseData?.password;
        docContent = response6?.responseData?.docContent;
        //_isLoading2= false;
      });
      _submit(uuID, ctx);
      /*Navigator.pushReplacement(
            ctx,
            MaterialPageRoute(builder: (context) => KycOnlineConfirmed(aadharName!,aadharNumber!)),
          );*/
    } else {}
  }

  Future<void> _submit(String? uuID, BuildContext ctx) async {
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
      parentDocumentTypeId: 10,
      kycType: "online",
      docNumber: _dataFields['documentNumber'],
      docType: "Aadhaar",
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
            _isLoading2 = false;
          });
        }

        Navigator.pushReplacement(
          ctx,
          MaterialPageRoute(
              builder: (context) =>
                  KycOnlineConfirmed(aadharName!, aadharNumber!)),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading2 = false;
      });
    }
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text('Do you really want to go back?',
              style: kIsWeb || Platform.isAndroid
                  ? AppTheme.lightTheme.textTheme.bodySmall
                  : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
                      .copyWith(fontWeight: FontWeight.w500)),
          content: Text(
            'All progress made will be lost.',
            style: kIsWeb || Platform.isAndroid
                ? AppTheme.lightTheme.textTheme.bodyMedium!
                    .copyWith(fontSize: 14)
                : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
                    .copyWith(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _textViewStyle = kIsWeb || Platform.isAndroid
        ? AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontSize: 15)
            .copyWith(fontSize: 15)
        : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w400); //TextStyle(color: Colors.black87);
    // TextStyle _dropdownTextViewStyle = _textViewStyle;
    // TextStyle _dropdownLabelStyle =
    // _textViewStyle.copyWith(fontWeight: FontWeight.w200);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AdaptiveCustomAppBar(
          title: 'Aadhaar Card Verification',
          showShopifyHomeButton: false,
          showShopifyCartButton: false,
          showKycButton: false,
          showProfileButton: false,
          showHamburger: false,
          scaffoldKey: null,
          adResponse: null,
          updateHandler: null,
          loginResponse: null,
          showMascot: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  verticalSpaceMedium,
                  /*Center(
                      child: Text(
                        'Aadhaar Card Verification',
                        style: Theme.of(context).textTheme.headline5?.copyWith(
                            color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),*/
                  verticalSpaceMedium,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 50.0,
                      ),
                      Center(
                          child: captchaImg == null
                              ? Icon(Icons.more_horiz,
                                  color: Colors.grey.shade100)
                              : Image.memory(base64Decode(captchaImg!))),
                      captchaImg == null
                          ? Icon(Icons.more_horiz, color: Colors.grey.shade100)
                          : IconButton(
                              onPressed: captchaImg == null
                                  ? null
                                  : () {
                                      getNewCaptcha(uuID, context);
                                    },
                              icon: Icon(
                                Icons.refresh,
                                color: AppTheme.primaryColor,
                              )),
                    ],
                  ),
                  verticalSpaceMedium,
                  Form(
                    key: _formKey1,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Row(
                      children: [
                        //ProfileImagePicker(() {}),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  enabled: _isLoading1 ? false : true,
                                  decoration:
                                      AdaptiveTheme.textFormFieldDecoration(
                                          context,
                                          'Type The Characters Above',
                                          _captchaFocusNode),
                                  controller: _captchaController,
                                  textInputAction: TextInputAction.next,
                                  focusNode: _captchaFocusNode,
                                  style: _textViewStyle,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please type captcha value';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _dataFields['captchaString'] = value!;
                                  },
                                ),
                                verticalSpaceSmall,
                                TextFormField(
                                  enabled: _isLoading1 ? false : true,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(12),
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]')),
                                  ],
                                  decoration:
                                      AdaptiveTheme.textFormFieldDecoration(
                                          context,
                                          'Aadhaar Number',
                                          _docNumberFocusNode),
                                  controller: _docNumberController,
                                  textInputAction: TextInputAction.next,
                                  style: _textViewStyle,
                                  keyboardType: TextInputType.number,
                                  focusNode: _docNumberFocusNode,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please provide aadhaar number';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _dataFields['documentNumber'] = value!;
                                  },
                                ),
                                verticalSpaceMedium,
                                _isLoading
                                    ? Align(
                                        alignment: Alignment.centerRight,
                                        child:
                                            AdaptiveCircularProgressIndicator())
                                    : Align(
                                        alignment: Alignment.centerRight,
                                        child: /*ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            primary: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              side: BorderSide(
                                                color:
                                                    AdaptiveTheme.primaryColor(
                                                        context),
                                              ),
                                            ),
                                          ),
                                          label: Text(
                                            'Send OTP',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color:
                                                    AdaptiveTheme.primaryColor(
                                                        context)),
                                          ),
                                          onPressed: _isLoading1
                                              ? null
                                              : () =>
                                                  enterAadhaar(uuID, context),
                                          icon: Icon(
                                            Icons.send,
                                            color: AdaptiveTheme.primaryColor(
                                                context),
                                          ),
                                        )*/
                                            appButton(
                                                context: context,
                                                width: 120,
                                                height: 30,
                                                title: 'Send OTP',
                                                titleColour: _isLoading1
                                                    ? Colors.grey
                                                    : AdaptiveTheme
                                                        .primaryColor(context),
                                                onPressed: _isLoading1
                                                    ? () {}
                                                    : () => enterAadhaar(
                                                        uuID, context),
                                                borderColor: _isLoading1
                                                    ? Colors.grey
                                                    : AdaptiveTheme
                                                        .primaryColor(context),
                                                borderRadius: 10),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // UserLocDropdownWidget(),

                  verticalSpaceMedium,
                  Visibility(
                    visible: _part2 ? true : false,
                    child: Form(
                      key: _formKey2,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(
                                  child: TextFormField(
                                    enabled: _isLoading2 ? false : true,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(6),
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]')),
                                    ],
                                    decoration:
                                        AdaptiveTheme.textFormFieldDecoration(
                                            context,
                                            'Enter OTP',
                                            _otpFocusNode),
                                    controller: _otpController,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    style: _textViewStyle,
                                    focusNode: _otpFocusNode,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please provide OTP';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _dataFields['otp'] = value!;
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 50.0,
                                ),
                                Flexible(
                                  child: TextFormField(
                                    enabled: _isLoading2 ? false : true,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(4),
                                      FilteringTextInputFormatter.allow(
                                          RegExp("[0-9a-zA-Z]")),
                                    ],
                                    decoration:
                                        AdaptiveTheme.textFormFieldDecoration(
                                            context,
                                            '*Share Code',
                                            _shareCodeFocusNode),
                                    controller: _shareCodeController,
                                    textInputAction: TextInputAction.next,
                                    style: _textViewStyle,
                                    focusNode: _shareCodeFocusNode,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please provide Share Code';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _dataFields['shareCode'] = value!;
                                    },
                                  ),
                                ),
                              ]),
                          verticalSpaceMedium,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Entered Wrong Aadhaar?:',
                                style: kIsWeb || Platform.isAndroid
                                    ? AppTheme.lightTheme.textTheme.bodySmall!
                                        .copyWith(fontSize: 15)
                                    : AppThemeCupertino
                                        .lightTheme.textTheme.navTitleTextStyle,
                                textAlign: TextAlign.center,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7),
                                      side: BorderSide(
                                        color:
                                            AdaptiveTheme.primaryColor(context),
                                      ),
                                    ),
                                  ),
                                  label: Text('Re-Submit',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: AdaptiveTheme.primaryColor(
                                              context))),
                                  onPressed: _isLoading2
                                      ? null
                                      : () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    KycOnlineScreen()),
                                          );
                                        },
                                  icon: Icon(
                                    Icons.refresh,
                                    color: AdaptiveTheme.primaryColor(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          verticalSpaceMedium,
                          Text(
                            '*Share Code is a 4 letters alphanumeric code which',
                            style: kIsWeb || Platform.isAndroid
                                ? AppTheme.lightTheme.textTheme.bodySmall!
                                    .copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300)
                                : AppThemeCupertino
                                    .lightTheme.textTheme.navTitleTextStyle
                                    .copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'you can create in order to share your Aadhaar',
                            style: kIsWeb || Platform.isAndroid
                                ? AppTheme.lightTheme.textTheme.bodySmall!
                                    .copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300)
                                : AppThemeCupertino
                                    .lightTheme.textTheme.navTitleTextStyle
                                    .copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'details with us.',
                            style: kIsWeb || Platform.isAndroid
                                ? AppTheme.lightTheme.textTheme.bodySmall!
                                    .copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300)
                                : AppThemeCupertino
                                    .lightTheme.textTheme.navTitleTextStyle
                                    .copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300),
                            textAlign: TextAlign.center,
                          ),
                          verticalSpaceMedium,
                          _isLoading2
                              ? Center(
                                  child: AdaptiveCircularProgressIndicator())
                              : SizedBox(
                                  width: screenWidthPercentage(context,
                                      percentage: .9),
                                  height: 50,
                                  child: appButton(
                                      context: context,
                                      width: 20,
                                      height: 20,
                                      title: 'Submit',
                                      titleColour:
                                          AdaptiveTheme.primaryColor(context),
                                      onPressed: () {
                                        enterOtp(uuID, context);
                                      },
                                      borderColor:
                                          AdaptiveTheme.primaryColor(context),
                                      borderRadius: 10),

                                  /*RoundButton(
                                      title: 'Submit',
                                      onPressed: () {
                                        enterOtp(uuID, context);
                                      },
                                      color: AppTheme.primaryColor),*/
                                )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
