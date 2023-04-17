class School {
  final int schoolId;
  final String schoolName;
  var schoolType;

  School({
    required this.schoolId,
    required this.schoolName,
    required this.schoolType,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      schoolId: json['schoolId'],
      schoolName: json['schoolName'],
      schoolType: json['schoolType'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'schoolId': schoolId,
      'schoolName': schoolName,
      'schoolType': schoolType,
    };
  }

  @override
  String toString() => schoolName;

  //this method will prevent the override of toString
  bool filterByName(String filter) {
    return this.schoolName.toLowerCase().contains(filter.toLowerCase());
  }
}
