import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../util/app_theme.dart';
import '../../../util/app_theme_cupertino.dart';
import '../../models/referral.dart';
import '/util/ui_helpers.dart';

class ReferralDetailViewItem extends StatefulWidget {
  final ReferralDetailDto referral;

  const ReferralDetailViewItem({Key? key, required this.referral})
      : super(key: key);
  @override
  State<ReferralDetailViewItem> createState() => _ReferralDetailViewItemState();
}

class _ReferralDetailViewItemState extends State<ReferralDetailViewItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: HexColor.fromHex("#FCFCFC"),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
        side: BorderSide(color: HexColor.fromHex("#E5E5E5")),
      ),
      elevation: 0,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: SizedBox(
          width: double.infinity,
          //height: 120,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.referral.rewardedStatus!.toLowerCase() ==
                          "yes")
                        Icon(
                          Icons.check_circle,
                          color: HexColor.fromHex("#1AE122"),
                          size: 14.0,
                        ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 100.0),
                          child: Text(
                            '${widget.referral.parentName}',
                            style: kIsWeb || Platform.isAndroid
                                ? AppTheme.lightTheme.textTheme.bodySmall!
                                    .copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700)
                                : AppThemeCupertino
                                    .lightTheme.textTheme.navTitleTextStyle
                                    .copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      // Spacer(),
                    ],
                  ),
                  SizedBox(height: 18),
                  Text(
                    '${widget.referral.dateOfJoining!.day}-${widget.referral.dateOfJoining!.month}-${widget.referral.dateOfJoining!.year}',
                    style: kIsWeb || Platform.isAndroid
                        ? AppTheme.lightTheme.textTheme.bodySmall!
                            .copyWith(fontSize: 12, fontWeight: FontWeight.w500)
                        : AppThemeCupertino
                            .lightTheme.textTheme.navTitleTextStyle
                            .copyWith(
                                fontSize: 12, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    'Date of joining',
                    style: kIsWeb || Platform.isAndroid
                        ? AppTheme.lightTheme.textTheme.bodySmall!
                            .copyWith(fontSize: 7, fontWeight: FontWeight.w300)
                        : AppThemeCupertino
                            .lightTheme.textTheme.navTitleTextStyle
                            .copyWith(fontSize: 7, fontWeight: FontWeight.w300),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //const SizedBox(width: 5),
                      Flexible(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 100.0),
                          child: Text(
                            'SL NO: ${widget.referral.parentId}',
                            style: kIsWeb || Platform.isAndroid
                                ? AppTheme.lightTheme.textTheme.bodySmall!
                                    .copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300)
                                : AppThemeCupertino
                                    .lightTheme.textTheme.navTitleTextStyle
                                    .copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                      // Spacer(),
                    ],
                  ),
                  SizedBox(height: 18),
                  Text(
                    widget.referral.rewardedStatus!.toLowerCase() == "yes"
                        ? 'Yes'
                        : 'No',
                    style: kIsWeb || Platform.isAndroid
                        ? AppTheme.lightTheme.textTheme.bodySmall!
                            .copyWith(fontSize: 12, fontWeight: FontWeight.w500)
                        : AppThemeCupertino
                            .lightTheme.textTheme.navTitleTextStyle
                            .copyWith(
                                fontSize: 12, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    'Rewarded',
                    style: kIsWeb || Platform.isAndroid
                        ? AppTheme.lightTheme.textTheme.bodySmall!
                            .copyWith(fontSize: 7, fontWeight: FontWeight.w300)
                        : AppThemeCupertino
                            .lightTheme.textTheme.navTitleTextStyle
                            .copyWith(fontSize: 7, fontWeight: FontWeight.w300),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
