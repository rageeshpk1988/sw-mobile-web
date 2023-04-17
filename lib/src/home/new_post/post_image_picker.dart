import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../helpers/global_variables.dart';

import '../../../util/app_theme_cupertino.dart';
import '../../../util/gen_thumpnail.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../adaptive/adaptive_theme.dart';
import '/util/dialogs.dart';

import '../../../util/app_theme.dart';

//TODO:This is a new image picker need to test and approve
class PostImagePicker extends StatefulWidget {
  final Function imageSaveHandler;
  final Function imageRemoveHandler;
  final Function videoSaveHandler;
  final Function videoRemoveHandler;
  final Function imageMultiSaveHandler;
  final bool disable;

  PostImagePicker(
    this.imageSaveHandler,
    this.imageRemoveHandler,
    this.videoSaveHandler,
    this.videoRemoveHandler,
    this.imageMultiSaveHandler,
    this.disable,
  );
  @override
  State<PostImagePicker> createState() => _PostImagePickerState();
}

class _PostImagePickerState extends State<PostImagePicker> {
  //XFile? _pickedImage;
  final _picker = ImagePicker();
  late File _savedImage;
  List<Image> _mediaFileWidgets = [];
  List<String> _videoPaths = [];

  int maxImagesAllowed = 4;
  int maxVideosAllowed = 1;

  void _showPickOptions(BuildContext context) {
    TextStyle _textStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w400);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.image_search,
                size: 30,
                color: AdaptiveTheme.primaryColor(context),
              ),
              title: Text(
                'Gallery',
                style: _textStyle,
              ),
              onTap: () {
                // _loadPicker(context, ImageSource.gallery);
                _loadPicker(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.camera,
                size: 30,
                color: AdaptiveTheme.primaryColor(context),
              ),
              title: Text(
                'Camera',
                style: _textStyle,
              ),
              onTap: () async {
                // _loadPicker(context, ImageSource.camera);
                var cameraStatus = await Permission.camera.status;
                if (cameraStatus.isDenied) {
                  await Permission.camera.request();
                }
                if (await Permission.camera.isGranted)
                  _loadPicker(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future _loadPicker(ImageSource imgSource) async {
    final MediaType? action = await Dialogs()
        .mediaTypeDialog(context, '', 'Please Choose Your Option');
    FocusScope.of(context).requestFocus(FocusNode());
    if (action == MediaType.IMAGE) {
      if (imgSource == ImageSource.camera) {
        Navigator.of(context).pop();
        if ((_mediaFileWidgets.length) >= maxImagesAllowed) {
          Dialogs().ackInfoAlert(context,
              'Maximum of $maxImagesAllowed image files are only allowed');
          return;
        }
        var image = await _picker.pickImage(source: imgSource);
        _cropImage(File(image!.path));
      } else {
        Navigator.of(context).pop();
        if ((_mediaFileWidgets.length) >= maxImagesAllowed) {
          Dialogs().ackInfoAlert(context,
              'Maximum of $maxImagesAllowed image files are only allowed');
          return;
        }
        final pickedFile = await MultiImagePicker.pickImages(
          maxImages: maxImagesAllowed - _mediaFileWidgets.length,
          enableCamera: false,
          cupertinoOptions: CupertinoOptions(
            takePhotoIcon: "chat",
            doneButtonTitle: "Done",
          ),
          materialOptions: MaterialOptions(
            actionBarColor: "#ED247C",
            actionBarTitle: "Select Images",
            allViewTitle: "All Photos",
            useDetailsView: false,
            selectCircleStrokeColor: "#000000",
          ),
        );
        if (pickedFile != []) {
          if ((pickedFile.length + _mediaFileWidgets.length) >
              maxImagesAllowed) {
            Dialogs().ackInfoAlert(context,
                'Maximum of $maxImagesAllowed image files are only allowed');
            return;
          } else {
            List<Asset>? _imageFileList;
            // setState(() async {
            //   _imageFileList = pickedFile;
            //   if (_imageFileList!.length == 1) {
            //     await _cropImage(File(_imageFileList![0].path));
            //   } else {
            //     for (var file in _imageFileList!) {
            //       _savedImage = File(file.path);
            //       _mediaFileWidgets
            //           .add(Image.file(_savedImage, width: 80, height: 80));
            //     }
            //     widget.imageMultiSaveHandler(_imageFileList);
            //   }
            // });

            _imageFileList = pickedFile;
            if (_imageFileList.length == 1) {
              File file = await getImageFileFromAssets(_imageFileList[0]);
              await _cropImage(File(file.path));
            } else {
              for (var file in _imageFileList) {
                File file1 = await getImageFileFromAssets(file);
                _savedImage = File(file1.path);
                _mediaFileWidgets
                    .add(Image.file(_savedImage, width: 80, height: 80));
              }
              widget.imageMultiSaveHandler(_imageFileList);
            }
            setState(() {});
            // widget.imageMultiSaveHandler(_imageFileList);
          }
        }
      }
    } else if (action == MediaType.VIDEO) {
      Navigator.of(context).pop();
      if ((_videoPaths.length) >= maxVideosAllowed) {
        Dialogs().ackInfoAlert(
            context, 'Only $maxVideosAllowed video file is allowed');
        return;
      }
      var image = await _picker.pickVideo(source: imgSource);
      if (image != null) {
        int sizeInBytes = File(image.path).lengthSync();
        double sizeInMb = sizeInBytes / (1024 * 1024);
        if (sizeInMb > GlobalVariables.videoFileSizeForUpload) {
          Dialogs().ackInfoAlert(context,
              'Maximum file size should not be more than ${GlobalVariables.videoFileSizeForUpload}MB');
          return;
        }
        // _pickedImage = XFile(image.path);

        setState(() {
          _videoPaths.add(image.path);
        });

        widget.videoSaveHandler(File(image.path));
      }
    }
  }

  _cropImage(File picked) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: AppTheme.primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(minimumAspectRatio: 1.0),
        ]);
    if (croppedFile != null) {
      // _pickedImage = XFile(croppedFile.path);

      setState(() {
        _savedImage = File(croppedFile.path);
        _mediaFileWidgets.add(Image.file(_savedImage, width: 80, height: 80));
      });

      widget.imageSaveHandler(_savedImage);
    }
  }

  void _deleteImage(int index) {
    setState(() {
      _mediaFileWidgets.removeAt(index);
      widget.imageRemoveHandler(index);
    });
  }

  void _deleteVideo(int index) {
    setState(() {
      _videoPaths.removeAt(index);
    });
    widget.videoRemoveHandler(index);
  }

  Widget _getThumNailImage(String videoPath) {
    GenThumbnailImage? _futreImage = null;
    ImageFormat _format = ImageFormat.JPEG;
    int _quality = 50;
    int _sizeH = 100;
    int _sizeW = 100;
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

  @override
  Widget build(BuildContext context) {
    TextStyle _textViewStyle = kIsWeb || Platform.isAndroid
        ? AppTheme.lightTheme.textTheme.bodySmall!.copyWith(fontSize: 15)
        : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
        Widget>[
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Text('Upload Image/Video',
                style: _textViewStyle.copyWith(
                    fontSize: 16, fontWeight: FontWeight.w300)),
            Spacer(),
            Card(
              elevation: 0.0,
              color: Colors.white, // AppTheme.secondaryColor,
              child: Transform.rotate(
                angle: 120 * math.pi / 100,
                child: IconButton(
                    icon: Icon(Icons.attach_file),
                    color: AdaptiveTheme.primaryColor(context),
                    onPressed: widget.disable
                        ? null
                        : () {
                            if (_mediaFileWidgets.length < maxImagesAllowed ||
                                _videoPaths.length < maxVideosAllowed) {
                              _showPickOptions(context);
                            } else {
                              Dialogs().ackInfoAlert(context,
                                  'Maximum of $maxImagesAllowed image and $maxVideosAllowed video files are only allowed');
                            }
                          }),
              ),
            ),
          ],
        ),
      ),
      if (_mediaFileWidgets.isNotEmpty)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 100,
            //width: double.infinity,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                //physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _mediaFileWidgets.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      ImageCard(_mediaFileWidgets[index], index, _deleteImage),
                      const SizedBox(width: 5),
                    ],
                  );
                }),
          ),
        ),
      if (_videoPaths.isNotEmpty)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 100,
            //width: double.infinity,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                //physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _videoPaths.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      VideoThumbNailCard(_getThumNailImage(_videoPaths[index]),
                          index, _deleteVideo),
                      const SizedBox(width: 5),
                    ],
                  );
                }),
          ),
        ),
    ]);
  }
}

