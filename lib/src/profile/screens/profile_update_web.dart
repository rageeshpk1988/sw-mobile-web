import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../../adaptive/adaptive_circular_progressInd.dart';

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
import '../../../widgets/web_banner.dart';
import '../../../widgets/web_bottom_bar.dart';

class ProfileUpdateScreenWeb extends StatefulWidget {
  static String routeName = '/web-profile-update';

  @override
  _ProfileUpdateScreenWebState createState() => _ProfileUpdateScreenWebState();
}

class _ProfileUpdateScreenWebState extends State<ProfileUpdateScreenWeb> {
  final _formKey = GlobalKey<FormState>();
  var scaffoldKey = GlobalKey<ScaffoldState>();
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
            .ackSuccessAlert(context, 'SUCCESS!!!', 'Profile Udpated!');
        Navigator.of(context).pop();
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      await Dialogs().ackAlert(context, 'An error occured', error.toString());
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
        ? AppTheme.lightTheme.textTheme.bodySmall!.copyWith(fontSize: 15)
        : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
            .copyWith(fontWeight: FontWeight.w400);
    Function parentRefreshHandler =
        ModalRoute.of(context)!.settings.arguments as Function;

    List<Widget> _items = [
      //List[0]
      ProfileImagePicker(_loginResponse.b2cParent!.profileImage!, saveImage),
      //List[1] //NAME
      TextFormField(
        enabled: _isLoading ? false : true,
        inputFormatters: [
          LengthLimitingTextInputFormatter(50),
          FilteringTextInputFormatter.deny(RegExp(GlobalVariables.regExpEmoji)),
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
      //List[2] EMAIL
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
      //List[3]//LOCATION PICKER
      UserLocationPicker(_defaultCountry, _defaultState, _defaultCity,
          updateLocation, _isLoading ? false : true),
      //LOCATION PICKER
      //List[4] //PINCODE
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
      //PINCODE
      //List[5]//UPDATE BUTTON
      SizedBox(
        width: screenWidthPercentage(context,
            percentage: screenWidth(context) > 800
                ? .12
                : screenWidth(context) > 400
                    ? 0.20
                    : 0.40),
        height: screenHeight(context) *
            (screenWidth(context) > 800
                ? 0.05
                : screenWidth(context) > 400
                    ? 0.03
                    : 0.05),
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
      ),
      //UPDATE BUTTON
    ];
    Widget _bodyWidgetSmall() {
      return Padding(
        padding: EdgeInsets.all(screenWidth(context) >= 400 ? 40.0 : 0.0),
        child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Column(children: [
              _items[0],
              const SizedBox(height: 5),
              _items[1],
              const SizedBox(height: 10),
              _items[2],
              const SizedBox(height: 10),
              _items[3],
              const SizedBox(height: 10),
              _items[4],
              const SizedBox(height: 10),
              Divider(thickness: 1),
              if (screenWidth(context) >= 400) const SizedBox(height: 10),
              _items[5],
            ])),
      );
    }

    Widget _bodyWidget() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  _items[0],
                  const SizedBox(width: 15),
                  //NAME
                  SizedBox(
                    width: screenWidth(context) * 0.285,
                    child: _items[1],
                  ),
                  //NAME
                  const SizedBox(width: 15),
                  //EMAIL
                  SizedBox(
                    width: screenWidth(context) * 0.285,
                    child: _items[2],
                  ),
                  //EMAIL
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 113.0),
                    child: SizedBox(
                      width: screenWidth(context) * 0.58,
                      child: _items[3],
                    ),
                  ),
                ],
              ),

              verticalSpaceSmall,
              //PINCODE
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 113.0),
                    child: SizedBox(
                      width: screenWidth(context) * 0.58,
                      child: _items[4],
                    ),
                  ),
                ],
              ),
              verticalSpaceMedium,
              Divider(thickness: 1),
              _isLoading
                  ? Center(child: AdaptiveCircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.only(left: 450.0),
                      child: _items[5],
                    )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      endDrawer: WebBannerDrawer(),
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
                    'Profile Update',
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
              height: screenHeight(context) * 0.98,
              child: _isLoading == false
                  ? screenWidth(context) > 800
                      ? _bodyWidget()
                      : _bodyWidgetSmall()
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
