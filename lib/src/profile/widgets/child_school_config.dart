import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dropdown_search/dropdown_search.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../helpers/global_variables.dart';
import '/src/models/login_response.dart';
import '/src/providers/auth.dart';
import '/util/app_theme_cupertino.dart';

import '../../../adaptive/adaptive_theme.dart';
import '/util/date_util.dart';
import '../../../../src/models/child.dart';
import '../../../util/app_theme.dart';
import '../../../widgets/profile_image_picker.dart';
import '../../../../src/models/parent_releation.dart';
import '../../../../src/models/school.dart';
import '../../../../src/models/school_board.dart';
import '../../../../src/models/school_division.dart';
import '../../../../src/providers/school_config.dart';
import '../../../../widgets/user_location_picker.dart';
import '../../models/city_name.dart';
import '../../models/state_name.dart';
import '../../models/country_name.dart';

import '../../../util/ui_helpers.dart';

class ChildSchoolConfig extends StatefulWidget {
  final Child? child;
  final Function updateHandler;
  final Function imageHandler;
  final GlobalKey formKey;
  final bool enable;
  ChildSchoolConfig(
    this.child,
    this.updateHandler,
    this.imageHandler,
    this.formKey,
    this.enable,
  );
  @override
  State<ChildSchoolConfig> createState() => _ChildSchoolConfigState();
}

class _ChildSchoolConfigState extends State<ChildSchoolConfig> {
  final Map<String, String> _dataFields = {
    'name': '',
    'dob': '',
    'tempDivision': '',
    'tempSchoolName': '',
  };
  var _isInIt = true;
  bool _isLoading = false;
  File _selectedImage = File('file.txt'); //dummy file name to avoid null issue

  CountryName? _defaultCountry;
  StateName? _defaultState;
  CityName? _defaultCity;
  String? _defaultProfileImage;

  CountryName? _selectdCountry;
  StateName? _selectedState;
  CityName? _selectedCity;

  String? _selectedGender;
  School? _selectedSchool;
  SchoolBoard? _selectedBoard;
  SchoolDivision? _selectedDivison;
  DivisionBySchoolList? _selectedDivisionBySchoolList;
  ParentReleation? _selectedRelation;

