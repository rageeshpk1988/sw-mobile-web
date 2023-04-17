import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/route_arguments.dart';
import '../../../../src/models/b2cparent.dart';

import '../../../../adaptive/adaptive_theme.dart';
import '../../../../util/ui_helpers.dart';

import '../../../models/firestore/followingparents.dart';
import '../../../models/login_response.dart';

import '../../../profile/screens/profile_others_web.dart';
import '../../../providers/auth.dart';
import '../../../providers/homestaticdata_new.dart';

class HomePageParentsListWeb extends StatefulWidget {
  @override
  State<HomePageParentsListWeb> createState() => _HomePageParentsListWebState();
}

class _HomePageParentsListWebState extends State<HomePageParentsListWeb> {
  List<B2CParent>? parentList;
  var _isInIt = true;
  final _listController = ScrollController();

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    LoginResponse loginResponse =
        Provider.of<Auth>(context, listen: true).loginResponse;

    if (_isInIt) {
      //setState(() {});
      Provider.of<HomeStaticDataNew>(context, listen: false)
          .fetchAndSetSuggestedParentList(loginResponse.b2cParent!.parentID)
          .then((value) {
        setState(() {
          parentList = Provider.of<HomeStaticDataNew>(context, listen: false)
              .suggestedParents;
          _isInIt = false;
        });
      });
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Widget _buildCard(BuildContext context, B2CParent parent) {
    return Container(
      width: 300,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 10.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(width: 5),
            ClipRRect(
              child: getAvatarImage(
                  parent.profileImage, 100, 130, BoxShape.rectangle),
            ),
            const SizedBox(width: 5),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(parent.name,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87),
                      softWrap: true,
                      overflow: TextOverflow.clip),
                ),
                GestureDetector(
                  onTap: () {
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
                      ProfileOthersScreenWeb.routeName,
                      arguments:
                          ProfileOthersArgs(null, followingParents, null),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.person_pin,
                          color: AdaptiveTheme.primaryColor(context)),
                      Text('Connect',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AdaptiveTheme.primaryColor(context))),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowHeading(
      BuildContext context, String heading, List<B2CParent> parentList) {
    return Padding(
      padding: EdgeInsets.only(left: 8.0, right: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            heading,
            style: TextStyle(
                letterSpacing: 0.0,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black),
            textAlign: TextAlign.left,
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                if (_listController.offset > 0) {
                  _listController.animateTo(_listController.offset - 300,
                      duration: Duration(milliseconds: 1000),
                      curve: Curves.fastOutSlowIn);
                }
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(5.0),
                shape: BoxShape.rectangle,
              ),
              child: Icon(Icons.arrow_back_outlined,
                  size: 20, color: AdaptiveTheme.secondaryColor(context)),
            ),
          ),
          const SizedBox(width: 3),
          GestureDetector(
            onTap: () {
              setState(() {
                _listController.animateTo(_listController.offset + 300,
                    duration: Duration(milliseconds: 1000),
                    curve: Curves.fastOutSlowIn);
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(5.0),
                shape: BoxShape.rectangle,
              ),
              child: Icon(Icons.arrow_forward_outlined,
                  size: 20, color: AdaptiveTheme.secondaryColor(context)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    parentList =
        Provider.of<HomeStaticDataNew>(context, listen: true).suggestedParents;
    // int maxItems = 0; //this is only for testing . to be removed
    // if (parentList != null) {
    //   maxItems = parentList!.length;
    // }

    return parentList == null
        ? SizedBox()
        : parentList!.length < 1
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    _rowHeading(context, 'Connect With Parents', parentList!),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: screenWidth(context) * 0.97,
                      height: 150,
                      child: ListView.builder(
                        controller: _listController,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: parentList!.length,
                        itemBuilder: (BuildContext context, int i) {
                          // if (i >= maxItems) {
                          //   return _buildCard(context, parentList![0]);
                          // } else {
                          return _buildCard(context, parentList![i]);
                          //}
                        },
                      ),
                    ),
                  ],
                ),
              );
  }
}
