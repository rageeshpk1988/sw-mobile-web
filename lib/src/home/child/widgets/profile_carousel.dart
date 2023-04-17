import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';
import 'package:provider/provider.dart';
import '../../../../util/app_theme.dart';
import '../../../../src/models/child.dart';

import '../../../../util/app_theme_cupertino.dart';

import '../../../../util/ui_helpers.dart';
import '../../../providers/auth.dart';

class ProfileCarousel extends StatefulWidget {
  final List<Child>? children;
  final Function? updateHandler;

  const ProfileCarousel({
    this.children,
    required this.updateHandler,
    Key? key,
  }) : super(key: key);

  @override
  _ProfileCarouselState createState() => _ProfileCarouselState();
}

class _ProfileCarouselState extends State<ProfileCarousel> {
  final PageController _pageController = new PageController();
  final ValueNotifier<int> _pageNotifier = new ValueNotifier<int>(0);
  bool _playForward = true;
  bool _playBackward = false;

  @override
  void dispose() {
    _pageController.dispose();
    _pageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //var deviceSize = MediaQuery.of(context).size;
    Widget _buildCarouselItem(Child child) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
        child: Container(
          width: double.infinity,
          height: 120,
          child: Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: HexColor.fromHex('#B1EEB5')),
              borderRadius: BorderRadius.circular(13),
            ),
            color: HexColor.fromHex('#EFFEF0'),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      getAvatarImage(
                          child.imageUrl, 40, 40, BoxShape.circle, child.name
                          //screenWidth(context) * 0.11,
                          ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
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
                                            ? child.name.substring(0, 17) +
                                                '...'
                                            : child.name,
                                        style: kIsWeb || Platform.isAndroid
                                            ? AppTheme.lightTheme.textTheme
                                                .titleSmall!
                                                .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize:
                                                        textScale(context) <=
                                                                1.0
                                                            ? 18
                                                            : 14)
                                            : AppThemeCupertino.lightTheme
                                                .textTheme.navTitleTextStyle
                                                .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize:
                                                        textScale(context) <=
                                                                1.0
                                                            ? 18
                                                            : 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              //verticalSpaceSmall,
                              Text(
                                '${child.className} ${child.division} - ${child.schoolName}',
                                style: kIsWeb || Platform.isAndroid
                                    ? AppTheme.lightTheme.textTheme.bodySmall!
                                        .copyWith(fontWeight: FontWeight.w400)
                                    : AppThemeCupertino
                                        .lightTheme.textTheme.textStyle,
                              ),
                            ],
                          ),
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

    return SizedBox(
      width: double.infinity,
      height: 120,
      child: Stack(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: _pageController,
                  itemCount: widget.children!.length,
                  itemBuilder: (BuildContext context, int i) {
                    return _buildCarouselItem(widget.children![i]);
                  },
                  onPageChanged: (index) {
                    Provider.of<Auth>(context, listen: false)
                        .updateChild(widget.children![index]);
                    widget.updateHandler!(widget.children![index].childID);
                    setState(() {
                      _pageNotifier.value = index;
                      _playForward =
                          !(_pageNotifier.value + 1 == widget.children!.length);
                      _playBackward = _pageNotifier.value == 0;
                    });
                  },
                ),
              ),
            ],
          ),
          if (widget.children!.length > 1)
            Positioned(
              right: 30,
              top: 30,
              child: ClipOval(
                child: Material(
                  color: Colors.green,
                  child: InkWell(
                    splashColor: Colors.green.shade100,
                    onTap: () async {
                      await Future.delayed(const Duration(milliseconds: 10));
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        // _pageController.animateTo(
                        //     _playForward
                        //         ? _pageController.position.maxScrollExtent
                        //         : _pageController.position.minScrollExtent,
                        //     duration: const Duration(milliseconds: 400),
                        //     curve: Curves.fastOutSlowIn);
                        _pageController.animateToPage(_pageNotifier.value,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.fastOutSlowIn);
                      });
                      _pageNotifier.value = _playForward
                          ? _pageNotifier.value + 1
                          : _pageNotifier.value - 1;
                      _playForward =
                          !(_pageNotifier.value + 1 == widget.children!.length);

                      _playBackward = _pageNotifier.value == 0;

                      setState(() {});
                    },
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: Icon(
                        _playForward //& !_playBackward
                            ? Icons.navigate_next
                            : Icons.navigate_before,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (widget.children!.length > 1)
            Positioned(
              left: 1,
              bottom: 25,
              child: Container(
                width: MediaQuery.of(context).size.width - 10,
                child: Align(
                  alignment: Alignment.center,
                  child: CirclePageIndicator(
                    size: 10,
                    selectedSize: 10,
                    dotColor: Colors.black12,
                    selectedDotColor: Colors.green,
                    // borderColor: Colors.black,
                    // selectedBorderColor: Colors.purple,
                    currentPageNotifier: _pageNotifier,
                    itemCount: widget.children!.length,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