  List<School>? _schoolList;
  List<SchoolBoard>? _boardList;
  List<SchoolDivision>? _divisionList = [];
  List<DivisionBySchoolList>? _divisionBySchoolList = [];
  List<ParentReleation>? _relationList;
  final _nameFocusNode = FocusNode();
  final _dobFocusNode = FocusNode();
  final _divisionFocusNode = FocusNode();
  final _tempSchoolFocusNode = FocusNode();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _otherSchoolController = TextEditingController();
  final _divisionController = TextEditingController();
  final _genderFocusNode = FocusNode();
  final _schoolFocusNode = FocusNode();
  final _boardFocusNode = FocusNode();
  final _classFocusNode = FocusNode();
  final _relationFocusNode = FocusNode();
  late LoginResponse loginResponse;
  @override
  void dispose() {
    _nameFocusNode.dispose();
    _dobFocusNode.dispose();
    _divisionFocusNode.dispose();
    _tempSchoolFocusNode.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _otherSchoolController.dispose();
    _divisionController.dispose();
    _genderFocusNode.dispose();
    _schoolFocusNode.dispose();
    _boardFocusNode.dispose();
    _classFocusNode.dispose();
    _relationFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(_onOnFocusNodeEvent);
    _genderFocusNode.addListener(_onOnFocusNodeEvent);
    _schoolFocusNode.addListener(_onOnFocusNodeEvent);
    _boardFocusNode.addListener(_onOnFocusNodeEvent);
    _classFocusNode.addListener(_onOnFocusNodeEvent);
    _relationFocusNode.addListener(_onOnFocusNodeEvent);
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
      loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
      if (widget.child != null) {
        _dataFields['name'] = widget.child!.name;
        _dataFields['dob'] = widget.child!.dob!;
        // _dataFields['tempDivision'] = widget.child!.tempDivision == null
        //     ? ''
        //     : widget.child!.tempDivision;
        _dataFields['tempDivision'] =
            widget.child!.division == null ? '' : widget.child!.division!;

        _selectedGender = widget.child!.gender;
        _nameController.text = widget.child!.name;

        //format dateofbirth
        _dobController.text = DateFormat('dd-MM-yyyy')
            .format(DateFormat('yyyy-MM-dd').parse(widget.child!.dob!));

        //format dateofbirth

        _defaultCountry = CountryName(
            countryID: widget.child!.countryID,
            countryName: widget.child!.country!);
        _selectdCountry = _defaultCountry;
        _defaultState = StateName(
          stateID: widget.child!.stateId,
          stateName: widget.child!.state,
        );
        _selectedState = _defaultState;
        _defaultCity = CityName(
            cityID: widget.child!.cityId, cityName: widget.child!.location!);
        _selectedCity = _defaultCity;

        _selectedSchool = School(
            schoolId: widget.child!.schoolId,
            schoolName: widget.child!.schoolName!,
            schoolType: widget.child!.schoolType);

        Provider.of<SchoolConfig>(context, listen: false)
            .fetchSchoolBoard(_selectdCountry!.countryID)
            .then((boardValue) {
          _boardList = boardValue;
          Provider.of<SchoolConfig>(context, listen: false)
              .fetchSchools(_selectedCity!.cityID)
              .then((schoolValue) {
            _schoolList = schoolValue;
            _selectedSchool!.schoolType = _schoolList!
                .firstWhere(
                    (element) => element.schoolId == _selectedSchool!.schoolId)
                .schoolType;
            Provider.of<SchoolConfig>(context, listen: false)
                .fetchDivsionAndParentRelation(_selectedSchool!)
                .then((divAndRelationValue) {
              setState(() {
                // _boardList = boardValue;
                _selectedBoard = SchoolBoard(
                    boardId: widget.child!.boardId!,
                    board: _boardList!
                        .firstWhere((element) =>
                            element.boardId == widget.child!.boardId)
                        .board);
                // _schoolList = schoolValue;

                // _divisionList =  divAndRelationValue.schoolDivisionList;
                if (divAndRelationValue.divisionBySchoolList!.isNotEmpty) {
                  _divisionBySchoolList =
                      divAndRelationValue.divisionBySchoolList;
                  //TODO:: this needs to be changed B2C-494
                  _selectedDivisionBySchoolList = DivisionBySchoolList(
                      divisionMappedId: 0,
                      divisionMapped:
                          '${widget.child!.className!}-${widget.child!.division}');
                } else {
                  _divisionList = divAndRelationValue.schoolDivisionList;
                  _selectedDivison =
                      SchoolDivision(division: widget.child!.className!);
                }
                // _selectedDivison =
                //     SchoolDivision(division: widget.child!.className!);
                _relationList = divAndRelationValue.parentReleationList;
                _selectedRelation = ParentReleation(
                    relationID: widget.child!.relationId,
                    relation: widget.child!.relation!);

                Future.delayed(
                    Duration.zero, () => _invokeParentUpdateHandler());
                setState(() {
                  _isLoading = false;
                });
              });
            });
          });
        });

        // _otherSchoolController.text = widget.child!.tempSchoolName == null
        //     ? ''
        //     : widget.child!.tempSchoolName;
        _divisionController.text = widget.child!.division!;

        _defaultProfileImage =
            widget.child!.imageUrl == null ? '' : widget.child!.imageUrl!;
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

  void updateLocation(
      CountryName? countryName, StateName? stateName, CityName? cityName) {
    setState(() {
      _selectdCountry = countryName;
      _selectedState = stateName;
      _selectedCity = cityName;
      _selectedSchool = null;
      if (_selectedCity != null) {
        _loadSchools();
      }
      if (_selectdCountry != null &&
          _selectedState != null &&
          _selectedCity != null) {
        _loadBoards();
      }
    });
  }

  void saveImage(File selectedImage) {
    setState(() {
      _selectedImage = selectedImage;
    });
    widget.imageHandler(_selectedImage);
  }

  Future<void> _loadBoards() async {
    _boardList = await Provider.of<SchoolConfig>(context, listen: false)
        .fetchSchoolBoard(_selectdCountry!.countryID);
  }

  Future<void> _loadSchools() async {
    _schoolList = await Provider.of<SchoolConfig>(context, listen: false)
        .fetchSchools(_selectedCity!.cityID);
  }

  Future<void> _loadDivisionAndRelation() async {
    DivisionAndParentRelation divisionAndReleation =
        await Provider.of<SchoolConfig>(context, listen: false)
            .fetchDivsionAndParentRelation(_selectedSchool!);
    _divisionList = divisionAndReleation.schoolDivisionList;
    _relationList = divisionAndReleation.parentReleationList;
    _divisionBySchoolList = divisionAndReleation.divisionBySchoolList;
    setState(() {});
  }

  Future<List<String>> getGenderList(String filter) async {
    return [
      "Male",
      "Female",
      "Other",
    ];
  }

  Future<List<School>> getSchools(String filter) async {
    //return _schoolList!;
    if (_schoolList == null) return [];
    if (filter == '') {
      return _schoolList!;
    }
    return _schoolList!
        .where((element) =>
            element.schoolName.toLowerCase().contains(filter.toLowerCase()))
        .toList();
  }

  Future<List<SchoolBoard>> getBoards(String filter) async {
    //return _boardList!;
    if (_boardList == null) return [];
    if (filter == '') {
      return _boardList!;
    }
    return _boardList!
        .where((element) =>
            element.board.toLowerCase().contains(filter.toLowerCase()))
        .toList();
  }

  Future<List<DivisionBySchoolList>> getDivsionBySchoolList(
      String filter) async {
    //return _divisionList!;
    if (_divisionBySchoolList == null) return [];
    if (filter == '') {
      return _divisionBySchoolList!;
    }
    return _divisionBySchoolList!
        .where((element) =>
            element.divisionMapped.toLowerCase().contains(filter.toLowerCase()))
        .toList();
  }

  Future<List<SchoolDivision>> getDivsions(String filter) async {
    //return _divisionList!;
    if (_divisionList == null) return [];
    if (filter == '') {
      return _divisionList!;
    }
    return _divisionList!
        .where((element) =>
            element.division.toLowerCase().contains(filter.toLowerCase()))
        .toList();
  }

  Future<List<ParentReleation>> getRelations(String filter) async {
    //return _relationList!;
    if (_relationList == null) return [];
    if (filter == '') {
      return _relationList!;
    }
    return _relationList!
        .where((element) =>
            element.relation.toLowerCase().contains(filter.toLowerCase()))
        .toList();
  }

  void _invokeParentUpdateHandler() {
    widget.updateHandler(
      _selectdCountry,
      _selectedState,
      _selectedCity,
      _selectedGender,
      _selectedSchool,
      _selectedBoard,
      _selectedDivison,
      _selectedDivisionBySchoolList,
      _selectedRelation,
      _dataFields,
    );
  }

  @override
  Widget build(BuildContext context) {
    // _invokeParentUpdateHandler();
    DateTime _pastDOB = DateUtil.calculatePastDate(3, 0, 0);
    DateTime _maxDOB = DateUtil.calculatePastDate(17, 0, 0);
    TextStyle _textViewStyle = kIsWeb || Platform.isAndroid
        ? AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontSize: 15, fontWeight: FontWeight.w300)
        : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
            .copyWith(fontSize: 15, fontWeight: FontWeight.w300);
    TextStyle _dropdownTextViewStyle = _textViewStyle;
    TextStyle _dropdownLabelStyle = _textViewStyle.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w200,
        letterSpacing: 0.0,
        color: Colors.grey.shade900);

    return _isLoading
        ? Center(child: const Text(''))
        : Column(
            children: [
              ProfileImagePicker(_defaultProfileImage, saveImage),
              //HEADER
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 1.0),
                      child: Column(
                        children: [
                          //NAME
                          TextFormField(
                            enabled: widget.enable,
                            style: _textViewStyle,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                              FilteringTextInputFormatter.deny(
                                  RegExp(GlobalVariables.regExpEmoji)),
                              FilteringTextInputFormatter.allow(
                                  RegExp(GlobalVariables.regExpAlphbets))
                            ],
                            decoration: AdaptiveTheme.textFormFieldDecoration(
                                context, 'Name', _nameFocusNode),
                            textInputAction: TextInputAction.next,
                            focusNode: _nameFocusNode,
                            controller: _nameController,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_dobFocusNode);
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Provide child's name";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _dataFields['name'] = value!;
                            },
                          ),
                          //NAME
                          const SizedBox(height: 5),
                          //DOB
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            //height: 60,
                            child: TextFormField(
                              enabled: widget.enable,
                              style: _textViewStyle,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Date of Birth',
                                errorStyle: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w300),
                                labelStyle: kIsWeb || Platform.isAndroid
                                    ? AppTheme.lightTheme.textTheme.bodySmall!
                                        .copyWith(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w200,
                                            color: _dobFocusNode.hasFocus
                                                ? AdaptiveTheme.primaryColor(
                                                    context)
                                                : Colors.grey.shade900)
                                    : AppThemeCupertino
                                        .lightTheme.textTheme.navTitleTextStyle
                                        .copyWith(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w300),
                                focusedBorder:
                                    AdaptiveTheme.outlineInputBorder(context),
                                border:
                                    AdaptiveTheme.outlineInputBorder(context),
                                suffixIcon: const Icon(Icons.date_range,
                                    color: AppTheme.primaryColor),
                              ),
                              textInputAction: TextInputAction.next,
                              focusNode: _dobFocusNode,
                              controller: _dobController,
                              onTap: () async {
                                DateTime date = DateTime(1900);
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());

