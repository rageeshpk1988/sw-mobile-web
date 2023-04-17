import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../src/kyc/screens/kyc_online_screen.dart';
import '../adaptive/adaptive_theme.dart';
import '../src/models/onlinekyc_health_check.dart';
import '../util/app_theme_cupertino.dart';
import '../util/dialogs.dart';
import '../src/models/login_response.dart';
import '../src/providers/auth.dart';
import '../src/models/kycdoc_response.dart';
import '../src/providers/kyc_document.dart';
import '../util/ui_helpers.dart';
import '/util/app_theme.dart';

class KycDocumentPicker extends StatefulWidget {
  final ParentDocumentTypeList? defaultDocument;
  final Function documentHandler;
  final bool enable;

  KycDocumentPicker(
    this.defaultDocument,
    this.documentHandler,
    this.enable,
  );
  @override
  State<KycDocumentPicker> createState() => _KycDocumentPickerState();
}

class _KycDocumentPickerState extends State<KycDocumentPicker> {
  var _isInIt = true;
  VerType? _verType = VerType.offline;
  late LoginResponse loginResponse;

  ParentDocumentTypeList? _selectedDocument;

  List<ParentDocumentTypeList>? _documentsList;
  final _documentFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    _documentFocusNode.addListener(_onOnFocusNodeEvent);
  }

  _onOnFocusNodeEvent() {
    setState(() {});
  }

  @override
  void dispose() {
    _documentFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      loginResponse = Provider.of<Auth>(context, listen: true).loginResponse;
      Provider.of<KycDocument>(context, listen: false)
          .fetchDocuments()
          .then((value) {
        setState(() {
          _documentsList = value;
          //print(_documentsList);
        });
      });
      _selectedDocument =
          widget.defaultDocument == null ? null : widget.defaultDocument;
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

  Future<List<ParentDocumentTypeList>> getDocuments(String filter) async {
    //filter is a dummy parameter
    if (_documentsList == null) return [];
    return _documentsList!;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _textViewStyle = kIsWeb || Platform.isAndroid
        ? AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontSize: 15)
            .copyWith(fontSize: 15)
        : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
            .copyWith(fontSize: 15, fontWeight: FontWeight.w300);

    TextStyle _dropdownTextViewStyle = _textViewStyle;
    TextStyle _dropdownLabelStyle = _textViewStyle.copyWith(
        fontWeight: FontWeight.w200, letterSpacing: 0.0);
    // TextStyle _dropdownLabelStyle =
    //_textViewStyle.copyWith(fontWeight: FontWeight.w200, letterSpacing: 0.0);

    return Column(
      children: [
        //DOCUMENTLIST
        DropdownSearch<ParentDocumentTypeList>(
          dropdownBuilder: (context, selectedItem) {
            if (selectedItem != null)
              return Text(selectedItem.documentType,
                  style: _dropdownTextViewStyle);
            else
              return Text('Document Type', style:  kIsWeb || Platform.isAndroid
                  ? AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w200,
                  color: _documentFocusNode.hasFocus
                      ? AdaptiveTheme.primaryColor(context)
                      : Colors.grey.shade900)
                  : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
                  .copyWith(fontSize: 15, fontWeight: FontWeight.w300,color:_documentFocusNode.hasFocus
                  ? AdaptiveTheme.primaryColor(context)
                  : Colors.grey.shade900 ));
          },
          enabled: widget.enable,
          focusNode: _documentFocusNode,
          validator: (v) => v == null ? 'Select your document' : null,
          mode: Mode.DIALOG,
          onFind: (String? filter) => getDocuments(filter!),
          compareFn: (item, selectedValue) =>
              item?.documentType == selectedValue?.documentType,
          dropdownSearchDecoration: AdaptiveTheme.dropdownSearchDecoration(
              context, 'Document Type', _documentFocusNode),
          popupItemBuilder: (context, item, isSelected) {
            return dropDownSearchCustomPopup(
                context, item.documentType, isSelected);
          },
          searchFieldProps: dropdownSearchCustomsearchBox(context),
          selectedItem: _selectedDocument,
          emptyBuilder: (context, searchEntry) => Center(
            child: Text(
              'Loading documents',
              style: _dropdownLabelStyle,
              // style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          filterFn: (document, filter) => document!.filterByName(filter!),
          onChanged: (data) async {
            setState(() {
              _selectedDocument = data;

              widget.documentHandler(
                _selectedDocument,
              );
            });
            if (_selectedDocument!.documentType == 'Aadhaar') {
              return showDialog<void>(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          actions: <Widget>[
                            ListTile(
                              title: Text(
                                'Verify Aadhaar Offline',
                                style: kIsWeb || Platform.isAndroid
                                    ? AppTheme.lightTheme.textTheme.bodySmall!
                                        .copyWith(fontSize: 15)
                                    : AppThemeCupertino
                                        .lightTheme.textTheme.navTitleTextStyle,
                              ),
                              leading: Radio<VerType>(
                                activeColor: AppTheme.primaryColor,
                                value: VerType.offline,
                                groupValue: _verType,
                                onChanged: (VerType? value) {
                                  setState(() {
                                    _verType = value!;
                                  });
                                  //Navigator.of(context).pop();
                                },
                              ),
                            ),
                            ListTile(
                              title: Text(
                                'Verify Aadhaar Online',
                                style: kIsWeb || Platform.isAndroid
                                    ? AppTheme.lightTheme.textTheme.bodySmall!
                                        .copyWith(fontSize: 15)
                                    : AppThemeCupertino
                                        .lightTheme.textTheme.navTitleTextStyle,
                              ),
                              leading: Radio<VerType>(
                                activeColor: AppTheme.primaryColor,
                                value: VerType.online,
                                groupValue: _verType,
                                onChanged: (VerType? value) {
                                  setState(() {
                                    _verType = value!;
                                  });
                                  //Navigator.of(context).pop();
                                },
                              ),
                            ),
                            TextButton(
                              child: Text(
                                'OK',
                                style: TextStyle(
                                    color: AdaptiveTheme.primaryColor(context)),
                              ),
                              onPressed: () async {
                                if (_verType == VerType.online) {
                                  HealthCheck response1 =
                                      await Provider.of<KycDocument>(context,
                                              listen: false)
                                          .getHealth();
                                  if (response1.code == "000") {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              KycOnlineScreen()),
                                    );
                                  } else {
                                    await Dialogs().ackAlert(
                                        context,
                                        '${response1.message}',
                                        'Please try again later');
                                  }
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  });

              //Navigator.of(context).pop();

            }
          },
          showSearchBox: true,
          showSelectedItems: true,
        ),
        //DOCUMENTLIST
        verticalSpaceSmall,
      ],
    );
  }
}

enum VerType {
  online,
  offline,
}
