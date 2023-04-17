import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/adaptive/adaptive_theme.dart';

import '../../../../util/app_theme.dart';
import '../../../../src/models/child.dart';

import '../../../../util/ui_helpers.dart';
import '../../../providers/auth.dart';

class ProfileCarouselWeb extends StatefulWidget {
  final List<Child>? children;
  final Function? updateHandler;

  const ProfileCarouselWeb({
    this.children,
    required this.updateHandler,
    Key? key,
  }) : super(key: key);

  @override
  _ProfileCarouselWebState createState() => _ProfileCarouselWebState();
}

class _ProfileCarouselWebState extends State<ProfileCarouselWeb> {
  final PageController _pageController = new PageController();
  final ValueNotifier<int> _pageNotifier = new ValueNotifier<int>(0);

  int selectedChildIndex = 0;
  @override
  void dispose() {
    _pageController.dispose();
    _pageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    Widget _buildCarouselItem(Child child) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
        child: Container(
          width: deviceSize.width * 0.25,
          height: 120,
          child: Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              side:
                  widget.children![selectedChildIndex].childID == child.childID
                      ? BorderSide(
                          color: AdaptiveTheme.secondaryColor(context),
                          width: 2.0)
                      : BorderSide(color: HexColor.fromHex('#B1EEB5')),
              borderRadius: BorderRadius.circular(13),
            ),
            // color: HexColor.fromHex('#EFFEF0'),
            color: widget.children![selectedChildIndex].childID == child.childID
                ? Colors.white
                : Colors.grey.shade200,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      getAvatarImage(
                          child.imageUrl,
                          screenWidth(context) * 0.09,
                          screenHeight(context) * 0.09,
                          BoxShape.circle,
                          child.name
                          //screenWidth(context) * 0.11,
                          ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: SizedBox(
                                    width: 200,
                                    child: Text(
                                      child.name.length > 18
                                          ? child.name.substring(0, 17) + '...'
                                          : child.name,
                                      style: AppTheme
                                          .lightTheme.textTheme.titleSmall!
                                          .copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //verticalSpaceSmall,
                            Text(
                              '${child.className} ${child.division} - ${child.schoolName}',
                              style: AppTheme.lightTheme.textTheme.bodySmall!
                                  .copyWith(fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 20.0, 20.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Text(
                  "Child's Transformation",
                  style: TextStyle(
                      letterSpacing: 0.0,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black),
                ),
                Spacer(),
                Row(
                  children: [
                    Text(
                      widget.children!.length.toString(),
                      style: TextStyle(
                          letterSpacing: 0.0,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.people_outline_rounded,
                      size: 30,
                      color: AdaptiveTheme.secondaryColor(context),
                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: deviceSize.width * 0.90,
            height: 120,
            child: ListView.builder(
              //controller: _listController,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: widget.children!.length,
              itemBuilder: (BuildContext context, int i) {
                return GestureDetector(
                  onTap: () {
                    Provider.of<Auth>(context, listen: false)
                        .updateChild(widget.children![i]);
                    widget.updateHandler!(widget.children![i].childID);
                    setState(() {
                      selectedChildIndex = i;
                    });
                  },
                  child: _buildCarouselItem(widget.children![i]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              widget.children![selectedChildIndex].name,
              style: TextStyle(
                  letterSpacing: 0.0,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
