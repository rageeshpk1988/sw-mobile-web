import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../util/dialogs.dart';
import '../../../../src/home/child/widgets/skill_enrichment_item.dart';

import '../../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../../adaptive/adaptive_custom_appbar.dart';
import '../../../providers/auth.dart';
import '../../../providers/child_skill_enrichment.dart';

class ChildSkillEnrichmentScreen extends StatefulWidget {
  static String routeName = '/child-skill-enrichment';
  ChildSkillEnrichmentScreen({Key? key}) : super(key: key);

  @override
  _ChildSkillEnrichmentScreenState createState() =>
      _ChildSkillEnrichmentScreenState();
}

class _ChildSkillEnrichmentScreenState
    extends State<ChildSkillEnrichmentScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _refreshSkills(BuildContext context) async {
    var parentId = Provider.of<Auth>(context, listen: false)
        .loginResponse
        .b2cParent!
        .parentID;
    var childId =
        Provider.of<Auth>(context, listen: false).currentChild!.childID;
    try {
      await Provider.of<ChildSkillEnrichment>(context, listen: false)
          .fetchAndSetSkills(childId!, parentId);
    } catch (e) {
      Dialogs().ackAlert(context, 'Data Error', e.toString());
    }
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
        title: "Skill Enrichment",
        showMascot: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
          child: FutureBuilder(
            future: _refreshSkills(context),
            builder: (ctx, dataSnapshot) => dataSnapshot.connectionState ==
                    ConnectionState.waiting
                ? Center(child: AdaptiveCircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _refreshSkills(context),
                    child: Consumer<ChildSkillEnrichment>(
                      builder: (ctx, skillsData, child) => skillsData.skill ==
                              null
                          ? Center(child: const Text(' '))
                          : skillsData.skill!.assessments!.length > 0
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount:
                                      skillsData.skill!.assessments!.length,
                                  itemBuilder: (ctx, i) => SkillEnrichmentItem(
                                      skillsData.skill!.assessments![i]),
                                )
                              : Center(
                                  child: const Text(
                                      'No Recommendations Found...')),
                    ),
                  ),
          ),
        ),
        // ),
      ),
    );
  }
}
