import 'dart:io';

import 'package:flutter/material.dart';

import '../../../helpers/global_variables.dart';

import '../../../util/gen_thumpnail.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '/util/dialogs.dart';

import '../../../util/app_theme.dart';

class PostImagePickerWeb extends StatefulWidget {
  final Function imageSaveHandler;
  final Function imageRemoveHandler;
  final Function videoSaveHandler;
  final Function videoRemoveHandler;
  final Function imageMultiSaveHandler;
  final bool disable;
  PostImagePickerWeb(
    this.imageSaveHandler,
    this.imageRemoveHandler,
    this.videoSaveHandler,
    this.videoRemoveHandler,
    this.imageMultiSaveHandler,
    this.disable,
  );
  @override
  State<PostImagePickerWeb> createState() => _PostImagePickerWebState();
}

class _PostImagePickerWebState extends State<PostImagePickerWeb> {
  //XFile? _pickedImage;
  final _picker = ImagePicker();
  late File _savedImage;
  List<Image> _mediaFileWidgets = [];
  List<String> _videoPaths = [];
  int maxImagesAllowed = 4;
  int maxVideosAllowed = 1;

  // void _showPickOptions(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       shape:
  //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: <Widget>[
  //           ListTile(
  //             dense: true,
  //             leading: CircleAvatar(
  //               backgroundColor: AdaptiveTheme.primaryColor(context),
  //               child: Icon(Icons.camera, color: Colors.white),
  //             ),
  //             title: Text(
  //               'Camera',
  //               style: TextStyle(fontSize: 16, color: Colors.black),
  //             ),
  //             onTap: () {
  //               // _loadPicker(context, ImageSource.camera);
  //               _loadPicker(ImageSource.camera);
  //             },
  //           ),
  //           ListTile(
  //             leading: CircleAvatar(
  //               backgroundColor: AdaptiveTheme.primaryColor(context),
  //               child: Icon(Icons.collections, color: Colors.white),
  //             ),
  //             title: Text(
  //               'Gallery',
  //               style: TextStyle(fontSize: 16, color: Colors.black),
  //             ),
  //             onTap: () {
  //               // _loadPicker(context, ImageSource.gallery);
  //               _loadPicker(ImageSource.gallery);
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Future _loadPicker(ImageSource imgSource) async {
    final MediaType? action = await Dialogs()
        .mediaTypeDialog(context, '', 'Please Choose Your Option');
    FocusScope.of(context).requestFocus(FocusNode());
    if (action == MediaType.IMAGE) {
      /*if (imgSource == ImageSource.camera) {
        Navigator.of(context).pop();
        if ((_mediaFileWidgets.length) >= maxImagesAllowed) {
          Dialogs().ackAlert(context, 'Image Files',
              'Maximum of $maxImagesAllowed image files are only allowed');
          return;
        }
        var image = await _picker.pickImage(source: imgSource);
        _cropImage(File(image!.path));
      }*/
      //Navigator.of(context).pop();
      if ((_mediaFileWidgets.length) >= maxImagesAllowed) {
        Dialogs().ackAlert(context, 'Image Files',
            'Maximum of $maxImagesAllowed image files are only allowed');
        return;
      }
      final pickedFile = await _picker.pickMultiImage();
      if (pickedFile != null) {
        if ((pickedFile.length + _mediaFileWidgets.length) > maxImagesAllowed) {
          Dialogs().ackAlert(context, 'Image Files',
              'Maximum of $maxImagesAllowed image files are only allowed');
          return;
        } else {
          List<XFile>? _imageFileList;
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
            await _cropImage(File(_imageFileList[0].path));
          } else {
            for (var file in _imageFileList) {
              _savedImage = File(file.path);
              _mediaFileWidgets
                  .add(Image.network(file.path, width: 80, height: 80));
            }
            widget.imageMultiSaveHandler(_imageFileList);
          }
          setState(() {});
          // widget.imageMultiSaveHandler(_imageFileList);
        }
      }
    } else if (action == MediaType.VIDEO) {
      //Navigator.of(context).pop();
      if ((_videoPaths.length) >= maxVideosAllowed) {
        Dialogs().ackAlert(context, 'Video Files',
            'Only $maxVideosAllowed video file is allowed');
        return;
      }
      var image = await _picker.pickVideo(source: imgSource);
      if (image != null) {
        int sizeInBytes = await image.length();
        double sizeInMb = sizeInBytes / (1024 * 1024);
        if (sizeInMb > GlobalVariables.videoFileSizeForUpload) {
          Dialogs().ackAlert(context, 'Video Files',
              'Maximum file size should be ${GlobalVariables.videoFileSizeForUpload}MB');
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
          WebUiSettings(context: context),
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
        _mediaFileWidgets
            .add(Image.network(croppedFile.path, width: 80, height: 80));
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
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                Text('Upload Image/Video'),
                Spacer(),
                Card(
                  color: AppTheme.secondaryColor,
                  child: IconButton(
                      icon: Icon(Icons.attach_file),
                      color: Colors.white,
                      onPressed: widget.disable
                          ? null
                          : () {
                              if (_mediaFileWidgets.length < maxImagesAllowed ||
                                  _videoPaths.length < maxVideosAllowed) {
                                _loadPicker(ImageSource.gallery);
                              } else {
                                Dialogs().ackAlert(context, 'Media Files',
                                    'Maximum of $maxImagesAllowed image and $maxVideosAllowed video files are only allowed');
                              }
                            }),
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
                          ImageCard(
                              _mediaFileWidgets[index], index, _deleteImage),
                          SizedBox(width: 5),
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
                          VideoThumbNailCard(
                              _getThumNailImage(_videoPaths[index]),
                              index,
                              _deleteVideo),
                          SizedBox(width: 5),
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
