class CountryName {
  final String countryID;
  final String countryName;

  CountryName({
    required this.countryID,
    required this.countryName,
  });

  factory CountryName.fromJson(Map<String, dynamic> json) {
    return CountryName(
      countryID: json['countryID'],
      countryName: json['countryName'],
    );
  }
  // static List<CountryName> fromJsonList(List list) {
  //   return list.map((item) => CountryName.fromJson(item)).toList();
  // }

  bool isEqual(CountryName? model) {
    return this.countryName == model?.countryName;
  }

  @override
  String toString() => countryName;

  //this method will prevent the override of toString
  bool filterByName(String filter) {
    return this.countryName.toLowerCase().contains(filter.toLowerCase());
  }
}
