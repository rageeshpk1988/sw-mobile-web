import '/src/models/school_division.dart';

class ParentReleation {
  final int relationID;
  final String relation;

  ParentReleation({
    required this.relationID,
    required this.relation,
  });

  factory ParentReleation.fromJson(Map<String, dynamic> json) {
    return ParentReleation(
      relationID: json['relationID'],
      relation: json['relation'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'relationID': relationID,
      'relation': relation,
    };
  }

  @override
  String toString() => relation;

  //this method will prevent the override of toString
  bool filterByName(String filter) {
    return this.relation.toLowerCase().contains(filter.toLowerCase());
  }
}

class DivisionAndParentRelation {
  final List<SchoolDivision> schoolDivisionList;
  final List<DivisionBySchoolList>? divisionBySchoolList;
  final List<ParentReleation> parentReleationList;
  DivisionAndParentRelation({
    required this.schoolDivisionList,
    this.divisionBySchoolList,
    required this.parentReleationList,
  });
  factory DivisionAndParentRelation.fromJson(Map<String, dynamic> json) {
    return DivisionAndParentRelation(
        schoolDivisionList: parseSchoolDivision(json['relationID']),
        parentReleationList: parseParentReleation(json['relation']),
        divisionBySchoolList:
            parseDivisionBySchoolList('divisionBySchoolList'));
  }
  static List<DivisionBySchoolList> parseDivisionBySchoolList(json) {
    final List<DivisionBySchoolList> divisions = [];
    for (Map<String, dynamic> dt in json) {
      DivisionBySchoolList division = DivisionBySchoolList.fromJson(dt);
      divisions.add(division);
    }
    return divisions;
  }

  static List<SchoolDivision> parseSchoolDivision(json) {
    final List<SchoolDivision> divisions = [];
    for (Map<String, dynamic> dt in json) {
      SchoolDivision division = SchoolDivision.fromJson(dt);
      divisions.add(division);
    }
    return divisions;
  }

  static List<ParentReleation> parseParentReleation(json) {
    final List<ParentReleation> relations = [];
    for (Map<String, dynamic> dt in json) {
      ParentReleation relation = ParentReleation.fromJson(dt);
      relations.add(relation);
    }
    return relations;
  }
}
