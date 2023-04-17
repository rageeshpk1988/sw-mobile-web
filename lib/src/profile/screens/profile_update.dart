import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../adaptive/adaptive_custom_appbar.dart';
import '../../../adaptive/adaptive_theme.dart';
import '../../../helpers/app_info.dart';

import '../../../helpers/global_variables.dart';
import '../../../src/models/b2cparent.dart';
import '../../../src/providers/user.dart';
import '../../../util/app_theme_cupertino.dart';
import '../../../util/dialogs.dart';
import '../../../src/models/city_name.dart';
import '../../../src/models/country_name.dart';
import '../../../src/models/login_response.dart';
import '../../../src/models/state_name.dart';
import '../../../src/providers/auth.dart';
import '../../../helpers/global_validations.dart';
import '../../../util/app_theme.dart';
import '../../../util/ui_helpers.dart';
import '../../../widgets/profile_image_picker.dart';

import '../../../widgets/user_location_picker.dart';

class ProfileUpdateScreen extends StatefulWidget {
  static String routeName = '/profile-update';

  @override
  _ProfileUpdateScreenState createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _pincodeFocusNode = FocusNode();
  //final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _pincodeController = TextEditingController();
  CountryName? _defaultCountry;
  StateName? _defaultState;
  CityName? _defaultCity;

  CountryName? _selectdCountry;
  StateName? _selectedState;
  CityName? _selectedCity;

