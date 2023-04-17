import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../adaptive/adaptive_theme.dart';
import '../util/ui_helpers.dart';
import '../util/app_theme.dart';

class ProfileImagePicker extends StatefulWidget {
  final String? defaultImage;
  final Function imageHandler;
  ProfileImagePicker(this.defaultImage, this.imageHandler);
  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  XFile? _pickedImage;
  final _picker = ImagePicker();
  late File _savedImage;

  void _showPickOptions(BuildContext context) {
    TextStyle _textStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w400);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.image_search,
                size: 30,
                color: AdaptiveTheme.primaryColor(context),
              ),
              title: Text('Pick from Gallery', style: _textStyle),
              onTap: () {
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
                'Take a Picture',
                style: _textStyle,
              ),
              onTap: () async {
                var cameraStatus = await Permission.camera.status;
                if (cameraStatus.isDenied) {
                  await Permission.camera.request();
                }
                if (await Permission.camera.isGranted)
                  _loadPicker(ImageSource.camera);
              },
            )
          ],
        ),
      ),
    );
  }

  Future _loadPicker(ImageSource imgSource) async {
    var image = await _picker.pickImage(source: imgSource);
    if (image != null) _cropImage(File(image.path));
    Navigator.of(context).pop();
  }

  // _cropImage(File picked) async {
  //   File? croppedFile = await ImageCropper.cropImage(
  //     sourcePath: picked.path,
  //     aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
  //     // androidUiSettings: AndroidUiSettings(
  //     //     toolbarTitle: 'Crop Image',
  //     //     toolbarColor: AppTheme.primaryColor,
  //     //     toolbarWidgetColor: Colors.white,
  //     //     initAspectRatio: CropAspectRatioPreset.original,
  //     //     lockAspectRatio: false),
  //     // iosUiSettings: IOSUiSettings(minimumAspectRatio: 1.0),
  //   ) as File;
  //   if (croppedFile != null) {
  //     _pickedImage = XFile(croppedFile.path);

  //     setState(() {});
  //     _savedImage = File(croppedFile.path);
  //     widget.imageHandler(_savedImage);
  //     evictImage(widget.defaultImage);
  //   }
  // }
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
      _pickedImage = XFile(croppedFile.path);

      setState(() {});
      _savedImage = File(croppedFile.path);
      widget.imageHandler(_savedImage);
      evictImage(widget.defaultImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    // LoginResponse? _loginResponse =
    //     Provider.of<Auth>(context, listen: false).loginResponse;

    return Stack(children: [
      Container(
        height: 150,
        width: 100,
        child: _pickedImage == null
            ? getAvatarImage(widget.defaultImage, 80, 80)
            : CircleAvatar(
                backgroundColor: AppTheme.lightTheme.disabledColor,
                radius: 20,
                backgroundImage: FileImage(File(_pickedImage!.path)),
                onBackgroundImageError: (exception, context) {
                  // print('${widget.defaultImage} Cannot be loaded');
                },
              ),
      ),
      Positioned(
        right: 1,
        bottom: 10,
        child: FloatingActionButton(
          onPressed: () {
            _showPickOptions(context);
          },
          mini: true,
          child: Icon(Icons.camera_alt_rounded),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
      )
    ]);
  }
}