                                date = (await showDatePicker(
                                  context: context,
                                  initialDate: _pastDOB, // DateTime.now(),
                                  firstDate: _maxDOB,
                                  lastDate: _pastDOB,
                                  helpText:
                                      'SELECT DATE OF BIRTH', // DateTime.now(),
                                  builder: (context, child) {
                                    return Theme(
                                      data: AppTheme.lightTheme,
                                      child: child!,
                                    );
                                  },
                                ))!;
                                _dobController.text =
                                    DateFormat('dd-MM-yyyy').format(date);
                              },
                              onFieldSubmitted: (_) {
                                // FocusScope.of(context)
                                //     .requestFocus(_mobileNumberFocusNode);
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Provide the date of birth';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _dataFields['dob'] = value!;
                              },
                            ),
                          ),
                          //DOB
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              //HEADER
              const SizedBox(height: 5),
              //GENDER
              DropdownSearch<String>(
                enabled: widget.enable,
                focusNode: _genderFocusNode,
                dropdownBuilder: (context, selectedItem) {
                  if (selectedItem != null)
                    return Text(selectedItem, style: _dropdownTextViewStyle);
                  else
                    return Text('Gender', style: _dropdownLabelStyle);
                },

                validator: (v) => v == null ? 'Select the gender' : null,
                mode: Mode.DIALOG,
                onFind: (String? filter) => getGenderList(filter!),
                compareFn: (item, selectedValue) => item == selectedValue,
                dropdownSearchDecoration:
                    AdaptiveTheme.dropdownSearchDecoration(
                        context,
                        _selectedGender == null ? '' : 'Gender',
                        _genderFocusNode),
                popupItemBuilder: (context, item, isSelected) {
                  return dropDownSearchCustomPopup(context, item, isSelected);
                },
                searchFieldProps: dropdownSearchCustomsearchBox(context),

                selectedItem: _selectedGender,
                filterFn: (str, filter) =>
                    str!.toLowerCase().contains(filter!.toLowerCase()),
                onChanged: (data) {
                  setState(() {
                    _selectedGender = data;
                    _invokeParentUpdateHandler();
                  });
                },
                showSearchBox: true,
                showSelectedItems: true,
                // dropdownButtonBuilder: (_) => Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: const Icon(
                //     Icons.arrow_drop_down,
                //     size: 40,
                //     color: Colors.black,
                //   ),
                // ),
              ),
              //GENDER
              verticalSpaceSmall,
              //LOCATIONPICKER
              UserLocationPicker(_defaultCountry, _defaultState, _defaultCity,
                  updateLocation, widget.enable),
              //LOCATIONPICKER
              verticalSpaceSmall,
              //SCHOOL
              DropdownSearch<School>(
                enabled: widget.enable,
                dropdownBuilder: (context, selectedItem) {
                  if (selectedItem != null)
                    return Text(selectedItem.schoolName,
                        style: _dropdownTextViewStyle);
                  else
                    return Text(
                      'Choose your School',
                      style: _dropdownLabelStyle,
                    );
                },

                focusNode: _schoolFocusNode,
                validator: (v) => v == null ? 'Select the school' : null,
                mode: Mode.DIALOG,
                onFind: _selectedCity != null
                    ? (String? filter) => getSchools(filter!)
                    : null,
                compareFn: (item, selectedValue) =>
                    item?.schoolName == selectedValue?.schoolName,
                dropdownSearchDecoration:
                    AdaptiveTheme.dropdownSearchDecoration(
                        context,
                        _selectedSchool == null ? '' : 'School',
                        _schoolFocusNode),
                popupItemBuilder: (context, item, isSelected) {
                  return dropDownSearchCustomPopup(
                      context, item.schoolName, isSelected);
                },
                searchFieldProps: dropdownSearchCustomsearchBox(context),
                selectedItem: _selectedSchool,
                filterFn: (school, filter) => school!.filterByName(filter!),
                // errorBuilder: (context, searchEntry, exception) => Center(
                //     child: Text('Loading...', style: TextStyle(color: Colors.grey))),
                emptyBuilder: (context, searchEntry) => Center(
                    child: Text(
                  'Select the Location',
                  style: _dropdownLabelStyle,
                )),
                onChanged: (data) {
                  setState(() {
                    _selectedSchool = data;
                    if (widget.child == null) _selectedDivison = null;
                    _loadDivisionAndRelation();
                    _invokeParentUpdateHandler();
                  });
                },
                showSearchBox: true,
                showSelectedItems: true,
              ),
              //SCHOOL
              verticalSpaceSmall,

              if (_selectedSchool != null &&
                  _selectedSchool!.schoolName.toLowerCase() == 'others')
                //OTHER SCHOOL
                TextFormField(
                  enabled: widget.enable,
                  style: _textViewStyle,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                    FilteringTextInputFormatter.deny(
                      RegExp(GlobalVariables.regExpEmoji),
                    ),
                  ],
                  decoration: AdaptiveTheme.textFormFieldDecoration(
                      context, 'School', _tempSchoolFocusNode),
                  textInputAction: TextInputAction.next,
                  focusNode: _tempSchoolFocusNode,
                  controller: _otherSchoolController,
                  onFieldSubmitted: (_) {
                    //  FocusScope.of(context).requestFocus(_emailFocusNode);
                  },
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Please provide school name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _dataFields['tempSchoolName'] = value!;
                  },
                ),

              //OTHER SCHOOL
              if (_selectedSchool != null &&
                  _selectedSchool!.schoolName.toLowerCase() == 'others')
                verticalSpaceSmall,
              //BOARD
              DropdownSearch<SchoolBoard>(
                enabled: widget.enable,
                dropdownBuilder: (context, selectedItem) {
                  if (selectedItem != null)
                    return Text(selectedItem.board,
                        style: _dropdownTextViewStyle);
                  else
                    return Text('Board', style: _dropdownLabelStyle);
                },
                focusNode: _boardFocusNode,
                validator: (v) => v == null ? 'Select the board' : null,
                mode: Mode.DIALOG,
                onFind: _selectdCountry != null &&
                        _selectedState != null &&
                        _selectedCity != null
                    ? (String? filter) => getBoards(filter!)
                    : null,
                compareFn: (item, selectedValue) =>
                    item?.board == selectedValue?.board,
                dropdownSearchDecoration:
                    AdaptiveTheme.dropdownSearchDecoration(context,
                        _selectedBoard == null ? '' : 'Board', _boardFocusNode),
                popupItemBuilder: (context, item, isSelected) {
                  return dropDownSearchCustomPopup(
                      context, item.board, isSelected);
                },
                searchFieldProps: dropdownSearchCustomsearchBox(context),
                selectedItem: _selectedBoard,
                filterFn: (board, filter) => board!.filterByName(filter!),
                // errorBuilder: (context, searchEntry, exception) => Center(
                //     child: Text('Loading...', style: TextStyle(color: Colors.grey))),
                emptyBuilder: (context, searchEntry) => Center(
                    child: Text(
                  'Select your school',
                  style: _dropdownLabelStyle,
                )),
                onChanged: (data) {
                  setState(() {
                    _selectedBoard = data;
                    _invokeParentUpdateHandler();
                  });
                },
                showSearchBox: true,
                showSelectedItems: true,
              ),
              //BOARD
              if (!_divisionBySchoolList!.isEmpty) verticalSpaceSmall,
              //if divisionbyschoollist is not empty then show
              //divisionbyschoollist items in dropdown
              //and disable class and division
              //DIVISIONBYSCHOOLLIST
              if (!_divisionBySchoolList!.isEmpty)
                DropdownSearch<DivisionBySchoolList>(
                  enabled: widget.enable,
                  dropdownBuilder: (context, selectedItem) {
                    if (selectedItem != null)
                      return Text(selectedItem.divisionMapped.toUpperCase(),
                          style: _dropdownTextViewStyle);
                    else
                      return Text(
                        'Class',
                        style: _dropdownLabelStyle,
                      );
                  },
                  focusNode: _classFocusNode,
                  validator: (v) => v == null ? 'Select the class' : null,
                  mode: Mode.DIALOG,
                  onFind: _selectedSchool != null
                      ? (String? filter) => getDivsionBySchoolList(filter!)
                      : null,
                  compareFn: (item, selectedValue) =>
                      item?.divisionMapped == selectedValue?.divisionMapped,
                  dropdownSearchDecoration:
                      AdaptiveTheme.dropdownSearchDecoration(
                          context,
                          _selectedDivisionBySchoolList == null ? '' : 'Class',
                          _classFocusNode),
                  popupItemBuilder: (context, item, isSelected) {
                    return dropDownSearchCustomPopup(
                        context, item.divisionMapped, isSelected);
                  },
                  searchFieldProps: dropdownSearchCustomsearchBox(context),
                  selectedItem: _selectedDivisionBySchoolList,
                  filterFn: (division, filter) =>
                      division!.filterByName(filter!),
                  // errorBuilder: (context, searchEntry, exception) => Center(
                  //     child: Text('Loading...', style: TextStyle(color: Colors.grey))),
                  emptyBuilder: (context, searchEntry) => Center(
                      child: Text(
                    'Select your school',
                    style: _dropdownLabelStyle,
                  )),
                  onChanged: (data) {
                    setState(() {
                      _selectedDivisionBySchoolList = data;
                      _invokeParentUpdateHandler();
                    });
                  },
                  showSearchBox: true,
                  showSelectedItems: true,
                ),
              //DIVISIONBYSCHOOLLIST
              if (!_divisionList!.isEmpty) verticalSpaceSmall,
              //CLASS (object name is DIVISION)
              if (!_divisionList!.isEmpty)
                DropdownSearch<SchoolDivision>(
                  enabled: widget.enable,
                  dropdownBuilder: (context, selectedItem) {
                    if (selectedItem != null)
                      return Text(selectedItem.division.toUpperCase(),
                          style: _dropdownTextViewStyle);
                    else
                      return Text(
                        'Class',
                        style: _dropdownLabelStyle,
                      );
                  },
                  focusNode: _classFocusNode,
                  validator: (v) => v == null ? 'Select the class' : null,
                  mode: Mode.DIALOG,
                  onFind: _selectedSchool != null
                      ? (String? filter) => getDivsions(filter!)
                      : null,
                  compareFn: (item, selectedValue) =>
                      item?.division == selectedValue?.division,
                  dropdownSearchDecoration:
                      AdaptiveTheme.dropdownSearchDecoration(
                          context,
                          _selectedDivison == null ? '' : 'Class',
                          _classFocusNode),
                  popupItemBuilder: (context, item, isSelected) {
                    return dropDownSearchCustomPopup(
                        context, item.division, isSelected);
                  },
                  searchFieldProps: dropdownSearchCustomsearchBox(context),
                  selectedItem: _selectedDivison,
                  filterFn: (division, filter) =>
                      division!.filterByName(filter!),
                  // errorBuilder: (context, searchEntry, exception) => Center(
                  //     child: Text('Loading...', style: TextStyle(color: Colors.grey))),
                  emptyBuilder: (context, searchEntry) => Center(
                      child: Text('Select your class',
                          style: TextStyle(color: Colors.grey))),
                  onChanged: (data) {
                    setState(() {
                      _selectedDivison = data;
                      _invokeParentUpdateHandler();
                    });
                  },
                  showSearchBox: true,
                  showSelectedItems: true,
                ),
              //CLASS
              if (!_divisionList!.isEmpty) verticalSpaceSmall,
              //DIVISION
              if (!_divisionList!.isEmpty)
                TextFormField(
                  enabled: widget.enable,
                  style: _textViewStyle,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(3),
                    FilteringTextInputFormatter.deny(
                        RegExp(GlobalVariables.regExpEmoji)),
                  ],
                  decoration: AdaptiveTheme.textFormFieldDecoration(
                      context, 'Division', _divisionFocusNode),
                  textInputAction: TextInputAction.next,
                  focusNode: _divisionFocusNode,
                  controller: _divisionController,
                  onFieldSubmitted: (_) {
                    //  FocusScope.of(context).requestFocus(_emailFocusNode);
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please provide division';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _dataFields['tempDivision'] = value!;
                  },
                ),
              //DIVISION
              verticalSpaceSmall,
              //RELATION
              DropdownSearch<ParentReleation>(
                enabled: widget.enable,
                dropdownBuilder: (context, selectedItem) {
                  if (selectedItem != null)
                    return Text(selectedItem.relation,
                        style: _dropdownTextViewStyle);
                  else
                    return Text(
                      'Relation',
                      style: _dropdownLabelStyle,
                    );
                },
                focusNode: _relationFocusNode,
                validator: (v) => v == null ? 'Select the relationship' : null,
                mode: Mode.DIALOG,
                onFind: _selectedSchool != null
                    ? (String? filter) => getRelations(filter!)
                    : null,
                compareFn: (item, selectedValue) =>
                    item?.relation == selectedValue?.relation,
                dropdownSearchDecoration:
                    AdaptiveTheme.dropdownSearchDecoration(
                        context,
                        _selectedRelation == null ? '' : 'Relation',
                        _classFocusNode),
                popupItemBuilder: (context, item, isSelected) {
                  return dropDownSearchCustomPopup(
                      context, item.relation, isSelected);
                },
                searchFieldProps: dropdownSearchCustomsearchBox(context),
                selectedItem: _selectedRelation,
                filterFn: (relation, filter) => relation!.filterByName(filter!),
                // errorBuilder: (context, searchEntry, exception) => Center(
                //     child: Text('Loading...', style: TextStyle(color: Colors.grey))),
                emptyBuilder: (context, searchEntry) => Center(
                    child: Text(
                  'Select your school',
                  style: _dropdownLabelStyle,
                )),
                onChanged: (data) {
                  setState(() {
                    _selectedRelation = data;
                    _invokeParentUpdateHandler();
                  });
                },
                showSearchBox: true,
                showSelectedItems: true,
              ),
              //RELATION
            ],
          );
  }
}
