import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../adaptive/adaptive_theme.dart';
import '../src/models/city_name.dart';
import '../src/models/login_response.dart';
import '../src/models/state_name.dart';
import '../src/models/country_name.dart';
import '../src/providers/auth.dart';
import '../src/providers/user_location.dart';
import '../util/app_theme.dart';
import '../util/app_theme_cupertino.dart';
import '../util/ui_helpers.dart';

class UserLocationPicker extends StatefulWidget {
  final CountryName? defaultCountry;
  final StateName? defaultState;
  final CityName? defaultCity;
  final Function locationHandler;
  final bool enable;
  UserLocationPicker(
    this.defaultCountry,
    this.defaultState,
    this.defaultCity,
    this.locationHandler,
    this.enable,
  );
  @override
  State<UserLocationPicker> createState() => _UserLocationPickerState();
}

class _UserLocationPickerState extends State<UserLocationPicker> {
  var _isInIt = true;

  CountryName? _selectedCountry;
  StateName? _selectedState;
  CityName? _selectedCity;

  List<CountryName>? _countriesList;
  List<StateName>? _statesList;
  List<CityName>? _citiesList;

  final _countryFocusNode = FocusNode();
  final _stateFocusNode = FocusNode();
  final _cityFocusNode = FocusNode();
  late LoginResponse loginResponse;
  @override
  void initState() {
    super.initState();
    _countryFocusNode.addListener(_onOnFocusNodeEvent);
    _stateFocusNode.addListener(_onOnFocusNodeEvent);
    _cityFocusNode.addListener(_onOnFocusNodeEvent);
  }

  _onOnFocusNodeEvent() {
    setState(() {});
  }

