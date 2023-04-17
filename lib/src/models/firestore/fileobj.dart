import 'package:flutter/material.dart';

class FileObj with ChangeNotifier {
  final String? type;

  final String? url;

  FileObj({
    this.type,
    this.url,
  });

  factory FileObj.fromJson(Map<String, dynamic> json) {
    return FileObj(
      type: json['type'],
      url: json['url'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
    };
  }

  Map<String, dynamic> toMap(FileObj file) {
    return {
      'type': file.type,
      'url': file.url,
    };
  }

  static List<Map> convertFileObjsToMap({required List<FileObj> fileObjs}) {
    List<Map> files = [];
    fileObjs.forEach((FileObj obj) {
      Map objMap = FileObj().toMap(obj);
      files.add(objMap);
    });
    return files;
  }
}