  var _isInIt = true;
  var _isLoading = false;
  bool _deleteAgree = false;
  late LoginResponse _loginResponse;
  File _selectedImage = File('file.txt'); //dumm file name to avoid null issue
  final Map<String, String> _dataFields = {
    //'adStatus': '',
    //'countryCode': '',
    //'docType': '',
    //'documentNumber': '',
    //'kycStatus': '',
    //'parentDocumentTypeId': '',
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
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _pincodeFocusNode.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _pincodeController.dispose();
    // _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(_onOnFocusNodeEvent);
    _emailFocusNode.addListener(_onOnFocusNodeEvent);
    _pincodeFocusNode.addListener(_onOnFocusNodeEvent);
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
      _nameController.text = _loginResponse.b2cParent!.name;
      _emailController.text = _loginResponse.b2cParent!.emailID;
      _pincodeController.text = _loginResponse.b2cParent!.pinCode!;
      if (_loginResponse.b2cParent != null) {
        if (_loginResponse.b2cParent!.countryID != '') {
          _defaultCountry = CountryName(
              countryID: _loginResponse.b2cParent!.countryID!,
              countryName: _loginResponse.b2cParent!.country!);
        }
        if (_loginResponse.b2cParent!.stateID != '') {
          _defaultState = StateName(
              stateID: int.parse(_loginResponse.b2cParent!.stateID!),
              stateName: _loginResponse.b2cParent!.state!);
        }
        if (_loginResponse.b2cParent!.locationID != '') {
          _defaultCity = CityName(
              cityID: _loginResponse.b2cParent!.locationID!,
              cityName: _loginResponse.b2cParent!.location!);
        }
        updateLocation(
            _defaultCountry == null ? null : _defaultCountry!,
            _defaultState == null ? null : _defaultState!,
            _defaultCity == null ? null : _defaultCity!);
      }

      setState(() {
        _isLoading = false;
      });
      _isInIt = false;
      super.didChangeDependencies();
    }
  }

  Future<void> _submit(Function parentRefreshHandler) async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
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
    B2CParent parent = B2CParent(
      parentID: _loginResponse.b2cParent!.parentID,
      name: _dataFields['name']!,
      emailID: _dataFields['email']!,
      countryID: _selectdCountry!.countryID,
      stateID: _selectedState!.stateID,
      locationID: _selectedCity!.cityID,
      pinCode: _dataFields['pin'],
    );
    try {
      var _inserted = await Provider.of<User>(context, listen: false)
          .parentProfileAddUpdate(
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
          parentRefreshHandler();
          setState(() {
            _isLoading = false;
          });
        }

        await Dialogs()
            .ackSuccessAlert(context, 'SUCCESS!!!', 'Profile Updated!');
        Navigator.of(context).pop();
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      await Dialogs().ackAlert(context, 'An error occured', error.toString());
    }
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    //The API request is not in standard object format, its a combination of many values
    //Build the object

    try {
      var _inserted = await Provider.of<Auth>(context, listen: false)
          .deleteAccount(_loginResponse.b2cParent!.parentID,_loginResponse.mobileNumber
         );
      if (_inserted) {
        //Refreshing the local storage . this needs to be rechecked for a better option
         // parentRefreshHandler();
          setState(() {
            _isLoading = false;
          });

       var logout = await Provider.of<Auth>(context,listen: false).logout();
       if(logout == true)
         {
           Navigator.of(context).pop();
           Navigator.of(context).pop();
         }



      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      await Dialogs().ackAlert(context, '', error.toString());
    }
  }

  void updateLocation(
      CountryName? countryName, StateName? stateName, CityName? cityName) {
    setState(() {
      _selectdCountry = countryName;
      _selectedState = stateName;
      _selectedCity = cityName;
    });
  }

  void saveImage(File selectedImage) {
    setState(() {
      _selectedImage = selectedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _textViewStyle = kIsWeb || Platform.isAndroid
        ? AppTheme.lightTheme.textTheme.bodySmall!.copyWith(fontSize: 15,fontWeight: FontWeight.w300)
        : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
            .copyWith(fontWeight: FontWeight.w300);
    Function parentRefreshHandler =
        ModalRoute.of(context)!.settings.arguments as Function;



    Future<Object?> _showAccountDeletionPopup() async {
      _deleteAgree = false;
      return await showDialog(
        builder: (context) {
          return StatefulBuilder(builder: (context,setState){
            return  Dialog(
              insetPadding: EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: Text(
                          "What to know before deleting your SchoolWizard account",
                          style: Platform.isIOS
                              ? AppThemeCupertino
                              .lightTheme.textTheme.navTitleTextStyle
                              .copyWith(
                              fontSize: 16, fontWeight: FontWeight.w700)
                              : AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                              fontSize: 16, fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        height: 19,
                      ),
                      /* Text(
                    "Why it is important?",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: HexColor.fromHex('#D8015F')),
                    textAlign: TextAlign.start,
                  ),
                  verticalSpaceSmall,*/
                      RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          style: Platform.isIOS
                              ? AppThemeCupertino
                              .lightTheme.textTheme.navTitleTextStyle
                              .copyWith(
                              fontSize: 14, fontWeight: FontWeight.w300)
                              : AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                              fontSize: 14, fontWeight: FontWeight.w300),
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Account deletion will cancel existing subscription plans:',
                                style: TextStyle(fontWeight: FontWeight.bold)),

                          ],
                        ),
                      ),
                      //verticalSpaceTiny,
                      RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          style: Platform.isIOS
                              ? AppThemeCupertino
                              .lightTheme.textTheme.navTitleTextStyle
                              .copyWith(
                              fontSize: 12, fontWeight: FontWeight.w300)
                              : AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                              fontSize: 12, fontWeight: FontWeight.w300),
                          children: <TextSpan>[
                            TextSpan(
                                text: "If you delete the account during a subscription period, all existing subscription plans will be terminated, their validity will not be extended, and a refund will not be available.",
                                style: TextStyle(fontWeight: FontWeight.normal)),

                          ],
                        ),
                      ),
                      verticalSpaceTiny,
                      //verticalSpaceTiny,
                      RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          style: Platform.isIOS
                              ? AppThemeCupertino
                              .lightTheme.textTheme.navTitleTextStyle
                              .copyWith(
                              fontSize: 14, fontWeight: FontWeight.w300)
                              : AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                              fontSize: 14, fontWeight: FontWeight.w300),
                          children: <TextSpan>[
                            TextSpan(
                                text: "Deleting your account will delete all data instantly:",
                                style: TextStyle(fontWeight: FontWeight.bold)),

                          ],
                        ),
                      ),
                      //verticalSpaceTiny,
                      RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          style: Platform.isIOS
                              ? AppThemeCupertino
                              .lightTheme.textTheme.navTitleTextStyle
                              .copyWith(
                              fontSize: 12, fontWeight: FontWeight.w300)
                              : AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                              fontSize: 12, fontWeight: FontWeight.w300),
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Deleting your account will delete all your personal information, including your name, email address, profiles, and any other attributes you might have,instantly.',
                                style: TextStyle(fontWeight: FontWeight.normal)),

                          ],
                        ),
                      ),
                      verticalSpaceTiny,
                      const SizedBox(
                        height: 7,
                      ),
                      verticalSpaceSmall,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: SizedBox(
                              width: 10,
                              height: 10,
                              child: Checkbox(
                                value: _deleteAgree,
                                fillColor: MaterialStateProperty.all(
                                    AdaptiveTheme.primaryColor(context)),
                                onChanged:  (value) {
                                  setState(() {
                                    _deleteAgree = value ?? false;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Text(
                           'I understand and want to delete my account.',
                           style: Platform.isIOS
                               ? AppThemeCupertino
                               .lightTheme.textTheme.navTitleTextStyle
                               .copyWith(
                               fontSize: 14, fontWeight: FontWeight.w500)
                               : AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                               fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      verticalSpaceSmall,
                      Center(
                        child: Container(
                            width: double.infinity,
                            child: appButton(
                              context: context,
                              width: 20,
                              height: 35,
                              title: 'Continue',
                              titleColour: !_deleteAgree
                                  ? Colors.grey
                                  : AdaptiveTheme.primaryColor(context),
                              borderColor: !_deleteAgree
                                  ? Colors.grey
                                  : AdaptiveTheme.primaryColor(context),
                              onPressed: _deleteAgree ? () async {
                                _deleteAccount();
                                Navigator.of(context).pop();
                              }:(){},
                            )),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Container(
                            width: double.infinity,
                            child: appButton(
                              context: context,
                              width: 20,
                              height: 35,
                              title: 'Cancel',
                              titleColour: AdaptiveTheme.secondaryColor(context),
                              borderColor: AdaptiveTheme.secondaryColor(context),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        }, context: context


      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AdaptiveCustomAppBar(
        showShopifyHomeButton: false,
        showShopifyCartButton: false,
        showKycButton: false,
        showProfileButton: false,
        showHamburger: false,
        scaffoldKey: null,
        adResponse: null,
        loginResponse: null,
        updateHandler: null,
        title: 'Profile Update',
        showMascot: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  ProfileImagePicker(
                      _loginResponse.b2cParent!.profileImage!, saveImage),
                  const SizedBox(height: 10),
                  //NAME
                  TextFormField(
                    enabled: _isLoading ? false : true,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(50),
                      FilteringTextInputFormatter.deny(
                          RegExp(GlobalVariables.regExpEmoji)),
                    ],
                    style: _textViewStyle,
                    decoration: AdaptiveTheme.textFormFieldDecoration(
                        context, 'Name', _nameFocusNode),
                    textInputAction: TextInputAction.next,
                    focusNode: _nameFocusNode,
                    controller: _nameController,
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
                      _dataFields['name'] = value!;
                    },
                  ),
                  //NAME
                  verticalSpaceSmall,
                  //EMAIL
                  TextFormField(
                    enabled: _isLoading ? false : true,
                    style: _textViewStyle,
                    decoration: AdaptiveTheme.textFormFieldDecoration(
                        context, 'Email', _emailFocusNode),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(320),
                    ],
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: _emailFocusNode,
                    validator: (value) {
                      if (!GlobalValidations.validateEmail(value!)) {
                        return 'Invalid email!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _dataFields['email'] = value!;
                    },
                  ),
                  //EMAIL
                  verticalSpaceSmall,
                  UserLocationPicker(_defaultCountry, _defaultState,
                      _defaultCity, updateLocation, _isLoading ? false : true),
                  verticalSpaceSmall,
                  //PINCODE
                  TextFormField(
                    style: _textViewStyle,
                    enabled: _isLoading ? false : true,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6),
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    //  style: TextStyle(color: Colors.black),
                    decoration: AdaptiveTheme.textFormFieldDecoration(
                        context, 'Pincode', _pincodeFocusNode),

                    controller: _pincodeController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    focusNode: _pincodeFocusNode,
                    // onFieldSubmitted: (_) {
                    //   FocusScope.of(context).requestFocus(_emailFocusNode);
                    // },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please provide the area pincode';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _dataFields['pin'] = value!;
                    },
                  ),
                  verticalSpaceMedium,
                  _isLoading
                      ? Center(child: AdaptiveCircularProgressIndicator())
                      : Column(
                    mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                              width: screenWidthPercentage(context, percentage: .9),
                              height: 50,
                              child: appButton(
                                context: context,
                                width: 20,
                                height: 20,
                                title: 'Update',
                                titleColour: AdaptiveTheme.primaryColor(context),
                                onPressed: () => _submit(parentRefreshHandler),
                                borderColor: AdaptiveTheme.primaryColor(context),
                                //borderRadius: 20
                              ),
                              // child: RoundButton(
                              //     color: AppTheme.primaryColor,
                              //     title: 'Update',
                              //     onPressed: () {
                              //       _submit(parentRefreshHandler);
                              //     }),
                            ),
                          SizedBox(height: 40),
                          if(Platform.isIOS)
                            if(!_isLoading)
                          InkWell(
                            child: Text(
                              "Delete Account",
                              style:  kIsWeb || Platform.isAndroid
                                  ? AppTheme.lightTheme.textTheme.bodySmall!.copyWith(fontSize: 15,fontWeight: FontWeight.w300)
                                  : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
                                  .copyWith(color: Colors.red,fontWeight: FontWeight.w500,decoration: TextDecoration.underline),
                            ),
                            onTap: () {
                              //TODO: continue from here
                              _showAccountDeletionPopup();
                            },
                          ),
                          SizedBox(height:40),
                        ],
                      )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
