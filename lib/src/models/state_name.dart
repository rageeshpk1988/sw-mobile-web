class StateName {
  int stateID;
  final String? stateName;

  StateName({
    required this.stateID,
    required this.stateName,
  });

  factory StateName.fromJson(Map<String, dynamic> json) {
    return StateName(
      stateID: json['stateID'],
      stateName: json['stateName'],
    );
  }
  static List<StateName> fromJsonList(List list) {
    return list.map((item) => StateName.fromJson(item)).toList();
  }

  bool isEqual(StateName? model) {
    return this.stateName == model?.stateName;
  }

  @override
  String toString() => stateName!;
  //this method will prevent the override of toString
  bool filterByName(String filter) {
    return this.stateName!.toLowerCase().contains(filter.toLowerCase());
  }
}
