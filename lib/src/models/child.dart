import 'package:flutter/material.dart';

class Child with ChangeNotifier {
  final String name;
  final String gender;
  final String? b2bStatus;
  final String? imageUrl;
  final String? country;
  final String? state;
  final String? location;
  int? childID;
  final String? schoolName;
  final String? className;
  final String? division;
  final String? relation;
  final int? boardId;
  final String? dob;
  var countryID;
  //these are all not part of the response. inconsistant data
  var cityId;
  var relationId;
  var schoolId;
  var stateId;
  var parentId;
  var schoolType;
  var tempDivision;
  var tempSchoolName;
  var tempStandard;

  Child({
    required this.name,
    required this.gender,
    this.b2bStatus,
    this.imageUrl,
    this.country,
    this.state,
    this.location,
    this.childID,
    this.schoolName,
    this.className,
    this.division,
    this.relation,
    this.boardId,
    this.dob,
    this.countryID,
    this.cityId,
    this.relationId,
    this.schoolId,
    this.stateId,
    this.parentId,
    this.schoolType,
    this.tempDivision,
    this.tempSchoolName,
    this.tempStandard,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      childID: json['childID'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      country: json['country'],
      state: json['state'],
      location: json['location'],
      schoolId: json['schoolId'],
      countryID: json['countryID'],
      schoolName: json['schoolName'],
      className: json['className'],
      division: json['division'],
      relation: json['relation'],
      boardId: json['boardId'],
      dob: json['dob'],
      b2bStatus: json['b2bStatus'],
      gender: json['gender'],
      relationId: json['relationId'],
      stateId: json['childStateId'],
      cityId: json['childLocationId'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'childID': childID,
      'name': name,
      'imageUrl': imageUrl,
      'country': country,
      'state': state,
      'location': location,
      'schoolId': schoolId,
      'countryID': countryID,
      'schoolName': schoolName,
      'className': className,
      'division': division,
      'relation': relation,
      'boardId': boardId,
      'dob': dob,
      'b2bStatus': b2bStatus,
      'gender': gender,
      'relationId': relationId,
      'childStateId': stateId,
      'childLocationId': cityId,
    };
  }
}
