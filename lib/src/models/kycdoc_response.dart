import 'package:flutter/cupertino.dart';

class ParentDocumentTypeList with ChangeNotifier {
  ParentDocumentTypeList({
    required this.documentId,
    required this.documentType,
  });
  var documentId;
  final String documentType;

  factory ParentDocumentTypeList.fromJson(Map<String, dynamic> json) {
    return ParentDocumentTypeList(
      documentId: json["documentId"],
      documentType: json["documentType"],
    );
  }

  bool isEqual(ParentDocumentTypeList? model) {
    return this.documentType == model?.documentType;
  }

  @override
  String toString() => documentType;

  bool filterByName(String filter) {
    return this.documentType.toLowerCase().contains(filter.toLowerCase());
  }

  Map<String, dynamic> toJson() {
    return {
      "documentId": documentId,
      "documentType": documentType,
    };
  }
}
//
