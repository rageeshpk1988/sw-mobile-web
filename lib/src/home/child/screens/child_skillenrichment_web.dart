import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/src/home/child/widgets/skill_enrichment_item_web.dart';
import '../../../../util/dialogs.dart';

import '../../../../adaptive/adaptive_circular_progressInd.dart';

import '../../../../util/ui_helpers.dart';
import '../../../../widgets/web_banner.dart';
import '../../../../widgets/web_bottom_bar.dart';
import '../../../providers/auth.dart';
import '../../../providers/child_skill_enrichment.dart';

class ChildSkillEnrichmentScreenWeb extends StatefulWidget {
  static String routeName = '/web-child-skill-enrichment';
  ChildSkillEnrichmentScreenWeb({Key? key}) : super(key: key);

  @override
  _ChildSkillEnrichmentScreenWebState createState() =>
      _ChildSkillEnrichmentScreenWebState();
}

class _ChildSkillEnrichmentScreenWebState
    extends State<ChildSkillEnrichmentScreenWeb> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

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
    Widget _bodyWidget() {
      return FutureBuilder(
        future: _refreshSkills(context),
        builder: (ctx, dataSnapshot) => dataSnapshot.connectionState ==
                ConnectionState.waiting
            ? Center(child: AdaptiveCircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => _refreshSkills(context),
                child: Consumer<ChildSkillEnrichment>(
                  builder: (ctx, skillsData, child) => skillsData.skill == null
                      ? Center(child: const Text(' '))
                      : skillsData.skill!.assessments!.length > 0
                          ? ListView.builder(
                              shrinkWrap: true,
                              // physics: NeverScrollableScrollPhysics(),
                              itemCount: skillsData.skill!.assessments!.length,
                              itemBuilder: (ctx, i) => SkillEnrichmentItemWeb(
                                  skillsData.skill!.assessments![i]),
                            )
                          : Center(
                              child: const Text('No Recommendations Found...')),
                ),
              ),
      );
    }

    return Scaffold(
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
                    'Skill Enrichment',
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
