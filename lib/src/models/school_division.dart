class SchoolDivision {
  final String division;

  SchoolDivision({
    required this.division,
  });

  factory SchoolDivision.fromJson(Map<String, dynamic> json) {
    return SchoolDivision(
      division: json['division'].toUpperCase(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'division': division,
    };
  }

  @override
  String toString() => division.toUpperCase();

  //this method will prevent the override of toString
  bool filterByName(String filter) {
    return this.division.toLowerCase().contains(filter.toLowerCase());
  }
}

class DivisionBySchoolList {
  final int divisionMappedId;
  final String divisionMapped;
  DivisionBySchoolList({
    required this.divisionMappedId,
    required this.divisionMapped,
  });
  factory DivisionBySchoolList.fromJson(Map<String, dynamic> json) {
    return DivisionBySchoolList(
      divisionMappedId: json['divisionMappedId'],
      divisionMapped: json['divisionMapped'].toUpperCase(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'divisionMappedId': divisionMappedId,
      'divisionMapped': divisionMapped,
    };
  }

  @override
  String toString() => divisionMapped.toUpperCase();

  //this method will prevent the override of toString
  bool filterByName(String filter) {
    return this.divisionMapped.toLowerCase().contains(filter.toLowerCase());
  }
}
