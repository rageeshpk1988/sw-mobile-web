import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../adaptive/adaptive_custom_appbar.dart';
import '../../../../adaptive/adaptive_theme.dart';
import '../../../../helpers/route_arguments.dart';

import '../../../../util/ui_helpers.dart';
import '../../../../widgets/rounded_button.dart';

import '../../../models/b2cparent.dart';
import '../../../models/firestore/followingparents.dart';
import '../../../profile/screens/profile_others.dart';
import '../../../providers/homestaticdata_new.dart';

class ParentTilesScreen extends StatefulWidget {
  static String routeName = '/parent-tiles';

  @override
  State<ParentTilesScreen> createState() => _ParentTilesScreenState();
}

class _ParentTilesScreenState extends State<ParentTilesScreen> {
  @override
  Widget build(BuildContext context) {
    // List<B2CParent> parentList =
    //     ModalRoute.of(context)!.settings.arguments as List<B2CParent>;

    List<B2CParent>? parentList =
        Provider.of<HomeStaticDataNew>(context, listen: true).suggestedParents;

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
        title: 'Connect With Parents',
        showMascot: true,
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: const EdgeInsets.all(10.0),
                itemCount: parentList!.length,
                itemBuilder: (ctx, i) => ParentItem(parentList[i]),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1 / 1,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    mainAxisExtent: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//this is for grid items
class ParentItem extends StatelessWidget {
  final B2CParent parent;
  ParentItem(this.parent);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 150,
      child: Wrap(
        alignment: WrapAlignment.center,
        children: <Widget>[
          ClipRRect(
            child: GestureDetector(
              onTap: () {
                //_cardNavigate(context, hospital);
              },
              child: getAvatarImage(
                  parent.profileImage, 130, 120, BoxShape.rectangle),
            ),
          ),
          // SizedBox(height: 30),
          Column(
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
                              ProfileOthersArgs(null, followingParents, null));
                    }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
