import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '/src/profile/widgets/child_school_config_web.dart';

import '../../../adaptive/adaptive_circular_progressInd.dart';

import '../../../adaptive/adaptive_theme.dart';
import '../../../helpers/app_info.dart';

import '../../../src/models/child.dart';
import '../../../src/models/login_response.dart';
import '../../../src/providers/auth.dart';
import '../../../src/providers/children.dart';
import '../../../util/dialogs.dart';
import '../../../src/models/city_name.dart';
import '../../../src/models/country_name.dart';
import '../../../src/models/state_name.dart';
import '../../../src/models/parent_releation.dart';
import '../../../src/models/school.dart';
import '../../../src/models/school_board.dart';
import '../../../src/models/school_division.dart';

import '../../../util/ui_helpers.dart';
import '../../../widgets/web_banner.dart';
import '../../../widgets/web_bottom_bar.dart';

//adding child details
class AddChildScreenWeb extends StatefulWidget {
  static String routeName = '/web-child-add';
  @override
  _AddChildScreenWebState createState() => _AddChildScreenWebState();
}

class _AddChildScreenWebState extends State<AddChildScreenWeb> {
  final _formKey = GlobalKey<FormState>();
  File _selectedImage = File('file.txt'); //dummy file name to avoid null issue
  var scaffoldKey = GlobalKey<ScaffoldState>();
  CountryName? _selectdCountry;
  StateName? _selectedState;
  CityName? _selectedCity;
  String? _selectedGender;
  School? _selectedSchool;
  SchoolBoard? _selectedBoard;
  SchoolDivision? _selectedDivision;
  DivisionBySchoolList? _selectedDivisionBySchoolList;
  ParentReleation? _selectedRelation;
  Map<String, String>? _selectedDataFields;

  var _isLoading = false;

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
    LoginResponse _loginResponse =
        Provider.of<Auth>(context, listen: false).loginResponse;

    //Build the object
    Child child = Child(
      boardId: _selectedBoard!.boardId,
      cityId: _selectedCity!.cityID,
      countryID: _selectdCountry!.countryID,
      dob: _selectedDataFields!['dob']!,
      gender: _selectedGender!,
      name: _selectedDataFields!['name']!,
      parentId: _loginResponse.b2cParent!.parentID,
      relationId: _selectedRelation!.relationID,
      relation: _selectedRelation!.relation,
      schoolId: _selectedSchool!.schoolName.toLowerCase() == 'others'
          ? 0
          : _selectedSchool!.schoolId,
      schoolType: _selectedSchool!.schoolType,
      // schoolType: _selectedSchool!.schoolName.toLowerCase() == 'others'
      //     ? 'tempSchool'
      //     : '',
      stateId: _selectedState!.stateID,
      tempDivision: _selectedDataFields!['tempDivision']!,
      tempSchoolName: _selectedSchool!.schoolName.toLowerCase() == 'others'
          ? _selectedDataFields!['tempSchoolName']
          : '',
      tempStandard:
          _selectedDivision == null ? '' : _selectedDivision!.division,
    );

    try {
      //TODO:: HERE ADDING THE DivisionBySchoolList as a separate parameter. It has to be changed
      //once the child model is clear, then will change into child object
      var _inserted = await Provider.of<Children>(context, listen: false)
          .childAddUpdate(child, _packageInfo.version, _selectedImage,
              _selectedDivisionBySchoolList);
      if (_inserted['success']) {
        bool _mobileValidated = await Provider.of<Auth>(context, listen: false)
            .validateMobileNumber(_loginResponse.mobileNumber);
        //Refreshing the local storage . this needs to be rechecked for a better option
        if (_mobileValidated) {
          parentRefreshHandler();
          setState(() {
            _isLoading = false;
          });
        }
        if (_inserted['message'].toString().trim() != '') {
          await Dialogs().ackAlert(context, 'Profile', _inserted['message']);
        } else {
          await Dialogs()
              .ackSuccessAlert(context, 'SUCCESS!!!', 'Added the Child!');
        }
        Navigator.of(context).pop();
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      await Dialogs().ackAlert(context, 'An error occured', error.toString());
    }
  }

  void updateConfig(
      CountryName? countryName,
      StateName? stateName,
      CityName? cityName,
      String? gender,
      School? school,
      SchoolBoard? board,
      SchoolDivision? division,
      DivisionBySchoolList? divisionBySchoolList,
      ParentReleation? relation,
      Map<String, String> dataFields) {
    setState(() {
      _selectdCountry = countryName;
      _selectedState = stateName;
      _selectedCity = cityName;
      _selectedGender = gender;
      _selectedSchool = school;
      _selectedBoard = board;
      _selectedDivision = division;
      _selectedDivisionBySchoolList = divisionBySchoolList;
      _selectedRelation = relation;
      _selectedDataFields = dataFields;
    });
  }

  void saveImage(File selectedImage) {
    setState(() {
      _selectedImage = selectedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    Function parentRefreshHandler =
        ModalRoute.of(context)!.settings.arguments as Function;

    Widget _bodyWidget() {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            // autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpaceSmall,
                //While adding the child , we need not pre-populate saved details
                ChildSchoolConfigWeb(null, updateConfig, saveImage, _formKey,
                    _isLoading ? false : true),
                verticalSpaceTiny,
                Divider(thickness: 1),
                Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth(context) > 800 ? 310 : 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isLoading
                          ? Center(child: AdaptiveCircularProgressIndicator())
                          : SizedBox(
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
                                title: 'Add Child',
                                titleColour:
                                    AdaptiveTheme.primaryColor(context),
                                onPressed: () => _submit(parentRefreshHandler),
                                borderColor:
                                    AdaptiveTheme.primaryColor(context),
                              ),
                            ),
                      verticalSpaceMedium,
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      endDrawer: WebBannerDrawer(),
      backgroundColor: Colors.white,
      key: scaffoldKey,
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
                    'Child Details',
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
              width: screenWidth(context) * 0.98,
              height: screenHeight(context) * 0.98,
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