  @override
  void dispose() {
    _countryFocusNode.dispose();
    _stateFocusNode.dispose();
    _cityFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      loginResponse = Provider.of<Auth>(context, listen: true).loginResponse;
      Provider.of<UserLocation>(context, listen: false)
          .fetchCountries()
          .then((value) {
        setState(() {
          _countriesList = value;
        });
      });
      _selectedCountry =
          widget.defaultCountry == null ? null : widget.defaultCountry;
      _selectedState = widget.defaultState == null ? null : widget.defaultState;
      _selectedCity = widget.defaultCity == null ? null : widget.defaultCity;
      if (_selectedCountry != null) {
        _loadStates();
        if (_selectedState != null) {
          _loadCities();
        }
      }
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

  Future<void> _loadStates() async {
    _statesList = await Provider.of<UserLocation>(context, listen: false)
        .fetchStateNames(_selectedCountry!.countryID);
  }

  Future<void> _loadCities() async {
    _citiesList =
        await Provider.of<UserLocation>(context, listen: false).fetchCityNames(
      _selectedCountry!.countryID,
      _selectedState!.stateID,
    );
  }

  Future<List<CountryName>> getCountries(String filter) async {
    if (_countriesList == null) return [];
    if (filter == '') {
      return await _countriesList!;
    }
    //Dialogs().ackAlert(context, 'title', '$filter ${_countriesList!.length}');

    return await _countriesList!
        .where((element) =>
            element.countryName.toLowerCase().contains(filter.toLowerCase()))
        .toList();
  }

  Future<List<StateName>> getStates(String filter) async {
    //return _statesList!;
    if (_statesList == null) return [];
    if (filter == '') {
      return await _statesList!;
    }
    return await _statesList!
        .where((element) =>
            element.stateName!.toLowerCase().contains(filter.toLowerCase()))
        .toList();
  }

  Future<List<CityName>> getCities(String filter) async {
    //return _citiesList!;
    if (_citiesList == null) return [];
    if (filter == '') {
      return await _citiesList!;
    }
    return await _citiesList!
        .where((element) =>
            element.cityName.toLowerCase().contains(filter.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _textViewStyle = kIsWeb || Platform.isAndroid
        ? AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontSize: 15, fontWeight: FontWeight.w300)
        : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
            .copyWith(fontSize: 15, fontWeight: FontWeight.w300);
    TextStyle _dropdownTextViewStyle = _textViewStyle;
    TextStyle _dropdownLabelStyle = _textViewStyle.copyWith(
        fontWeight: FontWeight.w200, letterSpacing: 0.0);
    return Column(
      children: [
        DropdownSearch<CountryName>(
          isFilteredOnline: true,
          enabled: widget.enable,
          dropdownBuilder: (context, selectedItem) {
            if (selectedItem != null)
              return Text(selectedItem.countryName,
                  style: _dropdownTextViewStyle);
            else
              return Text(
                'Choose your Country',
                style: _dropdownLabelStyle,
              );
          },
          focusNode: _countryFocusNode,
          validator: (v) => v == null ? 'Select your country' : null,
          mode: Mode.DIALOG,
          // filterFn: (country, filter) => country!.filterByName(filter!),
          itemAsString: (CountryName? c) => c!.countryName.toLowerCase(),
          onFind: (String? filter) async => await getCountries(filter!),

          compareFn: (item, selectedValue) =>
              item?.countryName.toLowerCase() ==
              selectedValue?.countryName.toLowerCase(),
          dropdownSearchDecoration: AdaptiveTheme.dropdownSearchDecoration(
              context,
              _selectedCountry == null ? '' : 'Country',
              _countryFocusNode),
          // errorBuilder: (context, searchEntry, exception) => Center(
          //     child: Text('Loading...', style: TextStyle(color: Colors.grey))),
          popupItemBuilder: (context, item, isSelected) {
            return dropDownSearchCustomPopup(
                context, item.countryName, isSelected);
          },
          searchFieldProps: dropdownSearchCustomsearchBox(context),
          selectedItem: _selectedCountry,

          emptyBuilder: (context, searchEntry) => Center(
            child: Text(
              'Loading countries',
              style: _dropdownLabelStyle,
              // style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          onChanged: (data) {
            setState(() {
              _selectedCountry = data;
              _selectedState = null;
              _selectedCity = null;
              _loadStates();
              widget.locationHandler(
                  _selectedCountry, _selectedState, _selectedCity);
            });
          },
          showSearchBox: true,
          showSelectedItems: true,
        ),
        //COUNTRYLIST
        verticalSpaceSmall,
        //STATELIST
        DropdownSearch<StateName>(
          enabled: widget.enable,
          dropdownBuilder: (context, selectedItem) {
            if (selectedItem != null)
              return Text(selectedItem.stateName!,
                  style: _dropdownTextViewStyle);
            else
              return Text(
                'Choose your State',
                style: _dropdownLabelStyle,
              );
          },
          focusNode: _stateFocusNode,
          validator: (v) => v == null ? 'Select your state' : null,
          mode: Mode.DIALOG,
          onFind: _selectedCountry != null
              ? (String? filter) => getStates(filter!)
              : null,
          compareFn: (item, selectedValue) =>
              item?.stateName == selectedValue?.stateName,

          dropdownSearchDecoration: AdaptiveTheme.dropdownSearchDecoration(
              context, _selectedState == null ? '' : 'State', _stateFocusNode),

          popupItemBuilder: (context, item, isSelected) {
            return dropDownSearchCustomPopup(
                context, item.stateName!, isSelected);
          },
          searchFieldProps: dropdownSearchCustomsearchBox(context),
          selectedItem: _selectedState,
          filterFn: (statenName, filter) => statenName!.filterByName(filter!),
          // errorBuilder: (context, searchEntry, exception) => Center(
          //     child: Text('Loading...', style: TextStyle(color: Colors.grey))),
          emptyBuilder: (context, searchEntry) => Center(
            child: Text(
              'Select the Country', style: _dropdownLabelStyle,
              //style: TextStyle(color: Colors.grey),
            ),
          ),
          onChanged: (data) {
            setState(() {
              _selectedState = data;
              _selectedCity = null;
              widget.locationHandler(
                  _selectedCountry, _selectedState, _selectedCity);
              _loadCities();
            });
          },
          showSearchBox: true,
          showSelectedItems: true,
        ),
        //STATELIST
        verticalSpaceSmall,
        //CITIESLIST
        DropdownSearch<CityName>(
          enabled: widget.enable,
          dropdownBuilder: (context, selectedItem) {
            if (selectedItem != null)
              return Text(selectedItem.cityName, style: _dropdownTextViewStyle);
            else
              return Text('Choose your Location', style: _dropdownLabelStyle);
          },
          focusNode: _cityFocusNode,
          validator: (v) => v == null ? 'Select your location' : null,
          mode: Mode.DIALOG,
          onFind: _selectedState != null
              ? (String? filter) => getCities(filter!)
              : null,
          compareFn: (item, selectedValue) =>
              item?.cityName == selectedValue?.cityName,
          dropdownSearchDecoration: AdaptiveTheme.dropdownSearchDecoration(
              context, _selectedCity == null ? '' : 'Location', _cityFocusNode),
          popupItemBuilder: (context, item, isSelected) {
            return dropDownSearchCustomPopup(
                context, item.cityName, isSelected);
          },
          searchFieldProps: dropdownSearchCustomsearchBox(context),
          selectedItem: _selectedCity,
          filterFn: (cityName, filter) => cityName!.filterByName(filter!),
          // errorBuilder: (context, searchEntry, exception) => Center(
          //     child: Text('Loading...', style: TextStyle(color: Colors.grey))),
          emptyBuilder: (context, searchEntry) => Center(
            child: Text(
              'Select the State',
              style: _dropdownLabelStyle,
              // style: TextStyle(color: Colors.grey),
            ),
          ),
          onChanged: (data) {
            setState(() {
              _selectedCity = data;
              widget.locationHandler(
                  _selectedCountry, _selectedState, _selectedCity);
            });
          },
          showSearchBox: true,
          showSelectedItems: true,
        ),
        //CITIESLIST
      ],
    );
  }
}
