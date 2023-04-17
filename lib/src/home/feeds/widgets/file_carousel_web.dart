import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';

import '../../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../../adaptive/adaptive_theme.dart';
import '../../../../util/video_from_network.dart';
//import '../../../../util/video_from_network_temp.dart';
import '../../../../util/ui_helpers.dart';
import '../../../../src/models/firestore/fileobj.dart';

class FileCarouselWeb extends StatefulWidget {
  final List<FileObj>? fileObjs;
  FileCarouselWeb(this.fileObjs);

  @override
  State<FileCarouselWeb> createState() => _FileCarouselWebState();
}

class _FileCarouselWebState extends State<FileCarouselWeb> {
  final PageController _pageController = new PageController();
  final ValueNotifier<int> _pageNotifier = new ValueNotifier<int>(0);

  @override
  void dispose() {
    _pageController.dispose();
    _pageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Widget _buildImageItem(FileObj fileObj) {
      return ClipRect(
        child: GestureDetector(
          onTap: () {
            //print(fileObj.url);
          },
          child: CachedNetworkImage(
            imageUrl: appImageUrl(fileObj.url!),
            imageBuilder: (context, imageProvider) => Container(
              width: size.width * 0.90,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
            placeholder: (context, url) =>
                Center(child: AdaptiveCircularProgressIndicator()),
            errorWidget: (context, url, error) => SizedBox(
              width: size.width * 0.90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported_outlined,
                      size: 100, color: AdaptiveTheme.primaryColor(context)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget _buildVideoItem(FileObj fileObj) {
      return VideoFromNetwork(videoUrl: appVideoUrl(fileObj.url!));
    }

    Widget _buildCarouselItem(FileObj fileObj) {
      return Card(
        elevation: 0.0,
        child: Stack(
          // alignment: WrapAlignment.center,
          children: <Widget>[
            if (fileObj.type == 'image') _buildImageItem(fileObj),
            if (fileObj.type == 'video') _buildVideoItem(fileObj),
            const SizedBox(height: 5),
          ],
        ),
      );
    }

    return SizedBox(
      width: size.width * 0.90,
      height: 270,
      child: Stack(
        //mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 258,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: PageView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: _pageController,
                    itemCount: widget.fileObjs!.length,
                    itemBuilder: (BuildContext context, int i) {
                      return _buildCarouselItem(widget.fileObjs![i]);
                    },
                    onPageChanged: (index) {
                      setState(() {
                        _pageNotifier.value = index;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          if (widget.fileObjs!.length > 1)
            Positioned(
              child: Align(
                alignment: Alignment(0, 0.8),
                child: CirclePageIndicator(
                  selectedBorderColor: Colors.white,
                  borderColor: Colors.white,
                  borderWidth: 3,
                  size: 8,
                  selectedSize: 8,
                  dotColor: Colors.white,
                  selectedDotColor: AdaptiveTheme.primaryColor(context),
                  // borderColor: Colors.black,
                  // selectedBorderColor: Colors.purple,
                  currentPageNotifier: _pageNotifier,
                  itemCount: widget.fileObjs!.length,
                ),
              ),
            )
        ],
      ),
    );
  }
}
