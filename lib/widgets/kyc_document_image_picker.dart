import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:getwidget/getwidget.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../adaptive/adaptive_theme.dart';
import '../util/app_theme.dart';
import '../util/app_theme_cupertino.dart';

class DocImagePicker extends StatefulWidget {
  final String? defaultImage;
  final Function imageHandler;
  final bool isLoading;
  DocImagePicker(this.defaultImage, this.imageHandler, this.isLoading);
  @override
  State<DocImagePicker> createState() => _DocImagePickerState();
}

class _DocImagePickerState extends State<DocImagePicker> {
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
              title: Text('Take a Picture', style: _textStyle),
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
    _cropImage(File(image!.path));
    Navigator.of(context).pop();
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
      _pickedImage = XFile(croppedFile.path);

      setState(() {});
      _savedImage = File(croppedFile.path);
      widget.imageHandler(_savedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
        title: Text(
          'Attach File',
          style: kIsWeb || Platform.isAndroid
              ? AppTheme.lightTheme.textTheme.bodyMedium!
                  .copyWith(fontSize: 16, fontWeight: FontWeight.w500)
              : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
                  .copyWith(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: FloatingActionButton(
          onPressed: widget.isLoading
              ? null
              : () {
                  _showPickOptions(context);
                },
          mini: true,
          child: Icon(Icons.attach_file),
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryColor,
        ),
      ),
      Container(
        margin: const EdgeInsets.only(
          left: 0,
          top: 60,
          right: 10,
          bottom: 10,
        ),
        height: 120,
        width: 120,
        child: GFAvatar(
          shape: GFAvatarShape.standard,
          backgroundColor: AppTheme.lightTheme.disabledColor,
          radius: 20,
          child: Center(
            child: _pickedImage == null && widget.defaultImage == ''
                ? Text(
                    "",
                    style: TextStyle(color: Colors.white),
                  )
                : null,
          ),
          backgroundImage:
              _pickedImage == null ? null : FileImage(File(_pickedImage!.path)),
        ),
      ),
    ]);
  }
}
//