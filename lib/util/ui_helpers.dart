// Horizontal Spacing
//import 'dart:ui';

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '/util/app_theme.dart';
import '/util/app_theme_cupertino.dart';
import '/util/gen_thumpnail.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../adaptive/adaptive_theme.dart';
import '/helpers/global_variables.dart';

const Widget horizontalSpaceTiny = const SizedBox(width: 5.0);
const Widget horizontalSpaceSmall = const SizedBox(width: 10.0);
const Widget horizontalSpaceRegular = const SizedBox(width: 18.0);
const Widget horizontalSpaceMedium = const SizedBox(width: 25.0);
const Widget horizontalSpaceLarge = const SizedBox(width: 50.0);

// Vertical Spacing
const Widget verticalSpaceTiny = const SizedBox(height: 5.0);
const Widget verticalSpaceSmall = const SizedBox(height: 10.0);
const Widget verticalSpaceRegular = const SizedBox(height: 18.0);
const Widget verticalSpaceMedium = const SizedBox(height: 25);
const Widget verticalSpaceLarge = const SizedBox(height: 50.0);
const Widget verticalSpaceMassive = const SizedBox(height: 120.0);

// Screen Size Helpers
double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
double textScale(BuildContext context) => MediaQuery.textScaleFactorOf(context);

///  [percentage] should
/// be between 0 and 1 where 0 is 0% and 100 is 100% of the screens height
double screenHeightPercentage(BuildContext context, {double percentage = 1}) =>
    screenHeight(context) * percentage;

/// [percentage] should
/// be between 0 and 1 where 0 is 0% and 100 is 100% of the screens width
double screenWidthPercentage(BuildContext context, {double percentage = 1}) =>
    screenWidth(context) * percentage;

String appImageUrl(String imageUrl) {
  if (imageUrl.substring(0, 9).toLowerCase() == 'resources') {
    return '${GlobalVariables.apiBaseUrl}/login/$imageUrl';
  } else {
    return imageUrl;
  }
}

String appVideoUrl(String videoUrl) {
  if (videoUrl.substring(0, 9).toLowerCase() == 'resources') {
    return '${GlobalVariables.apiBaseUrl}/login/$videoUrl';
  } else {
    return videoUrl;
  }
}

Widget _avatarImageDefault(
    //double radius,
    double width,
    double height,
    BoxShape boxShape) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      shape: boxShape,
      image: DecorationImage(
          image: AssetImage('assets/images/profile_dummy.png'),
          fit: BoxFit.scaleDown),
    ),
  );
}

Widget _avatarImageDefaultNew(
    //double radius,
    double width,
    double height,
    BoxShape boxShape,
    String userName) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      shape: boxShape,
      color: Color(0xffF6AB15),
      /*image: DecorationImage(
          image: AssetImage('assets/images/profile_dummy.png'),
          fit: BoxFit.scaleDown),*/
    ),
    child: Center(
        child: Text(
      userName[0].toUpperCase(),
      style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 22),
    )),
  );
}

Widget getAvatarImage(
    String? profileUrl, //double radius,
    double width,
    double height,
    [BoxShape boxShape = BoxShape.circle,
    String? userName]) {
  String imageUrl;
  if (profileUrl == null) {
    imageUrl = 'assets/images/profile_dummy.png';
  } else {
    if (profileUrl == '') {
      imageUrl = 'assets/images/profile_dummy.png';
    } else {
      imageUrl = appImageUrl(profileUrl);
    }
  }
  if (profileUrl == null || profileUrl == '') {
    if (userName == null) {
      return _avatarImageDefault(width, height, boxShape);
    } else {
      return _avatarImageDefaultNew(width, height, boxShape, userName);
    }
  } else {
    return Container(
      width: width,
      height: height,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            shape: boxShape,
            borderRadius: boxShape == BoxShape.rectangle
                ? BorderRadius.circular(10.0)
                : null,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        placeholder: (context, url) => userName == null
            ? Center(child: _avatarImageDefault(width, height, boxShape))
            : Center(
                child:
                    _avatarImageDefaultNew(width, height, boxShape, userName)),
        errorWidget: (context, url, error) => userName == null
            ? _avatarImageDefault(width, height, boxShape)
            : _avatarImageDefaultNew(width, height, boxShape, userName),
      ),
    );
  }
}

Widget splitString(
  String delimitedString,
  String delimiter,
  double fontSize,
) {
  List<String> stringParts = delimitedString.split(delimiter);
  return ListView.builder(
    physics: NeverScrollableScrollPhysics(),
    itemCount: stringParts.length,
    shrinkWrap: true,
    itemBuilder: (_, i) {
      return Text(
        stringParts[i],
        textAlign: TextAlign.left,
        style: TextStyle(fontSize: fontSize),
      );
    },
  );
}

// Future<void> removeProfileImageFile(String? imgUrl) async {
//   await DefaultCacheManager().removeFile(imgUrl!).then((value) {
//     //print('File removed');
//   }).onError((error, stackTrace) {
//     print(error);
//   });
// }

void evictImage(String? profileUrl) {
  var imgUrl = '${GlobalVariables.apiBaseUrl}/login/$profileUrl';

  final NetworkImage provider = NetworkImage(imgUrl);
  provider.evict().then<void>((bool success) {
    if (success) debugPrint('removed image!');
  });
}

getBoxDecoration(double borderWidth, double cornerRadius, Color color) =>
    BoxDecoration(
      border: Border.all(
        width: borderWidth,
        color: color,
      ),
      borderRadius: BorderRadius.all(Radius.circular(
              cornerRadius) //                 <--- border radius here
          ),
    );

/// Construct a color from a hex code string, of the format #RRGGBB.
Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

