class CityName {
  var cityID;
  final String cityName;

  CityName({
    required this.cityID,
    required this.cityName,
  });

  factory CityName.fromJson(Map<String, dynamic> json) {
    return CityName(
      cityID: json['cityID'],
      cityName: json['cityName'],
    );
  }
  static List<CityName> fromJsonList(List list) {
    return list.map((item) => CityName.fromJson(item)).toList();
  }

  bool isEqual(CityName? model) {
    return this.cityName == model?.cityName;
  }

  @override
  String toString() => cityName;
  //this method will prevent the override of toString
  bool filterByName(String filter) {
    return this.cityName.toLowerCase().contains(filter.toLowerCase());
  }
}
