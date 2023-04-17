import 'package:flutter/material.dart';
//import 'package:expandable_text/expandable_text.dart' as expandTextPackage;
import 'package:provider/provider.dart';
import '../../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../../helpers/route_arguments.dart';

import '../../../../src/providers/child_skill_summary.dart';
import '../../../../adaptive/adaptive_custom_appbar.dart';
import '../../../../util/dialogs.dart';
import '../../../../util/ui_helpers.dart';
import '../../../models/child.dart';
import '../../../models/login_response.dart';
import '../../../providers/auth.dart';

class ChildSkillReportSubViewScreen extends StatefulWidget {
  static String routeName = '/child-skill-report-subview';
  ChildSkillReportSubViewScreen({Key? key}) : super(key: key);

  @override
  _ChildSkillReportSubViewScreenState createState() =>
      _ChildSkillReportSubViewScreenState();
}

class _ChildSkillReportSubViewScreenState
    extends State<ChildSkillReportSubViewScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  late LoginResponse _loginResponse;
  var _isInIt = true;
  bool _isLoading = false;
  late Child _defaultChild;
  late String _pageDescription;
  late SkillReportDescriptionArgs categoryArgs;
  @override
  void didChangeDependencies() {
    if (_isInIt) {
      setState(() {
        _isLoading = true;
      });
      _loginResponse = Provider.of<Auth>(context, listen: false).loginResponse;
      _defaultChild = Provider.of<Auth>(context, listen: false).currentChild!;

      categoryArgs = ModalRoute.of(context)!.settings.arguments
          as SkillReportDescriptionArgs;

      Provider.of<ChildSkillSummary>(context, listen: false)
          .fetchAssessmentDescription(
              _defaultChild.childID!, categoryArgs.subCategory.catID)
          .then((value) {
        setState(() {
          _pageDescription = value;
          _isLoading = false;
        });
      }).onError((error, stackTrace) {
        setState(() {
          Dialogs().ackAlert(context, 'Data Error', error.toString());
        });
      });

      _isInIt = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      appBar: AdaptiveCustomAppBar(
        showShopifyHomeButton: false,
        showShopifyCartButton: false,
        showKycButton: false,
        showProfileButton: false,
        showHamburger: false,
        scaffoldKey: scaffoldKey,
        adResponse: null,
        loginResponse: null,
        kycStatus: null,
        updateHandler: () {},
        socialUpdateHandler: () {},
        socialAccessTokenResponse: null,
        title: categoryArgs.skillCategory.catName,
        showMascot: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(10),
          child: _isLoading
              ? Center(child: AdaptiveCircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        categoryArgs.subCategory.catName,
                        style: TextStyle(
                            fontSize: textScale(context) <= 1.0 ? 20 : 16,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            'Significance',
                            style: TextStyle(
                                fontSize: textScale(context) <= 1.0 ? 17 : 14,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(_pageDescription,
                          style: TextStyle(
                            letterSpacing: 0.5,
                            fontSize: textScale(context) <= 1.0 ? 16 : 12,
                          )),
                    ],
                  ),
                ),
        ),
        // ),
      ),
    );
  }
}