//Dropdown related
Padding dropDownSearchCustomPopup(
        BuildContext context, String item, bool isSelected) =>
    Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 7.0, 10.0, 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item,
            style: kIsWeb || Platform.isAndroid
                ? AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                    //fontSize: 16,
                    color: isSelected
                        ? AdaptiveTheme.primaryColor(context)
                        : Colors.black)
                : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
                    .copyWith(
                        fontWeight: FontWeight.w400,
                        color: isSelected
                            ? AdaptiveTheme.primaryColor(context)
                            : Colors.black),
          ),
          Divider(thickness: 1),
        ],
      ),
    );
//Dropdown related
TextFieldProps dropdownSearchCustomsearchBox(BuildContext context) =>
    TextFieldProps(
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      enableInteractiveSelection: false,
      decoration: InputDecoration(
        floatingLabelStyle:
            TextStyle(color: AdaptiveTheme.primaryColor(context)),
        labelStyle: kIsWeb || Platform.isAndroid
            ? AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
                fontSize: 15, fontWeight: FontWeight.w300, letterSpacing: 0.0)
            : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle.copyWith(
                fontSize: 15, fontWeight: FontWeight.w300, letterSpacing: 0.0),
        labelText: 'Search',
        suffixIcon: Icon(
          Icons.search,
          color: Colors.grey, // AdaptiveTheme.primaryColor(context),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(5.0),
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(
                width: 2.0, color: AdaptiveTheme.primaryColor(context))),
      ),
    );

//Hexcolor extension
extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

//Total file size
double totalFileSize(List<File> imageFiles, List<File> videoFiles) {
  var imageListLength = imageFiles.length;
  var videoListLength = videoFiles.length;
  double totalSize = 0.0;
  int sizeInBytes = 0;
  double sizeInMb = 0.0;
  for (int i = 0; i < imageListLength; i++) {
    sizeInBytes = imageFiles[i].lengthSync();
    sizeInMb = sizeInBytes / (1024 * 1024);
    totalSize = totalSize + sizeInMb;
  }
  for (int i = 0; i < videoListLength; i++) {
    sizeInBytes = videoFiles[i].lengthSync();
    sizeInMb = sizeInBytes / (1024 * 1024);
    totalSize = totalSize + sizeInMb;
  }
  return totalSize;
}

//Custom App Button
Widget appButton({
  required BuildContext context,
  required double width,
  required double height,
  required String title,
  required Color titleColour,
  VoidCallback? onPressed,
  required Color borderColor,
  Color primary = Colors.white,
  double borderRadius = 7.0,
  double titleFontSize = 15,
  // bool underlineText = false,
}) {
  return SizedBox(
    width: width,
    height: height,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        elevation: 0.0,
        backgroundColor: primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            color: borderColor,
          ),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(
          letterSpacing: 0.0,
          fontSize: titleFontSize,
          color: titleColour,
          // decoration:
          //     underlineText ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    ),
  );
}

Widget getThumNailImage(String videoPath) {
  GenThumbnailImage? _futreImage = null;
  ImageFormat _format = ImageFormat.JPEG;
  int _quality = 50;
  int _sizeH = 100;
  // 100;
  int _sizeW = 100;
  // 100;
  int _timeMs = 0;
  _futreImage = GenThumbnailImage(
      thumbnailRequest: ThumbnailRequest(
          video: videoPath,
          thumbnailPath: null,
          imageFormat: _format,
          maxHeight: _sizeH,
          maxWidth: _sizeW,
          timeMs: _timeMs,
          quality: _quality));
  // ignore: unnecessary_null_comparison
  return _futreImage != null ? _futreImage : SizedBox();
}
// //Adaptive button
// class AdaptiveButton extends StatelessWidget {
//   const AdaptiveButton({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         primary: Colors.white,
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//             side: BorderSide(
//                 color: AdaptiveTheme.primaryColor(
//                     context))), //need to change primary or secondary(adaptive)
//       ),
//       onPressed: () {
//         //adaptive function
//       },
//       child: Text(
//         "OK",
//         style: TextStyle(
//           fontSize: 12, // fontSize might also change
//           color: AdaptiveTheme.primaryColor(
//               context), //need to change primary or secondary(adaptive)
//         ),
//       ),
//     );
//   }
// }
class AppRatingBar extends StatefulWidget {
  final double initialRating;
  final Axis direction;
  final double size;
  final Function rateCallBack;
  const AppRatingBar({
    required this.initialRating,
    required this.direction,
    required this.size,
    required this.rateCallBack,
    Key? key,
  }) : super(key: key);

  @override
  State<AppRatingBar> createState() => _AppRatingBarState();
}

class _AppRatingBarState extends State<AppRatingBar> {
  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: widget.initialRating,
      direction: widget.direction,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 10.0),
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return Icon(
              Icons.sentiment_very_dissatisfied,
              color: Colors.red,
              size: widget.size,
            );
          case 1:
            return Icon(
              Icons.sentiment_dissatisfied,
              color: Colors.redAccent,
              size: widget.size,
            );
          case 2:
            return Icon(
              Icons.sentiment_neutral,
              color: Colors.amber,
              size: widget.size,
            );
          case 3:
            return Icon(
              Icons.sentiment_satisfied,
              color: Colors.lightGreen,
              size: widget.size,
            );
          case 4:
            return Icon(
              Icons.sentiment_very_satisfied,
              color: Colors.green,
              size: widget.size,
            );
          default:
            return Container();
        }
      },
      onRatingUpdate: (rating) {
        setState(() {
          widget.rateCallBack(rating);
        });
      },
      updateOnDrag: true,
    );
  }
}
