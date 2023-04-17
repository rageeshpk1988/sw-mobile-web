import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/route_arguments.dart';
import '../../../../src/models/b2cparent.dart';

import '../../../../adaptive/adaptive_theme.dart';
import '../../../../util/ui_helpers.dart';
import '../../../../widgets/rounded_button.dart';

import '../../../models/firestore/followingparents.dart';
import '../../../models/login_response.dart';
import '../../../profile/screens/profile_others.dart';
import '../../../providers/auth.dart';
import '../../../providers/homestaticdata_new.dart';
import '../screens/parent_tiles_screen.dart';

class HomePageParentsList extends StatefulWidget {
  @override
  State<HomePageParentsList> createState() => _HomePageParentsListState();
}

class _HomePageParentsListState extends State<HomePageParentsList> {
  List<B2CParent>? parentList;
  var _isInIt = true;
  @override
  void didChangeDependencies() {
    LoginResponse loginResponse =
        Provider.of<Auth>(context, listen: true).loginResponse;

    if (_isInIt) {
      setState(() {});
      Provider.of<HomeStaticDataNew>(context, listen: false)
          .fetchAndSetSuggestedParentList(loginResponse.b2cParent!.parentID)
          .then((value) {
        parentList = Provider.of<HomeStaticDataNew>(context, listen: false)
            .suggestedParents;
        setState(() {});
      });
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

  // final List<B2CParent> parentList;
  Widget _buildCard(BuildContext context, B2CParent parent) {
    return Container(
      width: 180,
      // height: 400,
      child: Card(
        elevation: 1.0,
        child: Wrap(
          alignment: WrapAlignment.center,
          children: <Widget>[
            ClipRRect(
              child: GestureDetector(
                onTap: () {
                  //navigate
                },
                child: getAvatarImage(
                    parent.profileImage, 130, 150, BoxShape.rectangle),
              ),
            ),
            // SizedBox(height: 30),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(parent.name,
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87),
                    softWrap: true,
                    overflow: TextOverflow.clip),
                //TODO :: Suggested parent's child is disabled as per
                //the team's decision
                // TextButton.icon(
                //   style: TextButton.styleFrom(
                //     textStyle: const TextStyle(fontSize: 16),
                //   ),
                //   onPressed: () {
                //     Dialogs().ackAlert(
                //         context, 'Suggested Child', 'Details will go here');
                //   },
                //   icon: Icon(
                //     Icons.face,
                //     color: Colors.blue,
                //     size: 18,
                //   ),
                //   label: const Text(
                //     'Alex',
                //     style: TextStyle(color: Colors.blue),
                //   ),
                // ),
                SizedBox(
                  width: 150,
                  child: RoundButton(
                      color: AdaptiveTheme.secondaryColor(context),
                      title: 'Connect',
                      onPressed: () {
                        FollowingParents followingParents = FollowingParents(
                          city: parent.location,
                          userID: parent.parentID,
                          createdAt: null,
                          country: parent.country,
                          userType: "parent",
                          state: parent.state,
                          userName: parent.name,
                          userImage: parent.profileImage,
                        );
                        Navigator.of(context).pushNamed(
                          ProfileOthersScreen.routeName,
                          arguments:
                              ProfileOthersArgs(null, followingParents, null),
                        );
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // void _cardNavigate(BuildContext context, B2CParent parent) {
  Widget _rowHeading(
      BuildContext context, String heading, List<B2CParent> parentList) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            heading,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black),
            textAlign: TextAlign.left,
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.arrow_forward_outlined),
            iconSize: 25,
            color: AdaptiveTheme.secondaryColor(context),
            onPressed: () {
              Navigator.of(context).pushNamed(ParentTilesScreen.routeName,
                  arguments: parentList);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    parentList =
        Provider.of<HomeStaticDataNew>(context, listen: true).suggestedParents;
    int maxItmes = 5;
    if (parentList != null) {
      if (parentList!.length < maxItmes) {
        maxItmes = parentList!.length;
      }
    }
    return parentList == null
        ? SizedBox()
        : parentList!.length < 1
            ? const SizedBox()
            : Column(
                children: [
                  _rowHeading(context, 'Connect With Parents', parentList!),
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: maxItmes + 1,
                      itemBuilder: (BuildContext context, int i) {
                        if (i == maxItmes) {
                          return const SizedBox();
                        } else {
                          return _buildCard(context, parentList![i]);
                        }
                      },
                    ),
                  ),
                ],
              );
  }
}
