import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import '/src/profile/screens/edit_child_web.dart';
import '../../../util/app_theme.dart';
import '/adaptive/adaptive_theme.dart';
import '../../../helpers/connectivity_helper.dart';
import '../../../helpers/route_arguments.dart';

import '../../../src/models/child.dart';
import '../../../src/profile/screens/edit_child.dart';
import '../../../util/app_theme_cupertino.dart';
import '../../../util/ui_helpers.dart';
import '../../../widgets/round_rect_action_button.dart';

class ChildListItem extends StatelessWidget {
  final Child child;
  final Function parentRefreshHandler;
  final editButton;
  final editButtonSizePercentage;
  ChildListItem(this.child, this.parentRefreshHandler, this.editButton,
      {this.editButtonSizePercentage = 0.06});

  @override
  Widget build(BuildContext context) {
    TextStyle _headerStyle(double fontSize, FontWeight fontWeight) {
      return kIsWeb || Platform.isAndroid
          ? AppTheme.lightTheme.textTheme.bodySmall!
              .copyWith(fontSize: fontSize, fontWeight: fontWeight)
          : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
              .copyWith(fontSize: fontSize, fontWeight: fontWeight);
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5.0,
      child: ListTile(
        leading: getAvatarImage(
            child.imageUrl,
            screenWidth(context) > 800 ? 70 : 40,
            screenWidth(context) > 800 ? 70 : 40,
            BoxShape.circle,
            child.name),
        isThreeLine: true,
        title: Text(
          child.name,
          style: _headerStyle(16, FontWeight.w500),
        ),
        subtitle: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${child.schoolName!}\n',
                style: _headerStyle(12, FontWeight.w300),
              ),
              TextSpan(
                text: '${child.className} ${child.division}',
                style: _headerStyle(12, FontWeight.w300)
                    .copyWith(color: AdaptiveTheme.secondaryColor(context)),
              ),
            ],
          ),
        ),
        trailing: editButton
            ? RoundRectActionButton(
                size: screenWidth(context) * editButtonSizePercentage, //0.06,
                iconData: Icons.edit_outlined,
                onTap: () async {
                  if (await ConnectivityHelper.hasInternet<EditchildArgs>(
                          context,
                          kIsWeb
                              ? EditChildScreenWeb.routeName
                              : EditChildScreen.routeName,
                          EditchildArgs(child, parentRefreshHandler)) ==
                      true) {
                    Navigator.of(context).pushNamed(
                        kIsWeb
                            ? EditChildScreenWeb.routeName
                            : EditChildScreen.routeName,
                        arguments: EditchildArgs(child, parentRefreshHandler));
                  }
                },
              )
            : null,
      ),
    );
  }
}