class ImageCard extends StatelessWidget {
  final Image imageTile;
  final int imageIndex;
  final Function deleteMediaHandler;
  ImageCard(
    this.imageTile,
    this.imageIndex,
    this.deleteMediaHandler,
  );
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          //padding: EdgeInsets.all(1.0),
          width: 100, height: 100,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0), color: Colors.white),
          child: Card(
            elevation: 1.0,
            child: imageTile,
          ),
        ),
        Positioned(
          right: -7,
          bottom: -7,
          child: IconButton(
            onPressed: () {
              deleteMediaHandler(imageIndex);
            },
            icon: Icon(
              Icons.delete_forever,
              size: 35,
            ),
          ),
        ),
      ],
    );
  }
}

class VideoThumbNailCard extends StatelessWidget {
  final Widget imageTile;
  final int imageIndex;
  final Function deleteMediaHandler;
  VideoThumbNailCard(
    this.imageTile,
    this.imageIndex,
    this.deleteMediaHandler,
  );
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          //padding: EdgeInsets.all(1.0),
          width: 100, height: 100,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0), color: Colors.white),
          child: Card(
            elevation: 1.0,
            child: imageTile,
          ),
        ),
        Positioned(
          right: -7,
          bottom: -7,
          child: IconButton(
            onPressed: () {
              deleteMediaHandler(imageIndex);
            },
            icon: Icon(
              Icons.delete_forever,
              size: 35,
            ),
          ),
        ),
        // Positioned(bottom: 0, child: Text('Video $imageIndex'))
      ],
    );
  }
}

Future<File> getImageFileFromAssets(Asset asset) async {
  final byteData = await asset.getByteData();

  final tempFile =
      File("${(await getTemporaryDirectory()).path}/${asset.name}");
  final file = await tempFile.writeAsBytes(
    byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
  );

  return file;
}
