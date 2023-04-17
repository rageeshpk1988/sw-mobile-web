import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:video_thumbnail/video_thumbnail.dart';

import '../adaptive/adaptive_circular_progressInd.dart';

/// TO GET THE THUMNAIL OF A VIDEO FILE
class ThumbnailRequest {
  final String? video;
  final String? thumbnailPath;
  final ImageFormat? imageFormat;
  final int? maxHeight;
  final int? maxWidth;
  final int? timeMs;
  final int? quality;

  const ThumbnailRequest(
      {this.video,
      this.thumbnailPath,
      this.imageFormat,
      this.maxHeight,
      this.maxWidth,
      this.timeMs,
      this.quality});
}

class ThumbnailResult {
  final Image? image;
  final int? dataSize;
  final int? height;
  final int? width;
  const ThumbnailResult({
    this.image,
    this.dataSize,
    this.height,
    this.width,
  });
}

class GenThumbnailImage extends StatefulWidget {
  final ThumbnailRequest thumbnailRequest;

  const GenThumbnailImage({
    Key? key,
    required this.thumbnailRequest,
  }) : super(key: key);

  @override
  _GenThumbnailImageState createState() => _GenThumbnailImageState();
}

class _GenThumbnailImageState extends State<GenThumbnailImage> {
  Future<ThumbnailResult> genThumbnail(ThumbnailRequest r) async {
    Uint8List? bytes;
    final Completer<ThumbnailResult> completer = Completer();
    if (r.thumbnailPath != null) {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: r.video!,
          thumbnailPath: r.thumbnailPath,
          imageFormat: r.imageFormat!,
          maxHeight: r.maxHeight!,
          maxWidth: r.maxWidth!,
          timeMs: r.timeMs!,
          quality: r.quality!);

      //print("thumbnail file is located: $thumbnailPath");

      final file = File(thumbnailPath!);
      bytes = file.readAsBytesSync();
    } else {
      bytes = await VideoThumbnail.thumbnailData(
          video: r.video!,
          imageFormat: r.imageFormat!,
          maxHeight: r.maxHeight!,
          maxWidth: r.maxWidth!,
          timeMs: r.timeMs!,
          quality: r.quality!);
    }

    int _imageDataSize = bytes!.length;
    //print("image size: $_imageDataSize");

    final _image = Image.memory(bytes);
    _image.image
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(ThumbnailResult(
        image: _image,
        dataSize: _imageDataSize,
        height: info.image.height,
        width: info.image.width,
      ));
    }));
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThumbnailResult>(
      future: genThumbnail(widget.thumbnailRequest),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final _image = snapshot.data.image;
          return _image;
        } else if (snapshot.hasError) {
          return Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.red,
            child: Text(
              "Error:\n${snapshot.error.toString()}",
            ),
          );
        } else {
          return AdaptiveCircularProgressIndicator();
        }
      },
    );
  }
}
